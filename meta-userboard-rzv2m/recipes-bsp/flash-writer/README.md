## `RZ/V2M EMMC flash writer helper` Overview

<img src="/assets/emmc_flash_writer_helper.png" />

As the picture displayed above, the `RZ/V2M EMMC flash writer helper` can help quickly program the `loader_1st_128kb.bin`, `loader_2nd_param.bin`, `loader_2nd.bin`, `u-boot_param.bin`, and `u-boot.bin` for the `RZ/V2M Evaluation Kit` board. 

### Steps for the `RZ/V2M EMMC flash writer helper`

#### 1. Change to the deploy folder
```
cd build/tmp/deploy/images/rzv2m
```

#### 2. Write the flash writer to the eMMC
Store the Flash writer binary (`B2_intSW.bin`) in a micro-SDHC Card that has 1 partition formatted with FAT32.
Insert the micro-SD card into the micro-SD card slot on the RZ/V2M Evaluation Kit.
Set the Main SW2 on the `RZ/V2M Evaluation Kit` is as the following table to change the board operation mode to "forced write mode".

|  SW1  |  SW2  |  SW3  |  SW4  |
| ----- | ----- | ----- | ----- |
|  OFF  |  OFF  |  OFF  |  ON   |

#### 3. Start the flash writer
Set the Main SW2 on the RZ/V2M Evaluation Kit is as the following table to change the board operation mode to "normal mode".

|  SW1  |  SW2  |  SW3  |  SW4  |
| ----- | ----- | ----- | ----- |
|  OFF  |  OFF  |  OFF  |  OFF  |

Power on the RZ/V2M Evaluation Kit. The following log will appear if RZ/V2M starts in normal mode and run Flash writer successfully.

```
Flash writer for RZ/V2M V1.00 Jul 9, 2021
>
```

#### 4. Write loader binaries to eMMC with Flash writer

```
sudo ./emmc_flash_writer_helper
```

#### 5. Confirm booting by the boot loader and U-boot
Power on the `RZ/V2M Evaluation Kit` with the normal mode. And then, confirm that the boot loader and U-boot run normally. 


### Quickly Deployment

#### 1. Build all

```
./build.sh
```

#### 2. NFS boot
```
```


