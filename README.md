## Introduction

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/TzaTyqkk9OA/0.jpg)](https://youtu.be/TzaTyqkk9OA)

This repository is a Linux reference software for building core-image-bsp on Renesas RZ/V2M. 
You have to get the proprietary software and hardware before building this REPO. Please contact for the following name card: 

## Block Diagram

<img src="https://renesas.info/w/images/2/29/RZV2M_EVK.jpg" />
<img src="/assets/block-rzv2m_0.png" width="600" height="480" />

## Contact

```
銳力科技股份有限公司 Regulus Technologies Co., Ltd  
2F, No.242, Yang-Guang St., Nei-Hu, Taipei 114, Taiwan, R.O.C.  
114 台北市內湖區陽光街242號2樓  
TEL : (02) 8753-3588  
FAX : (02) 8753-3589  
E-mail : sales@regulus.com.tw  
http://www.regulus.com.tw/  
```

## Quickly Deployment

##### 1. Build

```
./build.sh
```

##### 2. NFS Boot

```
=> setenv core1_vector 0x01000000
=> setenv core1addr 0x01000000
=> setenv core1_firmware core1_firmware.bin
=> setenv fdt_addr 0x58000000
=> setenv fdt_file r9a09g011gbg-evaluation-board.dtb
=> setenv kernel Image
=> setenv bootargs rw rootwait earlycon root=/dev/mmcblk1p2
=> setenv bootcmd 'fatload mmc 1:1 ${loadaddr} ${kernel}; fatload mmc 1:1 ${core1addr} ${core1_firmware}; fatload mmc 1:1 ${fdt_addr} ${fdt_file}; wakeup_a53core1 ${core1_vector}; booti ${loadaddr} - ${fdt_addr}'
=> setenv NFSROOT ${serverip}:/work/userboard-rzv2m/rootfs
=> setenv bootargs_nfs 'setenv bootargs rw rootwait root=/dev/nfs nfsroot=${NFSROOT},nfsvers=3 ip=dhcp'
=> setenv download_nfs 'nfs ${loadaddr} ${NFSROOT}/boot/${kernel}; nfs ${fdt_addr} ${NFSROOT}/boot/r9a09g011gbg-evaluation-board.dtb; nfs ${core1addr} ${NFSROOT}/boot/${core1_firmware};'
=> setenv bootnfs 'run bootargs_nfs; run download_nfs; wakeup_a53core1 ${core1_vector}; booti ${loadaddr} - ${fdt_addr}'
=> saveenv
=> run bootnfs
...
```

##### 3. EMMC update

```
./mmc_download.sh
```

##### 4. Enable the relavant service
```
systemctl enable drpai_demo.service
```

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/_iFeg2z4lCw/0.jpg)](https://youtu.be/_iFeg2z4lCw)

## RZ/V2M start-up guide

https://www.renesas.com/us/en/document/qsg/rzv2m-linux-start-guide-rev110?language=en&r=1320296

## RZ/V2M ISP support package release note

https://www.renesas.com/us/en/document/rln/rzv2m-isp-support-package-version110-release-note


## DRP-AI translator user manual

https://www.renesas.com/us/en/document/mat/drp-ai-translator-v160-user-s-manual?language=en&r=1320296


Maintainers
-------------------------

```
Jason Chang <jason.chang@regulus.com.tw>
```



