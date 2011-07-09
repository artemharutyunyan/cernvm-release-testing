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
#
#
# Precondition Tests 
# ------------------
#
# Precondition tests are required preconditions that must pass for
# the results of test cases to be accurate
#
#
# Precondition Test - Verify that the download page exists and that there is a 
#					  valid download url for the CernVM image specified, returns
#					  the url to download the image

# 	Precondition Test   - Download and extract the CernVM image, returns the location 
#					  	 of the extracted cernvm image file
#
# 	Precondition Test   - Create an XML definition file for the virtual machine based
#						 on the template XML definition file and settings defined and
#						 return the location of the final xml defintion file



#	Precondition Test 1  - Verify that the virtual machine XML definition file exists
#
#	Precondition Test 2  - Verify that the XML definition file provided is valid
#
# 	Precondition Test 3  - Verify that the mandatory configuration settings for the
#						 virtual machine XML definition file have been provided
#						 and are valid
#
# 	Precondition Test 4  - Verify that the hypervisor for the current virtual machine
#						 tested is accessible, set the URI as a global variable
#
# 	Precondition Test 5  - Verify that virtual machine NAT network is active and 
#						 set to autostart
#
# 	Precondition Test 6 - Verify that virtual machine domain has been created 
#						from an xml file
#
#	Precondition Test 7	 - Verify that virtual machine can be started
#
#	Precondition Test 8  - Verify that virtual machine has been stopped
#
#	Precondition Test 9  - Verify that the virtual has console support
#
#	Precondition Test 10 - Verify that virtual machine has web interface support
#
#	Precondition Test 11 - Verify that it is possible to login on web interface
#						  
#
#
# CernVM Tests Cases
# ------------------
#
# CernVM test cases are the actual test cases for testing CernVM images, the
# following is a list of the available CernVM test cases, please refer to the
# test suite developer manual for more detailed information about each test,
# including an API reference for each test case
#
#
#	CernVM Test Case 2 - Check login via ssh as root
#
#  	CernVM Test Case 3 - No error messages at boot
#
#  	CernVM Test Case 4 - Check for correct time / running ntpd
#
#	CernVM Test Case 5 - Create a new user using the CernVM web interface
#
#	CernVM Test Case 6 - Verify that the user is created and can be accessed
#						 from ssh login
#
#	CernVM Test Case 7 - Restart through the web interface and check that there
#						 are no error messages at boot
#
# =============================================================================

. ./tapper-autoreport --import-utils
. ./general-interface
. ./virt-interface
. ./web-interface
. ./cernvm-preconditions
. ./cernvm-testcases

TAP[0]="ok - autoreport selftest"
#TAP[1]="ok - some other description"
#append_tap "ok - the simplest of all tests"

HEADERS[0]="# Tapper-KVM-Version: 4.0.1"
HEADERS[1]="# Tapper-CernVM-Changeset: 1234"
HEADERS[2]="# Tapper-KVM-Base-OS-description: CernVM 2.3.0"

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

TEMPLATE_DIR="$(pwd)/templates"
IMAGES_DIR="/usr/share/images"		# Root directory for cernvm images
IMAGE_FOLDER="$IMAGES_DIR/vmware" # Image directory for current hypervisor
SUITENAME="CernVM-VMware-Tests"
SUITEVERSION="1.00"
TAPPER_REPORT_SERVER="cernvm-debian6-server"
DOWNLOAD_PAGE="http://cernvm.cern.ch/releases/releases.cgi"
#IMAGE_URL="http://arch-server/cernvm-2.3.0-x86_64.vmware.tar.gz"
IMAGE_URL=""
HASH_URL="http://arch-server/cernvm-2.3.0-x86_64.vmware.md5"
HYPERVISOR="vmware"
IMAGE_VERSION="2.4.0"
IMAGE_TYPE="desktop"	# Currently only basic and desktop supported


OSNAME="Fedora 13"
VM_XML_DEFINITION=""	# The location and name of the virtual machine definition file
VM_NAME="cernvm-vmware-2.3.0"
VM_CPUS="1"
VM_ARCH="x86"
VM_MEMORY=""
CERNVM_IMAGE=""		# The location and name of the CernVM image file
CHANGESET="0"
HOSTNAME="fedora13-vmware-host"
GUESTIP="192.168.1.139"

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

# Precondition Test - Verify that the download page exists and that there is a 
#					  valid download url for the CernVM image specified, returns
#					  the url to download the image
# @param $1 - The CernVM download page url
# @param $2 - The image version
# @param $3 - The hypervisor of the image
# @param $4	- The architecture of the image
# @param $5 - The type of image
IMAGE_URL=$(image_url $DOWNLOAD_PAGE $IMAGE_VERSION $HYPERVISOR $VM_ARCH $IMAGE_TYPE)
ok $? "Precondition Test - Verify that the download page exists and that there is a \
valid download url for the CernVM image specified, returns the url to download the image"


# Precondition Test 1  - Download and extract the CernVM image, returns the location 
#					  	 of the extracted cernvm image file
CERNVM_IMAGE=$(download_extract $IMAGE_URL $IMAGE_FOLDER cernvm_image_download.log)
ok $? "Precondition Test 1 - Download and extract the CernVM image"

# Precondition Test 2  - Create an XML definition file for the virtual machine based on 
#				       the template XML definition file and settings provided
# @param $1	The template file to use
# @param $2 The directory to save the final xml definition file in 
VM_XML_DEFINITION=$(create_def cernvm-vmware.xml $IMAGES_DIR)
ok $? "Precondition Test 2 - Create an XML definition file for the virtual machine \
based on the template XML definition file and settings provided"



# Precondition Test 1  - Verify that the virtual machine XML definition file exists
file_exists $VM_XML_DEFINITION
ok $? "Precondition Test 1  - Verify that the virtual machine XML definition file exists"


# Precondition Test 2  - Verify that the XML definition file provided is valid
validate_def_xml $VM_XML_DEFINITION
ok $? "Precondition Test 2  - Verify that the XML definition file provided is valid"


# Precondition Test 3  - Verify that the mandatory configuration settings for the
#						 virtual machine XML definition file have been provided and are valid
validate_def_settings $VM_XML_DEFINITION
ok $? "Precondition Test 3  - Verify that the mandatory configuration settings for the \
virtual machine XML definition file have been provided and are valid"


# Precondition Test 4  - Verify that the hypervisor for the current virtual machine
#						 tested is accessible, set the URI as a global variable
verify_hypervisor $VM_XML_DEFINITION
ok $? "Precondition Test 4  - Verify that the hypervisor for the current virtual machine \
tested is accessible, set the URI as a global variable"


# Precondition Test 5  - Verify that virtual machine NAT network is active and 
#						 set to autostart
verify_vm_net default
ok $? "Precondition Test 5  - Verify that virtual machine NAT network is active and \
set to autostart"


# Precondition Test 6 - Verify that virtual machine domain has been created 
#						from an xml file
create_vm $VM_XML_DEFINITION $VMNAME
ok $? "Precondition Test 6 - Verify that virtual machine domain $VMNAME has been \
created from an xml file"

# Precondition Test 7 - Verify that virtual machine can be started
start_vm $VMNAME
ok $? "Precondition Test 7 - Verify that virtual machine $VMNAME has been started"

# Precondition Test 8 - Verify that virtual machine $VMNAME has been stopped
stop_vm $VMNAME
ok $? "Precondition Test 8 - Verify that virtual machine $VMNAME has been stopped"

# Precondition Test 9 - Verify that the virtual machine has console support
# Start the virtual machine and verify that it has console support
start_vm $VMNAME
has_console_support $VMNAME
ok $? "Precondition Test 9 - Verify that virtual machine $VMNAME has console support"

# Precondition Test 10 - Verify that virtual machine has web interface support
has_web_interface $GUESTIP web_interface.log
ok $? "Precondition Test 10 - Verify that virtual machine $VMNAME has web interface support"
add_file web_interface.log

# Precondition Test 11 - Verify that it is possible to login on web interface
web_check_login $GUESTIP admin VM4l1f3 web_interface_login.log
ok $? "Precondition Test 11 - Verify that it is possible to login on web interface"
add_file web_interface_login.log



#
# CernVM Test Cases
# Execute CernVM image specific Test Cases
#

# CernVM Test Case 2 - Check login via ssh as root
check_ssh root $GUESTIP
ok $? "CernVM Test Case 2 - Check login via ssh as root"


# CernVM Test Case 3 - No error messages at boot
check_boot_error $GUESTIP $BOOT_ERRORS
ok $? "CernVM Test Case 3 - No error messages at boot"
add_file $BOOT_ERRORS


# CernVM Test Case 4 - Check for correct time / running ntpd
check_time $GUESTIP
ok $? "CernVM Test Case 4 - Check for correct time / running ntpd"


# CernVM Test Case 5 - Create a new user using the CernVM web interface
web_create_user $GUESTIP gnuuser VM4l1f3 web_interface_newuser.log
ok $? "CernVM Test Case 5 - Create a new user using the CernVM web interface"
add_file web_interface_newuser.log


# CernVM Test Case 6 - Verify that the user is created and can be accessed
#					   from ssh login
check_ssh todd $GUESTIP
ok $? "CernVM Test Case 6 - Verify that the user is created and can be accessed \
from ssh login"


# CernVM Test Case 7 - Restart through the web interface and check that there
#					   are no error messages at boot
web_restart $GUESTIP web_interface_reboot.log web_restart_boot.log
ok $? "CernVM Test Case 7 - Restart through the web interface and check that \
there are no error messages at boot"
add_file web_interface_reboot.log
add_file web_restart_boot.log


. ./tapper-autoreport
