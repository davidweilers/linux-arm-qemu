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
# exit
# export ARCH=arm64
# export CROSS_COMPILE=aarch64-linux-gnu-

cd ${DIR}
if ! [ -d "${DIR}/busybox" ]; then
	git clone --depth=1 https://github.com/mirror/busybox.git busybox
fi

if ! [ -f "${DIR}/busybox/.config" ]; then
	cd ${DIR}/busybox
	cp ${DIR}/busybox.config .config
	make -j$(nproc)

	# mkdir -p ${DIR}/rootfs/bin
	# cp busybox ${DIR}/rootfs/bin/busybox
	# ln -s busybox ${DIR}/rootfs/bin/sh
	# ln -s busybox ${DIR}/rootfs/bin/ls
	# ln -s busybox ${DIR}/rootfs/bin/mkdir
	# cd ${DIR}/rootfs
	# make -t ${DIR}/rootfs install
	# exit
fi

cd ${DIR}
if ! [ -d "${DIR}/linux" ]; then
	git clone --depth=1 https://github.com/torvalds/linux.git linux
fi

cd ${DIR}/linux
if ! [ -f "${DIR}/linux/.config" ]; then
	cd ${DIR}/linux
	cp ${DIR}/linux.config .config
	# make versatile_defconfig
	# # make distclean
	# make clean
	make tinyconfig
	make menuconfig
	make -j$(nproc)
	# make -j$(nproc) dtbs
fi

# ---

cd ${DIR}
rm -rf ${DIR}/rootfs
mkdir -p ${DIR}/rootfs/{bin,sbin,etc,usr,lib,dev,proc,sys}
ln -s busybox ${DIR}/rootfs/bin/sh
cp ${DIR}/busybox/busybox ${DIR}/rootfs/bin/
# cat > ${DIR}/rootfs/init << 'EOF'
# #!/bin/bash
# mount -t proc none /proc
# mount -t sysfs none /sys
# mount -t devtmpfs none /dev
# while true; do
# exec /bin/bash
# done
# EOF
# chmod +x ${DIR}/rootfs/init
cp main_static_arm32 ${DIR}/rootfs/init
chmod +x ${DIR}/rootfs/init
cd ${DIR}/rootfs
find . | cpio -R 0:0 -o -H newc | gzip > ../initrd.gz
cd ${DIR}
zcat initrd.gz | cpio -ivt
# exit

qemu=(
	-machine virt # ,highmem=off #versatilepb # raspi3b
	# -cpu max
	# -cpu arm1176
	-cpu cortex-a15
	-kernel linux/arch/arm/boot/zImage
	# -dtb linux/arch/arm/boot/dts/arm/vexpress-v2p-ca15_a7.dtb
	# -kernel linux/arch/x86/boot/bzImage
	-initrd initrd.gz
	# -append "root=/dev/vda console=ttyAMA0"
	# -device virtio-gpu-device
	# -append "fbcon=map:0"
	# -device virtio-gpu-pci
	# -device virtio-blk-device,drive=hd0
	-append "root=/dev/ram init=/init earlyprintk=serial,ttyAMA0 console=ttyAMA0"
	-device ramfb
	-display default,show-cursor=on
	# -vga std
	# -append "console=ttyS0"
	# -append "console=ttyAMA0"
	-m 256M
	# -serial stdio
	# -monitor stdio
	# -parallel none
	# -monitor stdio
	# -serial mon:stdio
	-no-reboot
	# -nographic
)

qemu-system-arm "${qemu[@]}"
