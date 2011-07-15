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
# 	Precondition Test 0  - Verify that the download page exists and that there is a 
#					  	   valid download url for the CernVM image specified, returns
#					  	   the url to download the image
#
# 	Precondition Test 1  - Download and extract the CernVM image, returns the location 
#					  	   of the extracted cernvm image file
#
# 	Precondition Test 2  - Create an XML definition file for the virtual machine based
#						   on the template XML definition file and settings defined and
#						   return the location of the final xml defintion file
#
#	Precondition Test 3	 - Verify that the virtual machine XML definition file exists
#
#	Precondition Test 4	 - Verify that the XML definition file provided is valid
#
# 	Precondition Test 5	 - Verify that the mandatory configuration settings for the
#						   virtual machine XML definition file have been provided
#						   and are valid
#
# 	Precondition Test 6  - Verify that the hypervisor for the current virtual machine
#						   tested is accessible, set the URI as a global variable
#
# 	Precondition Test 7  - Create an XML definition file for the virtual machine network
#					  	   based on the template network XML definition file and settings 
#					  	   defined and return the location of the created xml defintion file
#
#	Precondition Test 8	 - Verify that the network XML definition file exists
#
#	Precondition Test 9	 - Verify that the network XML definition file provided is valid
#
# 	Precondition Test 10 - Verify that the mandatory configuration settings for the
#						   network XML definition file have been provided
#						   and are valid
#
# 	Precondition Test 11 - Verify that the virtual machine network has been created 
#					  	   from an xml file
#
# 	Precondition Test 12 - Verify that virtual machine NAT network is active and 
#						   set to autostart
#
# 	Precondition Test 13 - Verify that virtual machine domain has been created 
#						   from an xml file
#
#	Precondition Test 14 - Verify that virtual machine can be started
#
#	Precondition Test 15 - Verify that virtual machine has been stopped
#
#	Precondition Test 16 - Verify that the virtual has console support
#
#	Precondition Test 17 - Verify that virtual machine has web interface support
#
#	Precondition Test 18 - Verify that it is possible to login on web interface
#
# 	Precondition Test 19 - Setup and configure the initial CernVM image through the
#					  	   web interface
#
# 	Precondition Test 20 - Enable automatic SSH login to the machine for the user
#					       specified using keys instead of passwords, and verify that it
#					       is possible to login automatically
#
# 	Precondition Test 21 - Set the root password using the CernVM web interface
#
# 	Precondition Test 22 - Enable automatic SSH login to the machine for the root
#					       user using keys instead of passwords, and verify that it
#					       is possible to login automatically
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
#	CernVM Test Case 1 - Check login via ssh as user created through web interface
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
HEADERS[2]="# Tapper-KVM-Base-OS-description: CernVM 2.4.0"

OUTPUT[0]="Please review the attached files"
OUTPUT[1]="for more information about"
OUTPUT[2]="test failures"

TAPDATA[0]="timecpb: 12"
TAPDATA[1]="timenocpb: 15"
TAPDATA[2]="ratio: 0.8"
TAPDATA[3]="vendor: $(get_vendor)"
TAPDATA[4]="cpu_family: $(get_cpu_family)"
append_tapdata "number_of_tap_reports: $(get_tap_counter)"


######## DEFAULT CONFIGURATIONS ##########
###
### MOST OF THESE SETTINGS SHOULD NOT BE CHANGED UNLESS SPECIFIED
###

TEMPLATE_DIR="$(pwd)/templates"
IMAGES_DIR="/usr/share/images"		# Root directory for cernvm images
SUITEVERSION="1.00"
DOWNLOAD_PAGE="http://cernvm.cern.ch/releases/releases.cgi"
IMAGE_URL=""						# Leave blank, url to download CernVM image
IMAGE_TYPE="desktop"				# Currently only basic and desktop supported
CERNVM_IMAGE=""						# Leave blank, location of the CernVM image file
VM_XML_DEFINITION=""				# Leave blank, the virtual machine definition file
NET_XML_DEFINITION=""				# Leave blank, the network definition file
IP_ADDRESS="" 						# DO NOT TOUCH, SPECIFYING CUSTOM IP ADDRESSES IS NOT SUPPORTED YET
REPORTGROUP=selftest-`date +%Y-%m-%d | md5sum | cut -d" " -f1`
NOSEND=0
NOUPLOAD=0

###
###
###
######## DEFAULT CONFIGURATIONS ##########



######## MANDATORY CONFIGURATIONS ##########
###
### ALL OF THESE SETTINGS MUST BE SET FOR SCRIPT TO FUNCTION
###

TAPPER_REPORT_SERVER="" 		# Mandatory, Tapper server hostname/ip to send reports to
TEMPLATE="cernvm-vbox.xml"		# Mandatory, the template file in the templates folder for the hypervisor
NET_TEMPLATE="vbox-network.xml"	# Mandatory, the network template file, only applies to kvm/virtualbox
HYPERVISOR="vbox"				# Mandatory, valid hypervisors are vmware,vbox,kvm
IMAGE_VERSION="2.4.0"			# Mandatory, version to download
VM_UUID=$(uuid)					# Mandatory, must be set as valid uuid
NET_UUID=$(uuid)				# Mandatory, must be set as valid uuid
VM_ARCH="x86_64"				# Mandatory, valid architectures are x86 and x86_64

### Web interface and initial CernVM image configuration settings
###
###	ALL OF THE FOLLOWING MUST BE SET
###
#
# The web inteface administration account settings, which should 
# not have to be modified unless web-interface defaults change
ADMIN_USERNAME="admin"
ADMIN_DEFAULT_PASS="password"
ADMIN_PASS="VM4l1f3"

# CernVM image user settings, specify the settings for new account
USER_NAME="alice"
USER_PASS="VM4l1f3"
USER_GROUP="alice"

# CernVM image root account settings, specify password for root account
ROOT_PASS="VM4l1f3"

# CernVM image desktop settings
STARTXONBOOT="on"		# Start X on boot, either "on" or "off"
RESOLUTION="1024x768"	# CernVM image desktop resolution
KEYBOARD_LOCALE="us"	# CernVM image keyboard locale

# CernVM image primary group (experiment) settings
EXPERIMENT_GROUP="ALICE" # Group name, should be all capitals

###
###
###
######## MANDATORY CONFIGURATIONS ##########



######## OPTIONAL CONFIGURATIONS ##########
###
### 
###

SUITENAME="CernVM-VirtualBox-Tests"	# Change this for different hypervisor tests
OSNAME="Fedora 13"					# Change this accordingly
CHANGESET="0"
HOSTNAME="fedora13-vbox-host"

# Set the image download location based on virtual machine settings
IMAGE_FOLDER="$IMAGES_DIR/$HYPERVISOR/$IMAGE_VERSION/$VM_ARCH"

### Optional virtual machine settings, best to leave as default
VM_NAME="cernvm-vbox-2.4.0"			# Virtual machine name, optional
VM_CPUS="1"
VM_MEMORY=""

### Optional virtual machine network settings, best to leave as default
NET_NAME=""

### Optional CernVM Test Case settings, best to leave as default as they do not
### have any affect on the testing
USER_NAME2="bob"
USER_PASS2="R00tM3"

###
###
###
######## OPTIONAL CONFIGURATIONS ##########




main_after_hook ()
{
    valuex=17
    echo "# Be sure to review the attached files, in particular"
    echo "# the boot_error.log incase there was an error that"
    echo "# did not get caught by the tests."
}


# A very simple test
uname -a | grep -q Linux  # example of an ok exit code
ok $? "The system is running Linux"


#
# CernVM Precondition Tests
# Create/configure, start, and control virtual machines tests
#


# Precondition Test 0 - Verify that the download page exists and that there is a 
#					  valid download url for the CernVM image specified, returns
#					  the url to download the image
IMAGE_URL=$(image_url $DOWNLOAD_PAGE $IMAGE_VERSION $HYPERVISOR $VM_ARCH $IMAGE_TYPE)
ok $? "Precondition Test 0 - Verify that the download page exists and that there is a \
valid download url for the CernVM image specified, returns the url to download the image"


# Precondition Test 1 - Download and extract the CernVM image, returns the location 
#					  	of the extracted cernvm image file
CERNVM_IMAGE=$(download_extract $IMAGE_URL $IMAGE_FOLDER cernvm_image_download.log)
ok $? "Precondition Test 1 - Download and extract the CernVM image"


# Precondition Test 2 - Create an XML definition file for the virtual machine based on 
#				        the template XML definition file and settings provided
VM_XML_DEFINITION=$(create_def $TEMPLATE $IMAGE_FOLDER)
ok $? "Precondition Test 2 - Create an XML definition file for the virtual machine \
based on the template XML definition file and settings provided"


# Precondition Test 3  - Verify that the virtual machine XML definition file exists
verify_exists ${VM_XML_DEFINITION}
ok $? "Precondition Test 3  - Verify that the virtual machine XML definition file exists"


# Precondition Test 4  - Verify that the XML definition file provided is valid
validate_def_xml ${VM_XML_DEFINITION}
ok $? "Precondition Test 4  - Verify that the XML definition file provided is valid"


# Precondition Test 5  - Verify that the mandatory configuration settings for the
#						 virtual machine XML definition file have been provided and are valid
validate_def_settings ${VM_XML_DEFINITION}
ok $? "Precondition Test 5  - Verify that the mandatory configuration settings for the \
virtual machine XML definition file have been provided and are valid"


# Precondition Test 6  - Verify that the hypervisor for the current virtual machine
#						 tested is accessible, set the URI as a global variable
verify_hypervisor ${VM_XML_DEFINITION}
ok $? "Precondition Test 6  - Verify that the hypervisor for the current virtual machine \
tested is accessible, set the URI as a global variable"


# Precondition Test 7 - Create an XML definition file for the virtual machine network
#					    based on the template network XML definition file and settings defined
NET_XML_DEFINITION=$(create_net_def $NET_TEMPLATE $IMAGE_FOLDER)
ok $? "Precondition Test 7 - Create an XML definition file for the virtual machine network \
based on the template network XML definition file and settings defined"


# Precondition Test 8 - Verify that the network XML definition file exists
verify_exists ${NET_XML_DEFINITION}
ok $? "Precondition Test 8 - Verify that the network XML definition file exists"


# Precondition Test 9 - Verify that the network XML definition file provided is valid
validate_def_xml ${NET_XML_DEFINITION}
ok $? "Precondition Test 9 - Verify that the network XML definition file provided is valid"


# Precondition Test 10 - Verify that the mandatory configuration settings for the
#						 network XML definition file have been provided and are valid
validate_net_settings ${NET_XML_DEFINITION}
ok $? "Precondition Test 10 - Verify that the mandatory configuration settings for the \
network XML definition file have been provided and are valid"


# Set the network name and IP address from the network xml definition file
NET_NAME=$(get_net_name ${NET_XML_DEFINITION})
IP_ADDRESS=$(get_ip_address ${NET_XML_DEFINITION})


# Precondition Test 11 - Verify that the virtual machine network has been created 
#					  	 from an xml file
create_net ${NET_XML_DEFINITION} ${NET_NAME}
ok $? "Precondition Test 11 - Verify that the virtual machine network has been \
created from an xml file"


# Precondition Test 12  - Verify that virtual machine network is active and 
#						 set to autostart
verify_vm_net ${NET_NAME}
ok $? "Precondition Test 12  - Verify that virtual machine NAT network is active and \
set to autostart"


# Precondition Test 13 - Verify that virtual machine domain has been created 
#						from an xml file
create_vm ${VM_XML_DEFINITION} $VM_NAME
ok $? "Precondition Test 13 - Verify that virtual machine domain $VMNAME has been \
created from an xml file"


# Precondition Test 14 - Verify that virtual machine can be started
start_vm $VM_NAME
ok $? "Precondition Test 14 - Verify that virtual machine $VMNAME has been started"


# Precondition Test 15 - Verify that virtual machine $VMNAME has been stopped
stop_vm $VM_NAME
ok $? "Precondition Test 15 - Verify that virtual machine $VMNAME has been stopped"


# Precondition Test 16 - Verify that the virtual machine has console support
# Start the virtual machine and verify that it has console support
start_vm $VM_NAME
has_console_support $VM_NAME
ok $? "Precondition Test 16 - Verify that virtual machine $VMNAME has console support"


# Precondition Test 17 - Verify that virtual machine has web interface support
web_check_interface ${IP_ADDRESS} web_interface.log
ok $? "Precondition Test 17 - Verify that virtual machine $VMNAME has web interface support"
add_file web_interface.log


# Precondition Test 18 - Verify that it is possible to login on web interface
web_check_login ${IP_ADDRESS} $ADMIN_USERNAME $ADMIN_DEFAULT_PASS web_interface_login.log
ok $? "Precondition Test 18 - Verify that it is possible to login on web interface"
add_file web_interface_login.log


# Precondition Test 19 - Setup and configure the initial CernVM image through the
#					  web interface
configure_image_web ${IP_ADDRESS} $ADMIN_USERNAME $ADMIN_DEFAULT_PASS web_config_image.log
ok $? "Precondition Test 19 - Setup and configure the initial CernVM image through \
the web interface"


# Precondition Test 20 - Enable automatic SSH login to the machine for the user
#					     specified using keys instead of passwords, and verify that it
#					     is possible to login automatically
verify_autologin_ssh ${IP_ADDRESS} $USER_NAME $USER_PASS
ok $? "Precondition Test 20 - Enable automatic SSH login to the machine for the user
specified using keys instead of passwords, and verify that it is possible to login automatically"


# Precondition Test 21 - Set the root password using the CernVM web interface
web_root_password ${IP_ADDRESS} $ROOT_PASS $ADMIN_PASS web_root_pass.log
ok $? "Precondition Test 21 - Set the root password using the CernVM web interface"


# Precondition Test 22 - Enable automatic SSH login to the machine for the root
#					     user using keys instead of passwords, and verify that it
#					     is possible to login automatically
verify_autologin_ssh ${IP_ADDRESS} root $ROOT_PASS
ok $? "Precondition Test 22 - Enable automatic SSH login to the machine for the root \
user using keys instead of passwords, and verify that it is possible to login automatically"




#
# CernVM Test Cases
# Execute CernVM image specific Test Cases
#

# CernVM Test Case 1 - Check login via ssh as user created through web interface
check_ssh ${IP_ADDRESS} $USER_NAME
ok $? "CernVM Test Case 1 - Check login via ssh as user created through web interface"


# CernVM Test Case 2 - Check login via ssh as root
check_ssh ${IP_ADDRESS} root
ok $? "CernVM Test Case 2 - Check login via ssh as root"


# CernVM Test Case 3 - No error messages at boot
check_boot_error ${IP_ADDRESS} boot_error.log
ok $? "CernVM Test Case 3 - No error messages at boot"
add_file boot_error.log


# CernVM Test Case 4 - Check for correct time / running ntpd
check_time ${IP_ADDRESS}
ok $? "CernVM Test Case 4 - Check for correct time / running ntpd"


# CernVM Test Case 5 - Create a new user using the CernVM web interface
web_create_user ${IP_ADDRESS} $USER_NAME2 $USER_PASS2 web_interface_newuser.log
ok $? "CernVM Test Case 5 - Create a new user using the CernVM web interface"
add_file web_interface_newuser.log


# Precondition Test - Enable automatic SSH login to the machine for the user
#					  specified using keys instead of passwords, and verify that it
#					  is possible to login automatically
verify_autologin_ssh ${IP_ADDRESS} $USER_NAME2 $USER_PASS2


# CernVM Test Case 6 - Verify that the user is created and can be accessed
#					   from ssh login
check_ssh ${IP_ADDRESS} $USER_NAME2
ok $? "CernVM Test Case 6 - Verify that the user is created and can be accessed \
from ssh login"


# CernVM Test Case 7 - Restart through the web interface and check that there
#					   are no error messages at boot
web_restart ${IP_ADDRESS} web_interface_reboot.log web_restart_boot.log
ok $? "CernVM Test Case 7 - Restart through the web interface and check that \
there are no error messages at boot"
add_file web_interface_reboot.log
add_file web_restart_boot.log


. ./tapper-autoreport
