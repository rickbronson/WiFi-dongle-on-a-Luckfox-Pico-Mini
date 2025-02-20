  WiFi dongle on a Luckfox Pico Mini
======================================================================================

  The Luckfox Pico Mini (Rockchip RV1103 Cortex A7 1.2GHz, 64MB DDR2) is one of the smallest boards that runs a full distribution of Linux but it doesn't have a wireless chip. So here we will get working a WiFi dongle.


You will need one of the following:

 - A USB C to USB A female OTG cable, preferably one that has a split to provide power.
 - A USB to serial converter hooked up according to:

![alt text](https://github.com/rickbronson/WiFi-dongle-on-a-Luckfox-Pico-Mini/blob/master/docs/hardware/hookup2.png "hookup")

 - One of the following WiFi dongles:
   - rtl8xxxu.ko 0bda:b720 Realtek Semiconductor Corp. RTL8723BU 802.11b/g/n WLAN Adapter
   - r8712u.ko 0bda:8172 Realtek Semiconductor Corp. RTL8191SU 802.11n WLAN Adapter
   - r8188eu.ko 0bda:0179 Realtek Semiconductor Corp. RTL8188ETV Wireless LAN 802.11n Network Adapter
   - rt2800usb.ko 1737:0077 802.11g Adapter [Linksys WUSB54GC v3] WUSB54GC v3 802.11g Adapter [Ralink RT2070L]
   - rtl8192cu.ko 0bda:8176 Realtek Semiconductor Corp. RTL8188CUS 802.11n WLAN Adapter

The following ones were tried but I could not get them working:

   - libertas_tf_usb.ko 1286:2001 Marvell Semiconductor, Inc. 88W8388 802.11a/b/g WLAN
   - 8821cu.ko 0bda:c820 Realtek Semiconductor Corp. 802.11ac NIC

Steps for install:

 - On your Linux box do:

```
git clone https://github.com/rickbronson/WiFi-dongle-on-a-Luckfox-Pico-Mini
cd WiFi-dongle-on-a-Luckfox-Pico-Mini
git clone https://github.com/LuckfoxTECH/luckfox-pico
git clone https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
mkdir -p lib
mv linux-firmware lib/firmware # move firmware to the right spot
cd luckfox-pico
sudo ./build.sh # choose your board, SD Card, Ubuntu
cp ../luckfox_rv1106_linux_defconfig sysdrv/source/kernel/.config
cd sysdrv/source/kernel
make ARCH=arm savedefconfig
cp defconfig arch/arm/configs/luckfox_rv1106_linux_defconfig
cd ../../..
sudo ./build.sh driver # build device driver modules, then copy firmware to filesystem
sudo cp -a sysdrv/source/objs_kernel/drv_ko/lib/modules output/out/rootfs_uclibc_rv1106/usr/lib
sudo cp -a ../lib/firmware/usb8388.bin ../lib/firmware/libertas/usb8388_v5.bin ../lib/firmware/rtlwifi ../lib/firmware/*7601* ../lib/firmware/rt2870.bin output/out/rootfs_uclibc_rv1106/usr/lib/firmware
sudo ./build.sh firmware  # build SD Card image sub-parts
cd ..
make full.img  # build SD Card image
# put SD card in, change the X in the following command to your SD Card drive letter:
sudo pv full.img | sudo dd bs=1M oflag=direct,sync of=/dev/sdX
# Plug SD Card into target and via USB serial converter, log into to root and do:
luckfox-config
 # goto Advanced Options->USB and set to Host, then:
reboot
lsusb # should show your dongle
# do this to get rid of any previous connections:
nmcli --fields UUID,TIMESTAMP-REAL con show | grep -v UUID | awk '{print $1}' | while read line; do sudo nmcli con delete uuid $line; done
nmcli device wifi connect <ESSID> --ask  # should connect to your router
ifconfig # should show your connection
nmcli device wifi list # should show all AP's
```
