#!/usr/bin/env bash

PROJECT_DIR=`pwd`
BUILD_NUMBER=$(date +%Y%m%d%H%M%S)

# Create a build direcctory with current date and time.
BUILD_NUMBER=$(date +%Y%m%d%H%M%S)
mkdir -p ${PROJECT_DIR}/${BUILD_NUMBER}

LOGFILE=${PROJECT_DIR}/${BUILD_NUMBER}/BUILDLOG-${BUILD_NUMBER}.log

exec >> $LOGFILE 2>&1

cd ${PROJECT_DIR}/${BUILD_NUMBER}

# Disk Image Builder Environment Settings
#
export ELEMENTS_PATH=/usr/local/share/ironic-python-agent-builder/dib
export DIB_DEV_USER_USERNAME=ampere
export DIB_DEV_USER_PWDLESS_SUDO=yes
#export DIB_DEV_USER_AUTHORIZED_KEYS=$HOME/.ssh/id_rsa.pub
export DIB_DEV_USER_PASSWORD=ampere
export CRYPTOGRAPHY_DONT_BUILD_RUST=1
export ARCH=arm64
export DIB_PYTHON=python3
export DIB_PYTHON_VERSION=3
export IPA_PYTHON=python3
export IPA_PYTHON_VERSION=3

export DIB_INSTALLTYPE_pip_and_virtualenv="package"
export DIB_REPOREF_ironic_python_agent=origin/stable/victoria
#export DIB_REPOREF_ironic_python_agent=origin/stable/ussuri
#export DIB_REPOREF_ironic_python_agent=origin/stable/train
export DIB_RELEASE=testing
#export DIB_RELEASE=stable
export DIB_BOOTLOADER_DEFAULT_CMDLINE="nofb nomodeset gfxpayload=text net.ifnames=0 biosdevname=0 module_blacklist=ib_core"

#export DIB_APT_MINIMAL_CREATE_INTERFACES=1
#export DIB_NETWORK_INTERFACE_NAMES="enp1s0f0np0 enp1s0f1np1"

echo "ELEMENTS_PATH = " $ELEMENTS_PATH
echo "DIB_DEV_USERNAME = " $DIB_DEV_USER_USERNAME
echo "DIB_DEV_USER_PWDLESS_SUDO = " $DIB_DEV_USER_PWDLESS_SUDO
echo "DIB_DEV_USER_PASSWORD = " $DIB_DEV_USER_PASSWORD
echo "CRYPTOGRAPHY_DONT_BUILD_RUST = " $CRYPTOGRAPHY_DONT_BUILD_RUST
echo "ARCH = " $ARCH
echo "IPA_PYTHON = " $IPA_PYTHON
echo "IPA_PYTHON_VERSION = " $IPA_PYTHON_VERSION
echo "DIB_REPOREF_ironic_python_agent = " $DIB_REPOREF_ironic_python_agent
echo "DIB_RELEASE = " $DIB_RELEASE
echo "DIB_BOOTLOADER_DEFAULT_CMDLINE = " $DIB_BOOTLOADER_DEFAULT_CMDLINE
echo "DIB_APT_MINIMAL_CREATE_INTERFACES = " $DIB_APT_MINIMAL_CREATE_INTERFACES
echo "DIB_NETWORK_INTERFACE_NAMES = " $DIB_NETWORK_INTERFACE_NAMES
echo "DIB__INSTALLTYPE_pip_and_virtualenv = " $DIB_INSTALLTYPE_pip_and_virtualenv

#ironic-python-agent-builder -e devuser debian
ironic-python-agent-builder -e devuser -e debian-systemd -e dhcp-all-interfaces -e mellanox debian
#ironic-python-agent-builder -e devuser -e dhcp-all-interfaces -e simple-init -e mellanox debian
#ironic-python-agent-builder centos
#disk-image-create debian ironic-python-agent-ramdisk devuser

sha256sum ironic-python-agent.kernel ironic-python-agent.initramfs > ${PROJECT_DIR}/${BUILD_NUMBER}/SHA256-${BUILD_NUMBER}.txt
tar -cvzf ironic_deploy_image_${BUILD_NUMBER}.tgz ${PROJECT_DIR}/${BUILD_NUMBER}/*.*
