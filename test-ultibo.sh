#!/bin/bash
set -x -e

export PATH=$HOME/ultibo/core/fpc/bin:$PATH

pushd unzip/Examples-master/01-HelloWorld/RPi2
fpc -B -Tultibo -Parm -CpARMV7A -WpRPI2B @$HOME/ultibo/core/fpc/bin/rpi2.cfg -O2 HelloWorld.lpr
popd

pushd unzip/Examples-master/VideoCoreIV/HelloPi/HelloAudio/RPi2
fpc -B -Tultibo -Parm -CpARMV7A -WpRPI2B @$HOME/ultibo/core/fpc/bin/rpi2.cfg -O2 HelloAudio.lpr
popd

