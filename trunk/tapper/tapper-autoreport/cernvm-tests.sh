#! /bin/bash

###################################################################
#
# This script contains several sample tests, to test the features
# and functionality of tapper, as well as to demo some sample
# tests specific to cernvm-testing
#
# The following tests are executed
#
#  - Create/configure, start, and control virtual machines
#  - CernVM TestCase 1: No error messages at boot
#  - CernVM TestCase 5: Check for correct time / running ntpd
#  - CernVM TestCase 6: Check login via ssh
#
###################################################################

. ./tapper-autoreport --import-utils

TAP[0]="ok - autoreport selftest"
#TAP[1]="ok - some other description"
#append_tap "ok - the simplest of all tests"

#HEADERS[0]="# Tapper-KVM-Version: 4.0.1"
#HEADERS[1]="# Tapper-CernVM-Changeset: 1234"
#HEADERS[2]="# Tapper-KVM-Base-OS-description: CernVM 2.3.0"

#OUTPUT[0]="I am misc output"
#OUTPUT[1]="I am put near the end"
#OUTPUT[2]="Care for me or I disappear"

TAPDATA[0]="timecpb: 12"
TAPDATA[1]="timenocpb: 15"
TAPDATA[2]="ratio: 0.8"
TAPDATA[3]="vendor: $(get_vendor)"
TAPDATA[4]="cpu_family: $(get_cpu_family)"
append_tapdata "number_of_tap_reports: $(get_tap_counter)"

main_after_hook ()
{
    valuex=17
    echo "# Be sure to review the attached files, in particular"
    echo "# the boot_error.log incase there was an error that"
    echo "# did not get caught by the tests."
}

SUITENAME="CernVM-Sample-Tests"
SUITEVERSION="1.00"
OSNAME="Debian Squeeze"
VMNAME="cernvm"
VM_XML_DEFINITION="/home/cernvm/image/cernvm.xml" # Virtual machine XML config file
CHANGESET="0"
HOSTNAME="cernvm-host"
GUESTIP="192.168.122.179"
TAPPER_REPORT_SERVER="cernvm-server"
REPORTGROUP=selftest-`date +%Y-%m-%d | md5sum | cut -d" " -f1`
NOSEND=0
NOUPLOAD=0

# A very simple test
uname -a | grep -q Linux  # example of an ok exit code
ok $? "The system is running Linux"

#
# Create/configure, start, and control virtual machines tests
#

# Verify that default network is active and set to autostart
virsh net-autostart default
virsh net-list --all | egrep -q "^default[[:space:]]*active[[:space:]]*yes"
ok $? "Verify that virtual machine NAT network is active and set to autostart"

# Verify that virtual machine domain has been created from an xml file
virsh define $VM_XML_DEFINITION
virsh list --all | grep -q $VMNAME
ok $? "Verify that virtual machine domain $VMNAME has been created from an xml file"

# Verify that virtual machine can be started and stopped
virsh start $VMNAME # Start it and wait 2 minutes for it to boot
sleep 120
virsh list --all | egrep -q "^[[:space:]]*[[:digit:]]*[[:space:]]*$VMNAME[[:space:]]*running"
ok $? "Verify that virtual machine $VMNAME has been started"
virsh shutdown $VMNAME
sleep 120	# Wait 2 minutes for virtual machine to turn off
virsh list --all | egrep -q "^[[:space:]]*-[[:space:]]*$VMNAME[[:space:]]*shut[[:space:]]off"
ok $? "Verify that virtual machine $VMNAME has been stopped"

. ./tapper-autoreport $BOOT_ERRORS
