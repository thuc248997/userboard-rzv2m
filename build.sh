#!/bin/bash -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
IP_ADDR=$(ip address | grep 192.168 | head -1 | awk '{print $2}' | awk -F '/' '{print $1}')

function print_boot_example() {
	echo ""
	echo ">> FOR MMC BOOT"
	echo -e "${YELLOW} => setenv bootmmc 'setenv bootargs rw rootwait earlycon root=/dev/mmcblk0p2; fatload mmc 1:1 0x48080000 Image; fatload mmc 1:1 0x48000000 r9a09g011gbg-evaluation-board.dtb; booti 0x48080000 - 0x48000000' ${NC}"
	echo -e "${YELLOW} => run bootmmc ${NC}"
	echo ""
	echo ">> FOR SD BOOT"
	echo -e "${YELLOW} => setenv bootsd 'setenv bootargs rw rootwait earlycon root=/dev/mmcblk1p2; fatload mmc 0:1 0x48080000 Image; fatload mmc 0:1 0x48000000 r9a09g011gbg-evaluation-board.dtb; booti 0x48080000 - 0x48000000' ${NC}"
	echo -e "${YELLOW} => run bootsd ${NC}"
	echo ""
	echo ">> FOR USB BOOT"
	echo -e "${YELLOW} => setenv bootusb 'setenv bootargs rw rootwait earlycon root=/dev/sda2; usb reset; fatload usb 0:1 0x48080000 Image; fatload usb 0:1 0x48000000 r9a09g011gbg-evaluation-board.dtb; booti 0x48080000 - 0x48000000' ${NC}"
	echo -e "${YELLOW} => run bootusb ${NC}"
	echo ""
	echo ">> FOR NFS BOOT"
	echo -e "${YELLOW} => setenv ethaddr 2E:09:0A:00:BE:11 ${NC}"
	echo -e "${YELLOW} => setenv ipaddr $(echo ${IP_ADDR} | grep 192.168 | head -1 | awk -F '.' '{print $1 "." $2 "." $3}').133 ${NC}"
	echo -e "${YELLOW} => setenv serverip ${IP_ADDR} ${NC}"
	echo -e "${YELLOW} => setenv NFSROOT '\${serverip}:$(pwd)/rootfs' ${NC}"
	echo -e "${YELLOW} => setenv core1_vector 0x01000000 ${NC}"
	echo -e "${YELLOW} => setenv core1addr 0x01000000 ${NC}"
	echo -e "${YELLOW} => setenv core1_firmware core1_firmware.bin ${NC}"
	echo -e "${YELLOW} => setenv fdt_addr 0x58000000 ${NC}"
	echo -e "${YELLOW} => setenv fdt_file r9a09g011gbg-evaluation-board.dtb ${NC}"
	echo -e "${YELLOW} => setenv loadaddr 0x58080000 ${NC}"
	echo -e "${YELLOW} => setenv kernel Image ${NC}"
	echo -e "${YELLOW} => saveenv ${NC}"

	echo -e "${YELLOW} => setenv bootnfs 'nfs \${loadaddr} \${NFSROOT}/boot/Image; nfs \${fdt_addr} \${NFSROOT}/boot/r9a09g011gbg-evaluation-board.dtb; nfs \${core1addr} \${NFSROOT}/boot/\${core1_firmware}; setenv bootargs rw rootwait earlycon root=/dev/nfs nfsroot=\${NFSROOT},nfsvers=3 ip=dhcp:rzv2m:eth0; booti \${loadaddr} - \${fdt_addr}' ${NC}"
	echo -e "${YELLOW} => run bootnfs ${NC}"
	echo ""

# sysbench --test=fileio --num-threads=20 --file-total-size=1G --file-test-mode=rndrw prepare && sysbench --test=fileio --num-threads=20 --file-total-size=1G --file-test-mode=rndrw run && sysbench --test=fileio --num-threads=20 --file-total-size=1G --file-test-mode=rndrw cleanup
}

CORE_IMAGE=core-image-bsp
CORE_IMAGE_SDK=core-image-bsp
MACHINE=rzv2m
TOOLCHAIN=linaro-gcc
#TOOLCHAIN=poky-gcc
WORK=`pwd`

##########################################################
#
sudo umount mnt || true
mkdir -p mnt && sudo rm -rfv mnt/*
#[ ! -f proprietary/RTM0AC0000XV264D30SL41C_3_0_17.zip ] && exit 1
sudo chown -R ${USER}.${USER} ${WORK}/proprietary

##########################################################
#
[ -d $HOME/.cargo/bin ] && export PATH=$HOME/.cargo/bin:$PATH
if [ 0 -eq `apt list --installed 2>&1 | grep clang-3.9 | grep -v WARNING | wc -l` ]; then
	echo -e "${YELLOW}>> apt-get install ...${NC}"
	sudo apt-get update
	sudo apt-get install -y libstdc++6 lib32stdc++6
	sudo apt-get install -y android-tools-adb quilt

	sudo apt-get install -y libdrm-dev libpng-dev
	sudo apt-get install -y linux-firmware
	sudo apt-get install -y git build-essential flex bison qemu-user-static debootstrap schroot nfs-kernel-server nfs-common
	sudo apt install -y --no-install-recommends git cmake ninja-build gperf ccache dfu-util device-tree-compiler wget \
		python3-dev python3-pip python3-setuptools python3-tk python3-wheel python3-serial xz-utils file make gcc gcc-multilib g++-multilib libsdl2-dev libhugetlbfs-dev libsysfs-dev sysbench

	sudo apt-get install -y binutils-aarch64-linux-gnu gcc-aarch64-linux-gnu
	sudo apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libegl1-mesa libsdl1.2-dev pylint3 xterm cpio python python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping libssl-dev
	sudo apt-get install -y e2fsprogs
	sudo apt-get install -y p7zip-full p7zip-rar

	sudo apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat \
		cpio python python3 python3-pip python3-pexpect python3-git python3-jinja2 xz-utils debianutils iputils-ping libsdl1.2-dev xterm p7zip-full autoconf2.13
	sudo apt install -y clang llvm clang-3.9 llvm-3.9
	sudo apt-get install -y build-essential libasound2-dev libcurl4-openssl-dev libdbus-1-dev libdbus-glib-1-dev libgconf2-dev libgtk-3-dev libgtk2.0-dev libpulse-dev \
		libx11-xcb-dev libxt-dev nasm nodejs openjdk-8-jdk-headless python-dbus python-dev python-pip python-setuptools software-properties-common unzip uuid wget xvfb yasm zip
	[ "$(lsb_release -a | grep Codename: | awk '{print $2}')X" == "bionicX" ] && sudo apt-get install libcurl4 libcurl4-openssl-dev -y
	sudo apt-get install -y libftdi-dev
	sudo apt-get install -y diffstat unzip texinfo chrpath socat cpio python python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping libsdl1.2-dev xterm p7zip-full
	sudo apt-get install -y android-tools-fsutils ccache libv8-dev pax gnutls-bin libftdi-dev
	sudo apt-get install -y gcc-aarch64-linux-gnu tftp tftpd-hpa nfs-kernel-server nfs-common tar rar gzip bzip2 pv fbi
fi
#fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=rwtest --filename=rwtest --rwmixread=70 --bs=4k --iodepth=64 --size=1G --readwrite=randrw && rm -rfv rwtest
TFTPBOOT=/var/lib/tftpboot
[ -d ${TFTPBOOT} ] && sudo chmod 777 ${TFTPBOOT}

##########################################################
#
echo -e "${YELLOW}>> git clone ${NC}"
(git clone git://git.yoctoproject.org/poky || true) &
(git clone git://git.linaro.org/openembedded/meta-linaro.git || true) &
(git clone git://git.openembedded.org/meta-openembedded.git || true) &
(git clone -b rocko/rzv2m https://github.com/renesas-rz/meta-rzv meta-rzv2m || true) &
(git clone http://git.yoctoproject.org/cgit.cgi/meta-gplv2 || true) &
wait

##########################################################
#
#META_RZV_COMMIT=rocko/rzv2m
#META_RZV_COMMIT=RZV2M-BSP-V1.0.0_for_Web
META_RZV_COMMIT=RZV2M-BSP-V1.0.0
POKY_COMMIT=7e7ee662f5dea4d090293045f7498093322802cc
META_OE_COMMIT=352531015014d1957d6444d114f4451e241c4d23
META_GPLV2_COMMIT=f875c60ecd6f30793b80a431a2423c4b98e51548

##########################################################
#
echo -e "${YELLOW}>> git ckeckout ${NC}"
cd ${WORK}/poky && (git checkout -b tmp ${POKY_COMMIT} || true)
cd ${WORK}/meta-linaro && (git checkout -b tmp 75dfb67bbb14a70cd47afda9726e2e1c76731885 || true)
cd ${WORK}/meta-openembedded && (git checkout -b tmp ${META_OE_COMMIT} || true)
cd ${WORK}/meta-rzv2m && (git checkout ${META_RZV_COMMIT} || true)
cd ${WORK}/meta-gplv2 && (git checkout -b tmp ${META_GPLV2_COMMIT} || true)

##########################################################
#
echo -e "${YELLOW}>> oe-init-build-env ${NC}"
cd ${WORK}
source poky/oe-init-build-env $WORK/build
cd ${WORK}/build
cp -fv ../meta-userboard-rzv2m/docs/sample/conf/${MACHINE}/${TOOLCHAIN}/*.conf ./conf/
cp -fv ../meta-userboard-rzv2m/conf/machine/rzv2m.conf ../meta-rzv2m/conf/machine/

##########################################################
#
cd ${WORK}
[ ! -d meta-drpai ] && tar zxvf proprietary/rzv2m_meta-drpai_ver5.00.tar.gz
[ ! -d meta-openamp ] && tar zxvf proprietary/rzv2m_isp_support-pkg_v110.tar.gz
sed 's/master/main/' -i meta-openamp/recipes-openamp/libmetal/libmetal.inc
sed 's/master/main/' -i meta-openamp/recipes-openamp/open-amp/open-amp.inc
#${WORK}/poky/bitbake/bin/bitbake-layers add-layer ${WORK}/meta-drpai

##########################################################
#
echo -e "${YELLOW}>> meta-userboard ${NC}"
cd ${WORK}/build
${WORK}/poky/bitbake/bin/bitbake-layers show-layers

##########################################################
#
echo -e "${YELLOW}>> ${CORE_IMAGE} ${NC}"
cd ${WORK}/build
${WORK}/poky/bitbake/bin/bitbake ${CORE_IMAGE} -v

##########################################################
#
echo -e "${YELLOW}>> drp-ai_translator_release ${NC}"
cd ${WORK}
[ ! -d drp-ai_translator_release -a -x ./proprietary/DRP-AI_Translator-v1.60-Linux-x86_64-Install ] && echo y | ./proprietary/DRP-AI_Translator-v1.60-Linux-x86_64-Install
cd ${WORK}/drp-ai_translator_release
if [ -f UserConfig/addrmap_in_yolov2.yaml -a -f UserConfig/prepost_yolov2.yaml ]; then
	echo -e "${YELLOW}>> yolov2 ${NC}"
	rm -rfv output/yolov2
	./run_DRP-AI_translator_V2M.sh yolov2 -onnx ./onnx/yolov2.onnx
	ls -l output/yolov2
fi

##########################################################
#
echo -e "${YELLOW}>> sstate-cache-management.sh ${NC}"
#cd ${WORK} && poky/scripts/sstate-cache-management.sh -d -y --cache-dir=build/sstate-cache

##########################################################
#
cd ${WORK}
if [ -d ${TFTPBOOT} -o -L ${TFTPBOOT} ]; then
        echo -e "${YELLOW}>> TFTPBOOT ${NC}"
        rm -rfv ${TFTPBOOT}/Image
        rm -rfv ${TFTPBOOT}/Image-*${MACHINE}*.bin
        rm -rfv ${TFTPBOOT}/Image--*
        rm -rfv ${TFTPBOOT}/Image-r9*.dtb
        rm -rfv ${TFTPBOOT}/r9a*.dtb

        /bin/cp -Rpfv build/tmp/deploy/images/${MACHINE}/$(ls -l build/tmp/deploy/images/${MACHINE}/Image-${MACHINE}.bin | awk '{print $11}') ${TFTPBOOT}/Image
	/bin/cp -Rpfv proprietary/core1_firmware.bin ${TFTPBOOT}/
        cd ${WORK}/build/tmp/deploy/images/${MACHINE}
        for D in $(ls -l r9a*.dtb | grep '\->' | awk '{print $9}' | xargs file | awk '{print $1}' | sed 's!:!!g'); do
                L=${D}; S=$(file ${L} | awk '{print $5}')
                /bin/cp -Rpfv ${S} ${TFTPBOOT}/${L}
        done
        cd -
fi

##########################################################
#
echo -e "${YELLOW}>> exported rootfs ${NC}"
cd ${WORK}
mkdir -p ${WORK}/rootfs
sudo /bin/rm -rf ${WORK}/rootfs/*
sudo tar zxvf ${WORK}/build/tmp/deploy/images/${MACHINE}/${CORE_IMAGE}-${MACHINE}.tar.gz -C ${WORK}/rootfs
sudo tar zxvf ${WORK}/build/tmp/deploy/images/${MACHINE}/modules-${MACHINE}.tgz -C ${WORK}/rootfs
sudo /bin/cp -Rpfv build/tmp/deploy/images/${MACHINE}/$(ls -l build/tmp/deploy/images/${MACHINE}/modules-${MACHINE}.tgz | awk '{print $11}') ${WORK}/rootfs/boot/modules-${MACHINE}.tgz
sudo /bin/cp -Rpfv build/tmp/deploy/images/${MACHINE}/$(ls -l build/tmp/deploy/images/${MACHINE}/${CORE_IMAGE}-${MACHINE}.tar.gz | awk '{print $11}') ${WORK}/rootfs/boot/${CORE_IMAGE}-${MACHINE}.tar.gz
sudo /bin/cp -Rpfv proprietary/core1_firmware.bin ${WORK}/rootfs/boot/
cd ${WORK}/build/tmp/deploy/images/${MACHINE}
for D in $(ls -l r9a*.dtb | grep '\->' | awk '{print $9}' | xargs file | awk '{print $1}' | sed 's!:!!g'); do
	L=${D}; S=$(file ${L} | awk '{print $5}')
	sudo /bin/cp -Rpfv ${S} ${WORK}/rootfs/boot/${L}
done
sudo chmod 777 ${WORK}/rootfs/boot
sudo chown -R ${USER}.${USER} ${WORK}/rootfs/boot/*

##########################################################
#
cd ${WORK}
if [ $(ls /dev/disk/by-id | grep SD_MMC | wc -l) -eq 0 \
        -a $(ls /dev/disk/by-id | grep Generic_USB_Flash_Disk | wc -l) -eq 0 \
        -a $(ls /dev/disk/by-id | grep General_USB_Flash_Disk | wc -l) -eq 0 \
        -a $(ls /dev/disk/by-id | grep usb-JetFlash | wc -l) -eq 0 \
        -a $(ls /dev/disk/by-id | grep usb-USB_Mass_Storage_Device | wc -l) -eq 0 ]; then

        echo -e "${YELLOW}>> ${CORE_IMAGE}-${MACHINE}.tar.gz ${NC}"
        cd ${WORK}
        ls -ld --color build/tmp/deploy/images/${MACHINE}
        ls -l --color build/tmp/deploy/images/${MACHINE}
        echo ""
        echo -e "${YELLOW}>> all succeeded ${NC}"

        print_boot_example
        exit 0
fi

##########################################################
#
echo -e "${YELLOW}>> SD_MMC / Generic_USB_Flash_Disk / General_USB_Flash_Disk / usb-JetFlash / usb-USB_Mass_Storage_Device ${NC}"
cd ${WORK}
if [ $(ls /dev/disk/by-id | grep usb-Generic-_SD_MMC | wc -l) -ne 0 ]; then
        SDDEV=$(ls -l /dev/disk/by-id/usb-Generic-_SD_MMC* | grep -v part | awk -F '->' '{print $2}' | sed 's/ //g' | sed 's/\.//g' | sed 's/\///g')
elif [ $(ls /dev/disk/by-id | grep usb-Generic_USB_Flash_Disk | wc -l) -ne 0 ]; then
        SDDEV=$(ls -l /dev/disk/by-id/usb-Generic_USB_Flash_Disk* | grep -v part | awk -F '->' '{print $2}' | sed 's/ //g' | sed 's/\.//g' | sed 's/\///g')
elif [ $(ls /dev/disk/by-id | grep usb-General_USB_Flash_Disk | wc -l) -ne 0 ]; then
        SDDEV=$(ls -l /dev/disk/by-id/usb-General_USB_Flash_Disk* | grep -v part | awk -F '->' '{print $2}' | sed 's/ //g' | sed 's/\.//g' | sed 's/\///g')
elif [ $(ls /dev/disk/by-id | grep usb-USB_Mass_Storage_Device | wc -l) -ne 0 ]; then
        SDDEV=$(ls -l /dev/disk/by-id/usb-USB_Mass_Storage_Device_* | grep -v part | awk -F '->' '{print $2}' | sed 's/ //g' | sed 's/\.//g' | sed 's/\///g')
else
        SDDEV=$(ls -l /dev/disk/by-id/usb-JetFlash* | grep -v part | awk -F '->' '{print $2}' | sed 's/ //g' | sed 's/\.//g' | sed 's/\///g')
fi
SDDEV=/dev/${SDDEV}

##########################################################
#
echo -e "${YELLOW}>> SD_MMC fdisk ${NC}"
sudo umount ${SDDEV}1 || true
sudo umount ${SDDEV}2 || true
sudo umount ${SDDEV}3 || true
sudo umount ${SDDEV}4 || true
sudo umount ${SDDEV}5 || true
sudo umount ${SDDEV}6 || true
sudo umount ${SDDEV}7 || true
sudo umount ${SDDEV}8 || true
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo fdisk $SDDEV
 d

 d

 d

 d

 d

 d

 d

 d

 n
 p
 1

 +1024M
 n
 p
 2


 t
 1
 c
 t
 2
 83
 p
 w
 q
EOF

##########################################################
#
echo -e "${YELLOW}>> SD_MMC boot ${NC}"
echo yes | sudo mkfs.vfat -n BOOT ${SDDEV}1
sudo mount -t vfat ${SDDEV}1 mnt
sudo rm -rfv ./mnt/*
sudo /bin/cp build/tmp/deploy/images/${MACHINE}/$(ls -l build/tmp/deploy/images/${MACHINE}/Image | awk '{print $11}') mnt/Image
sudo /bin/cp build/tmp/deploy/images/${MACHINE}/r9*.dtb mnt/
sudo /bin/cp build/tmp/deploy/images/${MACHINE}/$(ls -l build/tmp/deploy/images/${MACHINE}/modules-${MACHINE}.tgz | awk '{print $11}') mnt/modules-${MACHINE}.tgz
sudo umount mnt

##########################################################
#
echo -e "${YELLOW}>> SD_MMC rootfs ${NC}"
echo yes | sudo mkfs.ext4 -E lazy_itable_init=1,lazy_journal_init=1 ${SDDEV}2 -L rootfs -U 614e0000-0000-4b53-8000-1d28000054a9 -jDv
sudo tune2fs -O ^has_journal ${SDDEV}2
sudo mount -t ext4 -O noatime,nodirame,data=writeback ${SDDEV}2 mnt
sudo rm -rfv ./mnt/*
sudo tar zxvf build/tmp/deploy/images/${MACHINE}/${CORE_IMAGE}-${MACHINE}.tar.gz -C mnt/
sudo tar zxvf build/tmp/deploy/images/${MACHINE}/modules-${MACHINE}.tgz -C mnt/
sudo sync &
(for n in $(seq 1 1440); do sleep 1 ; if [ $(grep -e Dirty: /proc/meminfo | awk '{print $2}') -lt 4096 ]; then break ; fi; done ; killall watch ;) &
watch -d -e grep -e Dirty: -e Writeback: /proc/meminfo
echo -e "${YELLOW} >> SD_MMC umount ${NC}"
sudo umount mnt
echo -e "${YELLOW} >> SD_MMC fsck ${NC}"
sudo fsck.ext4 -y ${SDDEV}2

##########################################################
#
print_boot_example
exit 0
