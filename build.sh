#!/bin/sh -xe
build_root=./rpmbuild
stable_kernel_root=/root/Programs/linux-stable
source_root=$stable_kernel_root/fs/ocfs2

# first param input as release number, default 1
release=${1:-1}

mkdir -p $build_root/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
build_root=$(readlink -fn ${build_root})  ### rpm wants absolute path

cd $stable_kernel_root
githash=$(git log -1 HEAD --format=%H)
# prepare source package
# TODO archive from git tag
git archive --format=tar.gz --prefix=ocfs2-1.5.0/ -o $build_root/SOURCES/ocfs2-1.5.0.tar.gz HEAD fs/ocfs2
cd -

# prepare spec
sed -e "s/@githash@/$githash/g" -e "s/@release@/${release}/g" ./ocfs2-kmod.spec.in > ./ocfs2-kmod.spec
mv ./ocfs2-kmod.spec $build_root/SPECS

# prepare other dependency and tools
cp ./ocfs2.files $build_root/SOURCES
cp ./tools/* $build_root/SOURCES

# build rpm package
rpmbuild -ba --define "_topdir $build_root" $build_root/SPECS/ocfs2-kmod.spec
