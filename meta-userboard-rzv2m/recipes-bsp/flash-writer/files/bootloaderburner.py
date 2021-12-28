#!/usr/bin/env python3

import serial
import sys

sport = ""
if len(sys.argv) > 1:
    sport = sys.argv[1]

flasherfile = "AArch64_RZV2M_Flash_writer.mot"

flasherinittext = b"Flash writer for RZ/V2M"
sectreqtext = b"Please Input Start Address in sector"
sizreqtext = b"Please Input File size"

#inputtext = b" Please Input : H'"
#flasherwaittext = b"please send !"
flasherreadytext = b">"
sendrequesttext = b"please send"

bootloadermap = [
    {"area": "1", "sector": "0", "siz": "20000", "file": "loader_1st_128kb.bin"},
    {"area": "1", "sector": "100", "siz": "8", "file": "loader_2nd_param.bin"},
    {"area": "1", "sector": "101", "siz": "32E20", "file": "loader_2nd.bin"},
    {"area": "1", "sector": "901", "siz": "8", "file": "u-boot_param.bin"},
    {"area": "1", "sector": "902", "siz": "7F149", "file": "u-boot.bin"},
]

if len(sport) == 0:
    sport = "/dev/ttyUSB0"

print("RZG2 flash writer helper started.")
sp = serial.Serial(sport, 115200, timeout=0.5)
if sp is None:
    print("Failed to open serial port %s!" % sport)
    exit()

print("Open serial port %s successfully." % sport)

###########################################################
print("Waiting for download mode prompt ...")
while True:
    rdata = sp.read(8192)
    if flasherinittext in rdata:
        break

###########################################################
print('Download mode detected.')
print("")
#print('Sending %s ...' % flasherfile)
sp.write(b'\r\n')
while True:
    rdata = sp.read(4096)
    if flasherreadytext in rdata:
        break
sspeed = 115200
print("")
print("Flash burner ready, baudrate = %d. " % sspeed)

###########################################################
sp.close()
sp = serial.Serial(sport, sspeed, timeout=0.5)

sp.write(b'\r\n')
while True:
    rdata = sp.read(4096)
    if flasherreadytext in rdata:
        break

###########################################################
print("EM_E")
sequences = [0,1,2]
for i in sequences:
    sp.write(b'EM_E\r\n')
    while True:
        rdata = sp.read(4096)
        if flasherreadytext in rdata:
            break
    sp.write(b"%d\r\n" % i)
    while True:
        rdata = sp.read(4096)
        if flasherreadytext in rdata:
            break
    print(" %d erase completed. " % i)
print("")

###########################################################
for i in range(0, (len(bootloadermap) - 0)):
    print("EM_WB: %s         " % bootloadermap[i]['file'])
    sp.write(b'EM_WB\r\n')
    while True:
        rdata = sp.read(8192)
        if flasherreadytext in rdata:
            break
    print(" AREA: %s " % bootloadermap[i]['area'])
    sp.write(b'1\r\n')
    #cmd = str("%s\r\n" % bootloadermap[i]['area'])
    #sp.write(cmd.encode())
    while True:
        rdata = sp.read(8192)
        if sectreqtext in rdata:
            break
    print(" SECTOR: %s " % bootloadermap[i]['sector'])
    cmd = str("%s\r\n" % bootloadermap[i]['sector'])
    sp.write(cmd.encode())
    while True:
        rdata = sp.read(8192)
        if sizreqtext in rdata:
            break
    print(" SIZ: %s " % bootloadermap[i]['siz'])
    cmd = str("%s\r\n" % bootloadermap[i]['siz'])
    sp.write(cmd.encode())
    while True:
        rdata = sp.read(8192)
        if sendrequesttext in rdata:
            break
    f = open(bootloadermap[i]['file'], "rb")
    tlen = 0
    while True:
        fdata = f.read(8192)
        fdatalen = len(fdata)
        if fdatalen == 0:
            break;
        sp.write(fdata)
        tlen += fdatalen
        print('\r%d bytes completed.\r' % tlen, end='')
    f.close()
    #sp.write(b'.\r\n')
    while True:
        rdata = sp.read(8192)
        if flasherreadytext in rdata:
            break
    sp.write(b'\r\n')
    while True:
        rdata = sp.read(8192)
        if flasherreadytext in rdata:
            break
    print("")
    print("")

sp.close()
print("All succeeded. ")
exit()

