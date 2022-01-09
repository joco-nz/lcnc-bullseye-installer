#!/bin/bash

export SUDO_ASKPASS=`pwd`/sudo_helper.sh

# update linuxcnc
cd ~/dev/linuxcnc/rip
git pull
# set up the build locations for self build
CPUS=`nproc`
cd ~/dev/linuxcnc/rip/src/
make clean
./autogen.sh
./configure --with-realtime=uspace
make -j$CPUS

sudo -A make setuid

# make the deb files
cd ~/dev/linuxcnc/rip/debian/
./configure uspace
cd ~/dev/linuxcnc/rip/
dpkg-buildpackage -b -uc

# install the deb files
cd ~/dev/linuxcnc/
sudo -A dpkg -i linuxcnc-uspace_2.9.0~pre0_amd64.deb
sudo -A dpkg -i linuxcnc-doc-en_2.9.0~pre0_all.deb

# get qtpyvcp
cd ~/dev/qtpyvcp
git pull
python3 -m pip install --editable .
