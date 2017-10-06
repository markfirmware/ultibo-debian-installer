#!/bin/bash
set -x -e

# This script implements the instructions at https://ultibo.org/wiki/Building_for_Debian
#
# It will destroy the current ultibo installation at $HOME/ulibo/core and re-install it
#

rm -rf $HOME/ultibo downloads preloads unzip

function get {
    wget --quiet -O downloads/$1.zip https://github.com/ultibohub/$1/archive/master.zip
}

mkdir -p downloads
get Core
get Examples
get FPC

# === Introduction ===
# ----
# 
# Ultibo core is currently made available as a Windows installer download as well as various Windows tools, however there is nothing specific about the source code or modifications to Free Pascal that are dependent on Windows and some may choose to use it on other platforms such as Linux or Mac. While we are currently unable to provide prepackaged installations for Linux in the form of DEB or RPM files we have created a set of instructions for building the necessary items from source in order to provide similar functionality to the Windows platform.
# 
# Please note that because these instructions require you to build all of the components from source and possibly install additional packages onto your Linux installation you should be familiar with using the command line and confident with the tools available. These instructions are fully tested and proven to work, however we cannot provide support for individual cases if you experience issues in completing the steps below.
# 
# === Prerequisites ===
# ----
# 
# The instructions below detail the process of building the modified Free Pascal compiler, the Free Pascal ARM cross compiler and the Ultibo RTL in order to create a working configuration that allows developing Ultibo applications.
# 
# This process was tested and developed using Debian Wheezy 7.6 for i386 with Linux kernel version 3.2.0 however the requirements for FreePascal are relatively simple so these instructions should work without much change on later versions of Debian (eg Jessie) and should also be able to be translated easily to many other distributions.
# 
# In order to avoid any conflict with official FPC releases these instructions install all components into a folder within your home directory, if you follow these instructions the Ultibo version of Free Pascal as well as the RTL and sources will be located in the <code>$HOME/ultibo/core</code> folder so if your username is <code>linus</code> then the installation will be at <code>/home/linus/ultibo/core</code>.
# 
# Compiling the Ultibo edition of Free Pascal requires using the official 3.0.0 release version as the starting point, these instructions will NOT work if you start with version 2.6.4 or any other version. Fortunately the FPC team provide a precompiled download of FPC 3.0.0 which can be obtained from the [http://www.freepascal.org/download.var download] page and installed using the provided instructions.
# 
# If you prefer not to install the official 3.0.0 release (you may have other projects that depend on an earlier version for example) then you can get a fully working installation of Free Pascal 3.0.0 by following the instructions at [http://www.getlazarus.org/setup/?download#linux GetLazarus.org] which will by default install a working copy in the folder <code>$HOME/Development/FreePascal</code> that can be deleted later if you choose.
# 

apt-get update && apt-get -y install lazarus && fpc -i


# === Building Free Pascal (Ultibo Edition) ===
# ----
# 
# Assuming you have a working FPC 3.0.0 installation as discussed above, you can now proceed with the first stage of the process which is to build a Debian native version of the Ultibo edition of FPC.
# 
# These instructions assume that FPC 3.0.0 from the official download was installed to:
# 
#  /usr/local/bin/fpc
# 
# If you are using the GetLazarus.org version instead then you will need to temporarily add it to the path so it is used in preference to any official version, by default you can do something like this to add the appropriate folder to the path temporarily:
# 
#  export PATH=$HOME/Development/FreePascal/fpc/bin:$PATH
# 
# 
# You should now download the sources of the FPC Ultibo edition from [https://github.com/ultibohub/FPC GitHub] and unzip the contents to the folder:
# 
#  $HOME/ultibo/core
# 
# After extracting the files rename the folder <code>FPC-master</code> to <code>fpc</code> so the contents of the zip will be in <code>$HOME/ultibo/core/fpc</code>
# 
# 
# Now download the source of Ultibo core from [https://github.com/ultibohub/Core GitHub] and extract the <code>ultibo</code> folder to the location:
# 
#  $HOME/ultibo/core/fpc/source/rtl
# 
# And extract the <code>ultibounits</code> folder to the location:
# 
#  $HOME/ultibo/core/fpc/source/packages
# 
# And finally extract the <code>units</code> folder to the location:
# 
#  $HOME/ultibo/core/fpc
# 

apt-get -y install unzip
mkdir -p unzip
unzip -q downloads/Core.zip     -d unzip
unzip -q downloads/Examples.zip -d unzip
unzip -q downloads/FPC.zip      -d unzip
mkdir -p $HOME/ultibo/core
mv unzip/FPC-master \
       $HOME/ultibo/core/fpc
mv unzip/Core-master/source/rtl/ultibo \
       $HOME/ultibo/core/fpc/source/rtl
mv unzip/Core-master/source/packages/ultibounits \
       $HOME/ultibo/core/fpc/source/packages/ultibounits
mv unzip/Core-master/units \
       $HOME/ultibo/core/fpc/units

# 
# Once this is done, open a terminal window and change to the folder containing the Ultibo sources:
# 
#  cd $HOME/ultibo/core/fpc/source
# 

pushd $HOME/ultibo/core/fpc/source


# Do the following steps in order, checking that each was completed successfully before continuing:
# 
#  make distclean
# 
#  make all OS_TARGET=linux CPU_TARGET=i386
# 
#  make install OS_TARGET=linux CPU_TARGET=i386 INSTALL_PREFIX=$HOME/ultibo/core/fpc
# 

make distclean

make all OS_TARGET=linux CPU_TARGET=x86_64

make install OS_TARGET=linux CPU_TARGET=x86_64 INSTALL_PREFIX=$HOME/ultibo/core/fpc

# Once those steps have completed you should now have a Debian native version of the FPC Ultibo edition. Copy it to the <code>bin</code> directory as follows so we can find it later:
# 
#  cp $HOME/ultibo/core/fpc/source/compiler/ppc386 $HOME/ultibo/core/fpc/bin/ppc386
# 

cp $HOME/ultibo/core/fpc/source/compiler/ppcx64 $HOME/ultibo/core/fpc/bin/ppcx64

# Run the following to check that it shows as version 3.1.1 and lists <code>ultibo</code> under the supported targets.
# 
#  $HOME/ultibo/core/fpc/bin/fpc -i 
# 

$HOME/ultibo/core/fpc/bin/fpc -i 

# Use fpcmkcfg to create our default configuration file like this:
# 
#  $HOME/ultibo/core/fpc/bin/fpcmkcfg -d basepath=$HOME/ultibo/core/fpc/lib/fpc/3.1.1 -o $HOME/ultibo/core/fpc/bin/fpc.cfg
# 

$HOME/ultibo/core/fpc/bin/fpcmkcfg -d basepath=$HOME/ultibo/core/fpc/lib/fpc/3.1.1 -o $HOME/ultibo/core/fpc/bin/fpc.cfg

# === Installing the arm-none-eabi Toolchain ===
# ----
# 
# A toolchain that provides various utilities for the ARM embedded development is needed so that applications can be cross compiled from i386 to ARM. There are many different options available but for the purpose of Ultibo we need a toolchain that is built for arm-none-eabi and the one shown below is known to work correctly.
# 
# Download the file <code>gcc-arm-none-eabi-5_4-2016q3-20160926-linux.tar.bz2</code> from [https://launchpad.net/gcc-arm-embedded/+download launchpad.net] and save it to a temporary location.
# 
# Extract the contents of the file to the folder <code>$HOME/gcc-arm-none-eabi-5_4-2016q3</code> and then run the following commands from a terminal window:
# 
#  cp $HOME/gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/as $HOME/ultibo/core/fpc/bin/arm-ultibo-as
#  cp $HOME/gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/ld $HOME/ultibo/core/fpc/bin/arm-ultibo-ld
#  cp $HOME/gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/objcopy $HOME/ultibo/core/fpc/bin/arm-ultibo-objcopy
#  cp $HOME/gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/objdump $HOME/ultibo/core/fpc/bin/arm-ultibo-objdump
#  cp $HOME/gcc-arm-none-eabi-5_4-2016q3/arm-none-eabi/bin/strip $HOME/ultibo/core/fpc/bin/arm-ultibo-strip
# 

popd

tar zxf preloads.tgz
cp preloads/arm-none-eabi/bin/as      $HOME/ultibo/core/fpc/bin/arm-ultibo-as && \
cp preloads/arm-none-eabi/bin/ld      $HOME/ultibo/core/fpc/bin/arm-ultibo-ld && \
cp preloads/arm-none-eabi/bin/objcopy $HOME/ultibo/core/fpc/bin/arm-ultibo-objcopy && \
cp preloads/arm-none-eabi/bin/objdump $HOME/ultibo/core/fpc/bin/arm-ultibo-objdump && \
cp preloads/arm-none-eabi/bin/strip   $HOME/ultibo/core/fpc/bin/arm-ultibo-strip

# If you like you can now delete the extracted folder because none of the other files it contains are needed for Ultibo.
# 
# === Building the FPC ARM Cross Compiler ===
# ----
# 
# Now we need to build a cross compiler that runs under Linux on i386 but outputs code for Ultibo on ARM, this will be the copy of the compiler that we use to build Ultibo applications but we need to use the native compiler we created above to build this one first.
# 
# Open a new terminal window (NOT the one you used above !!) and change to the <code>source</code> folder
# 
#  cd $HOME/ultibo/core/fpc/source
# 

pushd $HOME/ultibo/core/fpc/source

# Export the path to our FPC 3.1.1 Ultibo edition:
# 
#  export PATH=$HOME/ultibo/core/fpc/bin:$PATH
# 

export PATH=$HOME/ultibo/core/fpc/bin:$PATH

# Build the ARM cross compiler using these commands, make sure you check that each step was successful before continuing:
# 
#  make distclean OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a BINUTILSPREFIX=arm-ultibo- FPCOPT="-dFPC_ARMHF" CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/ppc386
# 
#  make all OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a BINUTILSPREFIX=arm-ultibo- FPCOPT="-dFPC_ARMHF" CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/ppc386
# 
#  make crossinstall BINUTILSPREFIX=arm-ultibo- FPCOPT="-dFPC_ARMHF" CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPC=$HOME/ultibo/core/fpc/bin/ppc386 INSTALL_PREFIX=$HOME/ultibo/core/fpc
# 
# Now copy our cross compiler to the <code>bin</code> directory as follows so we can find it later:
# 
#  cp $HOME/ultibo/core/fpc/source/compiler/ppcrossarm $HOME/ultibo/core/fpc/bin/ppcrossarm
# 

apt-get -y install libc6-i386

make distclean OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a BINUTILSPREFIX=arm-ultibo- FPCOPT="-dFPC_ARMHF" CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/ppcx64

make all OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a BINUTILSPREFIX=arm-ultibo- FPCOPT="-dFPC_ARMHF" CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/ppcx64

make crossinstall BINUTILSPREFIX=arm-ultibo- FPCOPT="-dFPC_ARMHF" CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPC=$HOME/ultibo/core/fpc/bin/ppcx64 INSTALL_PREFIX=$HOME/ultibo/core/fpc

cp $HOME/ultibo/core/fpc/source/compiler/ppcrossarm $HOME/ultibo/core/fpc/bin/ppcrossarm

popd

# === Building the Ultibo RTL ===
# ----
# 
# The Ultibo RTL comes in 2 versions, one for ARMv6 which works on the Raspberry Pi A/B/A+/B+/Zero and another for ARMv7 which only works on Raspberry Pi 2B and 3B. These instructions allow for both to exist in different folders so you can have both versions available. If you choose not to build one or the other simply skip the relevant steps, you will need to perform this process each time you download an updated copy of the Ultibo RTL.
# 
# 
# '''Ultibo RTL for ARMv7'''
# 
# Open a new terminal window (Better NOT to continue with the one you used earlier) and change to the <code>source</code> folder
# 
#  cd $HOME/ultibo/core/fpc/source
# 
# Export the path to our FPC 3.1.1 Ultibo edition:
# 
#  export PATH=$HOME/ultibo/core/fpc/bin:$PATH
# 
# Build the ARMv7 RTL as follows, checking that each step was successful before continuing:
# 
#  make rtl_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc
# 
#  make rtl OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc
# 
#  make rtl_install CROSSINSTALL=1 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPC=$HOME/ultibo/core/fpc/bin/fpc INSTALL_PREFIX=$HOME/ultibo/core/fpc INSTALL_UNITDIR=$HOME/ultibo/core/fpc/units/armv7-ultibo/rtl
# 
# 

pushd $HOME/ultibo/core/fpc/source

make rtl_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc

make rtl OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc

make rtl_install CROSSINSTALL=1 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPC=$HOME/ultibo/core/fpc/bin/fpc INSTALL_PREFIX=$HOME/ultibo/core/fpc INSTALL_UNITDIR=$HOME/ultibo/core/fpc/units/armv7-ultibo/rtl

# '''Packages for ARMv7'''
# 
# Open a new terminal or continue with the one used to build the RTL, change to the <code>source</code> folder and ensure the path is updated:
# 
#  cd $HOME/ultibo/core/fpc/source
# 
#  export PATH=$HOME/ultibo/core/fpc/bin:$PATH
# 
# Build the ARMv7 Packages using the following commands:
# 
#  make rtl_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc
# 
#  make packages_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc
# 
#  make packages OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH -Fu$HOME/ultibo/core/fpc/units/armv7-ultibo/rtl" FPC=$HOME/ultibo/core/fpc/bin/fpc
# 
#  make packages_install CROSSINSTALL=1 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPC=$HOME/ultibo/core/fpc/bin/fpc INSTALL_PREFIX=$HOME/ultibo/core/fpc INSTALL_UNITDIR=$HOME/ultibo/core/fpc/units/armv7-ultibo/packages
# 
# 

make rtl_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc

make packages_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc

make packages OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH -Fu$HOME/ultibo/core/fpc/units/armv7-ultibo/rtl" FPC=$HOME/ultibo/core/fpc/bin/fpc

make packages_install CROSSINSTALL=1 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV7A -CfVFPV3 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv7a FPC=$HOME/ultibo/core/fpc/bin/fpc INSTALL_PREFIX=$HOME/ultibo/core/fpc INSTALL_UNITDIR=$HOME/ultibo/core/fpc/units/armv7-ultibo/packages

popd

# '''Ultibo RTL for ARMv6'''
# 
# The process for the ARMv6 RTL is very similar but there are many differences in the parameters, careful you don't use the wrong ones.
# 
# Open a new terminal window and change to the <code>source</code> folder
# 
#  cd $HOME/ultibo/core/fpc/source
# 
# Export the path to our FPC 3.1.1 Ultibo edition:
# 
#  export PATH=$HOME/ultibo/core/fpc/bin:$PATH
# 
# Build the ARMv6 RTL as follows, checking that each step was successful before continuing:
# 
#  make rtl_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc
# 
#  make rtl OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc
# 
#  make rtl_install CROSSINSTALL=1 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPC=$HOME/ultibo/core/fpc/bin/fpc INSTALL_PREFIX=$HOME/ultibo/core/fpc INSTALL_UNITDIR=$HOME/ultibo/core/fpc/units/armv6-ultibo/rtl
# 
# 

pushd $HOME/ultibo/core/fpc/source

make rtl_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc

make rtl OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc

make rtl_install CROSSINSTALL=1 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPC=$HOME/ultibo/core/fpc/bin/fpc INSTALL_PREFIX=$HOME/ultibo/core/fpc INSTALL_UNITDIR=$HOME/ultibo/core/fpc/units/armv6-ultibo/rtl

# '''Packages for ARMv6'''
# 
# Open a new terminal or continue with the one used to build the RTL, change to the <code>source</code> folder and ensure the path is updated:
# 
#  cd $HOME/ultibo/core/fpc/source
# 
#  export PATH=$HOME/ultibo/core/fpc/bin:$PATH
# 
# Build the ARMv6 Packages as follows:
# 
#  make rtl_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc
# 
#  make packages_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc
# 
#  make packages OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH -Fu$HOME/ultibo/core/fpc/units/armv6-ultibo/rtl" FPC=$HOME/ultibo/core/fpc/bin/fpc
# 
#  make packages_install CROSSINSTALL=1 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPC=$HOME/ultibo/core/fpc/bin/fpc INSTALL_PREFIX=$HOME/ultibo/core/fpc INSTALL_UNITDIR=$HOME/ultibo/core/fpc/units/armv6-ultibo/packages
# 

make rtl_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc

make packages_clean CROSSINSTALL=1 OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" FPC=$HOME/ultibo/core/fpc/bin/fpc

make packages OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH -Fu$HOME/ultibo/core/fpc/units/armv6-ultibo/rtl" FPC=$HOME/ultibo/core/fpc/bin/fpc

make packages_install CROSSINSTALL=1 FPCFPMAKE=$HOME/ultibo/core/fpc/bin/fpc CROSSOPT="-CpARMV6 -CfVFPV2 -CIARM -CaEABIHF -OoFASTMATH" OS_TARGET=ultibo CPU_TARGET=arm SUBARCH=armv6 FPC=$HOME/ultibo/core/fpc/bin/fpc INSTALL_PREFIX=$HOME/ultibo/core/fpc INSTALL_UNITDIR=$HOME/ultibo/core/fpc/units/armv6-ultibo/packages

popd

# === Creating the Configuration files ===
# ----
# 
# To allow switching between ARMv6 and ARMv7 the Ultibo installation includes configuration files that are passed to FPC to specify certain parameters for each model, you can easily create these for Debian as well like this.
# 
# Open a terminal window and change to the location where FPC Ultibo edition is installed:
# 
#  cd $HOME/ultibo/core/fpc/bin
# 

pushd $HOME/ultibo/core/fpc/bin

# Create a new <code>rpi.cfg</code> file:
# 
#  nano rpi.cfg
# 
# And paste these lines into the file, you need to change the word <code><user></code> to be your actual username (eg <code>linus</code>):
# 
#  #
#  # Raspberry Pi (A/B/A+/B+/Zero) specific config file
#  #
#  -CfVFPV2
#  -CIARM
#  -CaEABIHF
#  -OoFASTMATH
#  -Fu/home/<user>/ultibo/core/fpc/units/armv6-ultibo/rtl
#  -Fu/home/<user>/ultibo/core/fpc/units/armv6-ultibo/packages
#  -Fl/home/<user>/ultibo/core/fpc/units/armv6-ultibo/lib
#  -Fl/home/<user>/ultibo/core/fpc/units/armv6-ultibo/lib/vc4
# 
# 
# Save the file and do the same for the <code>rpi2.cfg</code>, <code>rpi3.cfg</code> and <code>qemuvpb.cfg</code> files, remember to replace <code><user></code> with your username:
# 

cat <<__EOF__ > rpi.cfg
#
# Raspberry Pi (A/B/A+/B+/Zero) specific config file
#
-CfVFPV2
-CIARM
-CaEABIHF
-OoFASTMATH
-Fu$HOME/ultibo/core/fpc/units/armv6-ultibo/rtl
-Fu$HOME/ultibo/core/fpc/units/armv6-ultibo/packages
-Fl$HOME/ultibo/core/fpc/units/armv6-ultibo/lib
-Fl$HOME/ultibo/core/fpc/units/armv6-ultibo/lib/vc4
__EOF__


# Contents of rpi2.cfg
# 
#  #
#  # Raspberry Pi 2B specific config file
#  #
#  -CfVFPV3
#  -CIARM
#  -CaEABIHF
#  -OoFASTMATH
#  -Fu/home/<user>/ultibo/core/fpc/units/armv7-ultibo/rtl
#  -Fu/home/<user>/ultibo/core/fpc/units/armv7-ultibo/packages
#  -Fl/home/<user>/ultibo/core/fpc/units/armv7-ultibo/lib
#  -Fl/home/<user>/ultibo/core/fpc/units/armv7-ultibo/lib/vc4
# 
# 

cat <<__EOF__ > rpi2.cfg
#
# Raspberry Pi 2B specific config file
#
-CfVFPV3
-CIARM
-CaEABIHF
-OoFASTMATH
-Fu$HOME/ultibo/core/fpc/units/armv7-ultibo/rtl
-Fu$HOME/ultibo/core/fpc/units/armv7-ultibo/packages
-Fl$HOME/ultibo/core/fpc/units/armv7-ultibo/lib
-Fl$HOME/ultibo/core/fpc/units/armv7-ultibo/lib/vc4
__EOF__

# Contents of rpi3.cfg
# 
#  #
#  # Raspberry Pi 3B specific config file
#  #
#  -CfVFPV3
#  -CIARM
#  -CaEABIHF
#  -OoFASTMATH
#  -Fu/home/<user>/ultibo/core/fpc/units/armv7-ultibo/rtl
#  -Fu/home/<user>/ultibo/core/fpc/units/armv7-ultibo/packages
#  -Fl/home/<user>/ultibo/core/fpc/units/armv7-ultibo/lib
#  -Fl/home/<user>/ultibo/core/fpc/units/armv7-ultibo/lib/vc4
# 
# 

cat <<__EOF__ > rpi.cfg
#
# Raspberry Pi 3B specific config file
#
-CfVFPV3
-CIARM
-CaEABIHF
-OoFASTMATH
-Fu$HOME/ultibo/core/fpc/units/armv7-ultibo/rtl
-Fu$HOME/ultibo/core/fpc/units/armv7-ultibo/packages
-Fl$HOME/ultibo/core/fpc/units/armv7-ultibo/lib
-Fl$HOME/ultibo/core/fpc/units/armv7-ultibo/lib/vc4
__EOF__

# Contents of qemuvpb.cfg
# 
#  #
#  # QEMU VersatilePB specific config file
#  #
#  -CfVFPV3
#  -CIARM
#  -CaEABIHF
#  -OoFASTMATH
#  -Fu/home/<user>/ultibo/core/fpc/units/armv7-ultibo/rtl
#  -Fu/home/<user>/ultibo/core/fpc/units/armv7-ultibo/packages
#  -Fl/home/<user>/ultibo/core/fpc/units/armv7-ultibo/lib
# 

cat <<__EOF__ > qemuvpb.cfg
#
# QEMU VersatilePB specific config file
#
-CfVFPV3
-CIARM
-CaEABIHF
-OoFASTMATH
-Fu$HOME/ultibo/core/fpc/units/armv7-ultibo/rtl
-Fu$HOME/ultibo/core/fpc/units/armv7-ultibo/packages
-Fl$HOME/ultibo/core/fpc/units/armv7-ultibo/lib
__EOF__

popd

# === Compiling an Application ===
# ----
# 
# Compiling an application from the command line is quite simple, you just need to remember some extra parameters because of the different environment. To compile something like the Hello World example open a terminal window, change to the folder where the application is located and add the path to FPC 3.1.1 Ultibo edition like this:
# 
#  export PATH=$HOME/ultibo/core/fpc/bin:$PATH
# 
# Then compile the application using this command:
# 
#  fpc -B -Tultibo -Parm -CpARMV7A -WpRPI2B @$HOME/ultibo/core/fpc/bin/rpi2.cfg -O2 HelloWorld.lpr
# 
# This example is for a Raspberry Pi 2B but can easily be adjusted for any other model by changing the appropriate parameters, so to compile for Raspberry Pi B instead try this:
# 
#  fpc -B -Tultibo -Parm -CpARMV6 -WpRPIB @$HOME/ultibo/core/fpc/bin/rpi.cfg -O2 HelloWorld.lpr
# 
# Or for a Raspberry Pi 3B use this one:
# 
#  fpc -B -Tultibo -Parm -CpARMV7A -WpRPI3B @$HOME/ultibo/core/fpc/bin/rpi3.cfg -O2 HelloWorld.lpr
# 
# And for the QEMU target the command line looks like this:
# 
#  fpc -B -Tultibo -Parm -CpARMV7A -WpQEMUVPB @$HOME/ultibo/core/fpc/bin/qemuvpb.cfg -O2 HelloWorld.lpr
# 
