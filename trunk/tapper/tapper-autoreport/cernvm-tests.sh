#! /bin/bash

# =============================================================================
#
# cernvm-tests.sh
# -----------------
#
# This script contains several sample tests, to test the features
# and functionality of tapper, as well as to demo some sample
# tests specific to cernvm-testing
#
# The following tests are executed
#
#
#	Precondition Test 1 - Verify that virtual machine NAT network is active and 
#						  set to autostart
#	Precondition Test 2 - Verify that virtual machine domain has been created 
#						  from an xml file
#	Precondition Test 3 - Verify that virtual machine can be started
#	Precondition Test 4 - Verify that virtual machine has been stopped
#	Precondition Test 5 - Verify that the virtual has console support
#	Precondition Test 6 - Verify that virtual machine has web interface support
#	Precondition Test 7 - Verify that it is possible to login on web interface
#						  
#
#
#  	CernVM Test Case 1 - No error messages at boot
#  	CernVM Test Case 2 - Check for correct time / running ntpd
#  	CernVM Test Case 3 - Check login via ssh
#	CernVM Test Case 4 - Create a new user using the CernVM web interface
#	CernVM Test Case 5 - Verify that the user is created and can be accessed
#						 from ssh login
#	CernVM Test Case 6 - Restart through the web interface and check that there
#						 are no error messages at boot
#
# =============================================================================

. ./tapper-autoreport --import-utils
. ./web-interface
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
OSNAME="Red Hat 5"
VMNAME="cernvm"
VM_XML_DEFINITION="/home/CernVM/IMAGES/kvm/cernvm.xml" # Virtual machine XML config file
CHANGESET="0"
HOSTNAME="cernvm-redhat5-host"
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


# Precondition Test 6 - Verify that virtual machine has web interface support
curl -i -v http://192.168.122.252:8004/login > web_interface.log 2>&1

# Check that curl didn't have any error return codes, then verify that the
# page is actually the CernVM web interface
RESULT=1
if [ "$?" -eq 0 ]
then
	if grep -q -e "CernVM Software Appliance" web_interface.log ; test "$?" -eq 0 \
	&& grep -q -e '<body id="page-login">' web_interface.log ; test "$?" -eq 0
	then
		RESULT=0
	fi
fi

ok $RESULT "Precondition Test 6 - Verify that virtual machine has web interface support"
add_file web_interface.log


# Precondition Test 7 - Verify that it is possible to login on web interface
curl -i -v --cookie cjar --cookie-jar cjar -H "Host: 192.168.122.252:8004" -H "User-Agent: Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.17) Gecko/20110428 Fedora/3.6.17-1.fc13 Firefox/3.6.17" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" -H "Accept-Language: en-us,en;q=0.5" -H "Accept-Encoding: gzip,deflate" -H "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7" -H "Keep-Alive: 115" -H "Connection: keep-alive" -H "Referer: http://192.168.122.252:8004/login" -H "Content-Type: application/x-www-form-urlencoded" --data "user_name=admin" --data "password=VM4l1f3" --data "login=Login" --location-trusted http://192.168.122.252:8004/login > web_interface_login.log 2>&1

# Check that curl didn't have any error return codes, then verify that it was
# was possible to login on web interface by validating that curl was redirected
# to the status page
RESULT=1
if [ "$?" -eq 0 ]
then
	if grep -q -e "Location: http://192.168.122.252:8004/status/Status/" web_interface_login.log ; \
	test "$?" -eq 0 && grep -q -e '<title>CernVM Software Appliance - Appliance Status</title>' \
	web_interface_login.log ; test "$?" -eq 0
	then
		RESULT=0
	fi
fi

ok $RESULT "Precondition Test 7 - Verify that it is possible to login on web interface"
add_file web_interface_login.log


# CernVM Test Case 1 - Check login via ssh as root
check_ssh root $GUESTIP
ok $? "CernVM Test Case 1 - Check login via ssh as root"


# CernVM Test Case 2 - No error messages at boot
check_boot_error $GUESTIP $BOOT_ERRORS
ok $? "CernVM Test Case 2 - No error messages at boot"
add_file $BOOT_ERRORS


# CernVM Test Case 3 - Check for correct time / running ntpd
check_time $GUESTIP
ok $? "CernVM Test Case 3 - Check for correct time / running ntpd"


# CernVM Test Case 4 - Create a new user using the CernVM web interface
curl -i -v --cookie cjar --cookie-jar cjar -H "Host: 192.168.122.252:8004" -H "User-Agent: Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.17) Gecko/20110428 Fedora/3.6.17-1.fc13 Firefox/3.6.17" -H "Accept: application/json" -H "Accept-Language: en-us,en;q=0.5" -H "Accept-Encoding: gzip,deflate" -H "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7" -H "Keep-Alive: 115" -H "Connection: keep-alive" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -H "Referer: http://192.168.122.252:8004/cernvm/User/" -H "Pragma: no-cache" -H "Cache-Control: no-cache" --data "cernvmUser=todd" --data "cernvmUserGroup=alice" --data "cernvmUserShell=%2Fbin%2Fbash" --data "newpass1=testing123" --data "newpass2=testing123" --location-trusted http://192.168.122.252:8004/cernvm/User/userUpdate > web_interface_newuser.log 2>&1

ok $? "CernVM Test Case 4 - Create a new user using the CernVM web interface"
add_file web_interface_newuser.log


#	CernVM Test Case 5 - Verify that the user is created and can be accessed
#						 from ssh login
check_ssh todd $GUESTIP
ok $? "CernVM Test Case 5 - Verify that the user is created and can be accessed \
from ssh login"


#	CernVM Test Case 6 - Restart through the web interface and check that there
#						 are no error messages at boot
curl -i -v --cookie cjar --cookie-jar cjar -H "Host: 192.168.122.252:8004" -H "User-Agent: Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.17) Gecko/20110428 Fedora/3.6.17-1.fc13 Firefox/3.6.17" -H "Accept: application/json" -H "Accept-Language: en-us,en;q=0.5" -H "Accept-Encoding: gzip,deflate" -H "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7" -H "Keep-Alive: 115" -H "Connection: keep-alive" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -H "Referer: http://192.168.122.252:8004/reboot/Reboot/" -H "Pragma: no-cache" -H "Cache-Control: no-cache" --location-trusted http://192.168.122.252:8004/reboot/Reboot/rebootNow > web_interface_reboot.log 2>&1

# Check that curl didn't have any error return codes, then verify that it was
# possible to restart the 
RESULT=1
if [ "$?" -eq 0 ]
then
	if egrep -q "^\{\"message\"\:[[:space:]]*\"Rebooting[[:space:]]*now\.\"\,[[:space:]]*\"errors\"\:[[:space:]]*\[\]\,[[:space:]]*\"schedId\"\:[[:space:]]*[[:digit:]]*\}" web_interface_reboot.log ; test "$?" -eq 0
	then
		echo "PASS RESTART TEST!"
		sleep 120
		check_boot_error $GUESTIP web_restart_boot.log
		if [ "$?" -eq 0 ]
		then
			RESULT=0
		fi
	fi
fi
ok $RESULT "CernVM Test Case 6 - Restart through the web interface and check that \
there are no error messages at boot"
add_file web_interface_reboot.log
add_file web_restart_boot.log


. ./tapper-autoreport
