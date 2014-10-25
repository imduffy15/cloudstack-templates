#!/usr/bin/env bash
set -e

mkimg="$(basename "$0")"

usage() {
	echo >&2 "usage: $mkimg output_directory hostname root_password disk_size script [script-args]"
	echo >&2 "   ie: $mkimg output_directory debian.cloudstack.org password 10G debootstrap --variant=minbase wheezy"
	echo >&2 "       $mkimg output_directory ubuntu.cloudstack.org password 10G debootstrap --include=ubuntu-minimal --components=main,universe trusty"
#	echo >&2 "       $mkimg output_directory centos.cloudstack.org password 10G rinse --distribution centos-6"
	exit 1
}

scriptDir="$(dirname "$(readlink -f "$BASH_SOURCE")")/mkimage"

script="$6"
[ "$script" ] || usage

OUTPUT_DIRECTORY=${1}
HOSTNAME=${2}
ROOT_PASSWORD=${3}
DISK_SIZE=${4}
PACKAGES=${5}
shift 6

if [ ! -x "$scriptDir/$script" ]; then
	echo >&2 "error: $script does not exist or is not executable"
	echo >&2 "  see $scriptDir for possible scripts"
	exit 1
fi

# don't mistake common scripts like .febootstrap-minimize as image-creators
if [[ "$script" == .* ]]; then
	echo >&2 "error: $script is a script helper, not a script"
	echo >&2 "  see $scriptDir for possible scripts"
	exit 1
fi

# Create a virtual disk
VIRTUAL_DISK="/tmp/$(basename $0).$$.tmp"
qemu-img create -f raw ${VIRTUAL_DISK} ${DISK_SIZE}

# pass all remaining arguments to $script
"$scriptDir/$script" "${HOSTNAME}" "${ROOT_PASSWORD}" "${VIRTUAL_DISK}" "${PACKAGES}" "$@"
rc=$?
if [[ ${rc} != 0 ]] ; then
    exit ${rc}
fi

TIMESTAMP=$(date +"%s")

cd ${OUTPUT_DIRECTORY}

# Create KVM Image
qemu-img convert -o compat=0.10 -c -f raw ${VIRTUAL_DISK} -O qcow2 debian-kvm-${TIMESTAMP}.qcow2
bzip2 debian-kvm-${TIMESTAMP}.qcow2

# Create VMware Image
qemu-img convert -f raw ${VIRTUAL_DISK} -O vmdk debian-vmware-${TIMESTAMP}.vmdk
bzip2 debian-vmware-${TIMESTAMP}.vmdk

# Create HyperV Image
qemu-img convert -f raw ${VIRTUAL_DISK} -O vpc debian-hyperv-${TIMESTAMP}.vhd
zip debian-hyperv.vhd-${TIMESTAMP}.zip debian-hyperv-${TIMESTAMP}.vhd
rm debian-hyperv-${TIMESTAMP}.vhd

# Create XenServer image
vhd-util convert -s 0 -t 1 -i ${VIRTUAL_DISK} -o stagefixed-${TIMESTAMP}.vhd
faketime '2010-01-01' vhd-util convert -s 1 -t 2 -i stagefixed-${TIMESTAMP}.vhd -o debian-xen-${TIMESTAMP}.vhd
rm *.bak
bzip2 debian-xen-${TIMESTAMP}.vhd

# Delete the raw virtual disk
rm -rf ${VIRTUAL_DISK}