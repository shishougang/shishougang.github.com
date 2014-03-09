---
layout: post
title: "Install Xilinx ISE on the Ubuntu"
date: 2012-09-12 20:44
comments: true
categories: [Software, FPGA]
tags: Xilinx ISE 
---

## Download Xilinx ISE
Official site: http://www.xilinx.com/support/download/index.htm

Choose `Full Installer for Linux`
<!-- more -->

## Install

``` bash Install
cd the folder
untar the archives
sudo chmod +x xsetup
sudo ./xsetup
```
* Just use the default install path: `/opt/Xilinx`
* Uncheck `Install cable drivers`(if checked, it will pop the error info below, just click `OK`.
{% codeblock Xilinx Software Steup lang:bash %}
Driver installation failed. Please check the /.xinstall/install.log file for
...
{% endcodeblock %}

The details of the `/.xinstall/install.log` will be

``` bash install.log
--Installing windrvr6---------------------------------------------
--Checking version.
--File /lib/modules/2.6.32-42-generic-pae/kernel/drivers/misc/windrvr6.o does not exist.
--File LINUX.2.6.32-42-generic-pae.i386/windrvr6.o does not exist.
--Setting source version to 1301.
--File LINUX.2.6.32-42-generic-pae.i386/windrvr6.o is newer than the destination file.
USE_KBUILD = yes
creating cache ./config.cache
checking for cpu architecture... i386
checking for WinDriver root directory... /opt/Xilinx/14.2/ISE_DS/common/bin/lin/install_script/install_drivers/linux_drivers/windriver32
checking for linux kernel source... found at /lib/modules/2.6.32-42-generic-pae/build
not found
loading cache ./config.cache
checking for cpu architecture... i386
checking for WinDriver root directory... /opt/Xilinx/14.2/ISE_DS/common/bin/lin/install_script/install_drivers/linux_drivers/windriver32
checking for linux kernel source... found at /lib/modules/2.6.32-42-generic-pae/build
not found
make -f makefile.usb.kbuild clean
make[1]: Entering directory `/opt/Xilinx/14.2/ISE_DS/common/bin/lin/install_script/install_drivers/linux_drivers/windriver32/windrvr'
make[1]: Leaving directory `/opt/Xilinx/14.2/ISE_DS/common/bin/lin/install_script/install_drivers/linux_drivers/windriver32/windrvr'
make -f makefile.usb.kbuild
make[1]: Entering directory `/opt/Xilinx/14.2/ISE_DS/common/bin/lin/install_script/install_drivers/linux_drivers/windriver32/windrvr'
make[1]: Leaving directory `/opt/Xilinx/14.2/ISE_DS/common/bin/lin/install_script/install_drivers/linux_drivers/windriver32/windrvr'
make -f makefile.usb.kbuild
make[1]: Entering directory `/opt/Xilinx/14.2/ISE_DS/common/bin/lin/install_script/install_drivers/linux_drivers/windriver32/windrvr'
make[1]: Leaving directory `/opt/Xilinx/14.2/ISE_DS/common/bin/lin/install_script/install_drivers/linux_drivers/windriver32/windrvr'
--make windrvr install rc= 2
--install_windrvr6 rc = 2
--Module windrvr6 is not running.
--Module xpc4drvr is not running.
--Note: By default, the file permission of /dev/windrvr6 is enabled for the root user only
  and must be changed to allow access to other users.

--real rc=2

--Driver installation failed.

--Digilent Return code = 0
--Xilinx Return code = 1
--Return code = 1
```
* The Xilinx License Configuration Manager appears and configure
* Finish

## Installing Cable Drivers
* install the prerequisite

``` bash install 
On 32-bit
sudo apt-get install gitk git-gui libusb-dev build-essential libc6-dev fxload 
On 64-bit
sudo apt-get install gitk git-gui libusb-dev build-essential libc6-dev-i386 fxload
```

* Download the driver source and install

``` bash download and install
cd /opt/Xilinx 
sudo git clone git://git.zerfleddert.de/usb-driver

cd usb-driver/ 
On 32-bit
sudo make 
On 64-bit
sudo make lib32
```

## Setup up the driver

``` bash setup up
$ ./setup_pcusb /opt/Xilinx/13.2/ISE_DS/ISE/
Looking for USB cable files: /opt/Xilinx/14.2/ISE_DS/ISE/bin/lin
Copying firmware to /usr/share:
`/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin/xusbdfwu.hex' -> `/usr/share/xusbdfwu.hex'
`/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin/xusb_emb.hex' -> `/usr/share/xusb_emb.hex'
`/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin/xusb_xlp.hex' -> `/usr/share/xusb_xlp.hex'
`/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin/xusb_xp2.hex' -> `/usr/share/xusb_xp2.hex'
`/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin/xusb_xpr.hex' -> `/usr/share/xusb_xpr.hex'
`/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin/xusb_xse.hex' -> `/usr/share/xusb_xse.hex'
`/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin/xusb_xup.hex' -> `/usr/share/xusb_xup.hex'
Installing udev rules:
done
```

## Setting the ISE

``` bash Setting 
cd /opt/Xilinx/14.2/ISE_DS
bash ./settings32.sh 
. /opt/Xilinx/14.2/ISE_DS/common/.settings32.sh /opt/Xilinx/14.2/ISE_DS/common
. /opt/Xilinx/14.2/ISE_DS/EDK/.settings32.sh /opt/Xilinx/14.2/ISE_DS/EDK
. /opt/Xilinx/14.2/ISE_DS/common/CodeSourcery/.settings32.sh /opt/Xilinx/14.2/ISE_DS/common/CodeSourcery
. /opt/Xilinx/14.2/ISE_DS/PlanAhead/.settings32.sh /opt/Xilinx/14.2/ISE_DS/PlanAhead
. /opt/Xilinx/14.2/ISE_DS/../../Vivado/2012.2/.settings32.sh /opt/Xilinx/14.2/ISE_DS/../../Vivado/2012.2
. /opt/Xilinx/14.2/ISE_DS/ISE/.settings32.sh /opt/Xilinx/14.2/ISE_DS/ISE
. /opt/Xilinx/14.2/ISE_DS/../../Vivado_HLS/2012.2/.settings32.sh /opt/Xilinx/14.2/ISE_DS/../../Vivado_HLS/2012.2
```
## Restart udev

``` bash Restart udev
/etc/init.d/boot.udev restart
```


## Fixing the Path

``` bash Fixing the Path
32-bit
echo "PATH=\$PATH:/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin" >> ~/.bashrc echo "export PATH" >> ~/.bashrc 
64-bit
echo "PATH=\$PATH:/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin64/" >> ~/.bashrc echo "export PATH" >> ~/.bashrc
```
## Run the IMPACK to check everything

<p class="warning"> Errors </p>
If it appears:

``` bash Errors
INFO:iMPACT - Selected Current Working Directory:
   '/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin'
libusb couldn't open USB device /dev/bus/usb/002/035: Permission denied.
libusb requires write access to USB device nodes.
```
* First check there is `/etc/udev/rules.d/xusbdfwu.rules`
* Restart udev `/etc/init.d/boot.udev restart`
* Still wrong, reboot and try again.

## Reference
	http://www.george-smart.co.uk/wiki/Xilinx_JTAG_Linux

	http://git.zerfleddert.de/cgi-bin/gitweb.cgi/usb-driver?a=blob_plain;f=README;hb=HEAD
