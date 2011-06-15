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
. ./virt-interface
. ./cernvm-testcases

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
OSNAME="Fedora 13"
VMNAME="cernvm"
VM_XML_DEFINITION="/home/cernvm/image/cernvm.xml" # Virtual machine XML config file
CHANGESET="0"
HOSTNAME="cernvm-fedora13-host"
GUESTIP="192.168.122.252"
TAPPER_REPORT_SERVER="cernvm-debian6-server"
REPORTGROUP=selftest-`date +%Y-%m-%d | md5sum | cut -d" " -f1`
BOOT_ERRORS="boot_error.log"
NOSEND=0
NOUPLOAD=0

# A very simple test
uname -a | grep -q Linux  # example of an ok exit code
ok $? "The system is running Linux"

#
# CernVM Precondition Tests
# Create/configure, start, and control virtual machines tests
#

# Precondition Test 1 - Verify that virtual machine NAT network is active and 
#						set to autostart
set_default_net
ok $? "Precondition Test 1 - Verify that virtual machine NAT network is active \
and set to autostart"

# Precondition Test 2 - Verify that virtual machine domain has been created 
#						from an xml file
create_vm $VM_XML_DEFINITION $VMNAME
ok $? "Precondition Test 2 - Verify that virtual machine domain $VMNAME has been \
created from an xml file"

# Precondition Test 3 - Verify that virtual machine can be started
start_vm $VMNAME
ok $? "Precondition Test 3 - Verify that virtual machine $VMNAME has been started"

# Precondition Test 4 - Verify that virtual machine $VMNAME has been stopped
stop_vm $VMNAME
ok $? "Precondition Test 4 - Verify that virtual machine $VMNAME has been stopped"

# Precondition Test 5 - Verify that the virtual has console support
# Start the virtual machine and verify that it has console support
start_vm $VMNAME
has_console_support $VMNAME
ok $? "Precondition Test 5 - Verify that virtual $VMNAME has console support"


# CernVM TestCase 1 - Check login via ssh as root
check_ssh root $GUESTIP
ok $? "CernVM Test Case 1 - Check login via ssh as root"

# CernVM TestCase 2 - No error messages at boot
check_boot_error $GUESTIP $BOOT_ERRORS
ok $? "CernVM Test Case 2 - No error messages at boot"

# CernVM TestCase 3 - Check for correct time / running ntpd
check_time $GUESTIP
ok $? "CernVM Test Case 3 - Check for correct time / running ntpd"

. ./tapper-autoreport $BOOT_ERRORS
