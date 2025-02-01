PROJ=luckfox-pico
export OPT_HOME := $(shell pwd)
export PATH=$(shell printenv PATH):$(PWD)/$(PROJ)/tools/linux/toolchain/arm-rockchip830-linux-uclibcgnueabihf/bin
CROSS_COMPILE=arm-rockchip830-linux-uclibcgnueabihf-

all: full.img

kernel:
	cd $(PROJ)/sysdrv/source/objs_kernel; make drivers ARCH=arm CROSS_COMPILE=arm-rockchip830-linux-uclibcgnueabihf-
	cd $(PROJ)/sysdrv/source/objs_kernel; make ARCH=arm CROSS_COMPILE=arm-rockchip830-linux-uclibcgnueabihf-

IMAGE_OUT=$(PWD)/full.img
IMAGE_DIR=$(PROJ)/output/image

#blkdevparts=mmcblk1:32K(env),512K@32K(idblock),256K(uboot),32M(boot),512M(oem),256M(userdata),6G(rootfs),-(media)
# from https://github.com/LuckfoxTECH/$(PROJ)/issues/66
full.img: $(IMAGE_DIR)/boot.img $(IMAGE_DIR)/env.img $(IMAGE_DIR)/idblock.img $(IMAGE_DIR)/oem.img $(IMAGE_DIR)/rootfs.img $(IMAGE_DIR)/uboot.img $(IMAGE_DIR)/userdata.img
	cd $(IMAGE_DIR); cp env.img $(IMAGE_OUT)
	cd $(IMAGE_DIR); dd bs=1k seek=32 if=idblock.img of=$(IMAGE_OUT)
	cd $(IMAGE_DIR); dd bs=1k seek=`dc -e '32 512 + f'` if=uboot.img of=$(IMAGE_OUT)
	cd $(IMAGE_DIR); dd bs=1k seek=`dc -e '32 512 256 + + f'` if=boot.img of=$(IMAGE_OUT)
	cd $(IMAGE_DIR); dd bs=1k seek=`dc -e '32 512 256 32 1024 * + + + f'` if=oem.img of=$(IMAGE_OUT)
	cd $(IMAGE_DIR); dd bs=1k seek=`dc -e '32 512 256 32 1024 * 512 1024 * + + + + f'` if=userdata.img of=$(IMAGE_OUT)
	cd $(IMAGE_DIR); dd bs=1k seek=`dc -e '32 512 256 32 1024 * 512 1024 * 256 1024 * + + + + + f'` if=rootfs.img of=$(IMAGE_OUT)

flash_image:
	cd $(IMAGE_DIR); sudo pv $(IMAGE_OUT) | sudo dd bs=1M oflag=direct,sync of=/dev/sdb
