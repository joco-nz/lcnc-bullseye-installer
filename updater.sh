#!/bin/bash

export SUDO_ASKPASS=`pwd`/sudo_helper.sh

# Ask the user if they want to install a developer version of qtpyvcp
zenity --question --text="Is this a USER or DEVELOPER install?" --no-wrap --ok-label="USER" --cancel-label="DEVELOPER"
DEVELOPER=$?
# Developer = 1 for DEVELOPER install
# Developer = 0 for USER install


# Ask the user if they want to install a developer version of qtpyvcp
zenity --question --text="UPDATE linuxcnc 2.9-pre Yes or No?" --no-wrap --ok-label="yes" --cancel-label="no"
CHOICE=$?
if [ $CHOICE -eq 0 ]
then
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
	./configure no-docs
	cd ~/dev/linuxcnc/rip/
	dpkg-buildpackage -b -uc

	# install the deb files
	cd ~/dev/linuxcnc/
	sudo -A dpkg -i linuxcnc-uspace_2.9.0~pre0_amd64.deb
	#sudo -A dpkg -i linuxcnc-doc-en_2.9.0~pre0_all.deb
fi

if [ $DEVELOPER -eq 1 ]
then
	# get qtpyvcp
	echo "Updating Qtpyvcp"
	cd ~/dev/qtpyvcp
	git pull

	# determine if PB is installed and if is installed, update
	if [ -d ~/dev/probe_basic ]
	then
		echo "Updating Probe Basic and Conversational"
		cd ~/dev/probe_basic
		git pull
		qcompile .
		
		cd ~/dev/qtpyvcp.conversational-gcode
		git pull
	fi
fi
