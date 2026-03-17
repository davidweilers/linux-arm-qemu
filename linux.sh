#!/bin/bash

# make -j$(nproc)
# make tinyconfig

# PASSWORD_HASH=$(openssl passwd -6)
USERNAME='pi'

DIR=${PWD}

# ARCH=x86_64
# CROSS=x86_64-linux-gnu

# export ARCH=x86
# export CROSS_COMPILE=x86_64-linux-gnu-

# export ARCH=arm64
# export CROSS_COMPILE=aarch64-linux-gnu-

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabi-

# qemu-system-arm
# export ARCH=arm64
# export CROSS_COMPILE=aarch64-linux-gnu-

cd ${DIR}/busybox
# make clean
# cd ${DIR}/linux
# make clean

# make defconfig
# # make clean
# sed -e 's/.*FEATURE_PREFER_APPLETS.*/CONFIG_FEATURE_PREFER_APPLETS=y/' -i .config
# sed -e 's/.*FEATURE_SH_STANDALONE.*/CONFIG_FEATURE_SH_STANDALONE=y/' -i .config
# sed -e 's/.*CONFIG_SHA1_HWACCEL.*/CONFIG_SHA1_HWACCEL=n/' -i .config
# sed -e 's/.*CONFIG_STATIC.*/CONFIG_STATIC=y/' -i .config
# sed -e 's/.*CONFIG_TC.*/CONFIG_TC=n/' -i .config
# sed -i 's/.*CONFIG_STATIC_LIBGCC=.*/CONFIG_STATIC_LIBGCC=y/' -i .config
# make menuconfig
# ARCH=${ARCH} CROSS_COMPILE=${CROSS}- make menuconfig		
# make -j$(nproc)
mkdir -p ${DIR}/rootfs/bin
cp busybox ${DIR}/rootfs/bin/busybox
# ln -s busybox ${DIR}/rootfs/bin/sh
# ln -s busybox ${DIR}/rootfs/bin/ls
# ln -s busybox ${DIR}/rootfs/bin/mkdir
# cd ${DIR}/rootfs
# make -t ${DIR}/rootfs install
# exit

cd ${DIR}/linux
# make versatile_defconfig
# # make distclean
# make clean
make tinyconfig
# # make menuconfig
make -j$(nproc)

# exit

cd ${DIR}/rootfs
find . | cpio -o -H newc | gzip > ../initrd.gz

cd ${DIR}

qemu=(
	-machine versatilepb # raspi3b
	# -cpu arm1176
	# -cpu cortex-a57
	-kernel linux/arch/arm/boot/zImage
	-dtb linux/arch/arm/boot/dts/arm/versatile-pb.dtb
	# -kernel linux/arch/x86/boot/bzImage
	-initrd initrd.gz
	-append "root=/dev/ram boot=/init init=/init earlyprintk=serial,ttyAMA0 console=ttyAMA0"
	# -vga std
	# -append "console=ttyS0"
	# -append "console=ttyAMA0"
	# -m 256M
	# -serial stdio
	# -monitor stdio
	# -parallel none
	# -monitor stdio
	# -serial mon:stdio
	-no-reboot
	-nographic
)

qemu-system-arm "${qemu[@]}"

