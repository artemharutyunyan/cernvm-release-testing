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
#   Precondition Test 0  - Verify that the download page exists and that there is a 
#                          valid download url for the CernVM image specified, returns
#                          the url to download the image
#
#   Precondition Test 1  - Download and extract the CernVM image, returns the location 
#                          of the extracted cernvm image file
#
#   Precondition Test 2  - Create an XML definition file for the virtual machine based
#                          on the template XML definition file and settings defined and
#                          return the location of the final xml defintion file
#
#   Precondition Test 3  - Verify that the virtual machine XML definition file exists
#
#   Precondition Test 4  - Verify that the XML definition file provided is valid
#
#   Precondition Test 5  - Verify that the mandatory configuration settings for the
#                          virtual machine XML definition file have been provided
#                          and are valid
#
#   Precondition Test 6  - Verify that the hypervisor for the current virtual machine
#                          tested is accessible, set the URI as a global variable
#
#   Precondition Test 7  - Create an XML definition file for the virtual machine network
#                          based on the template network XML definition file and settings 
#                          defined and return the location of the created xml defintion file
#
#   Precondition Test 8  - Verify that the network XML definition file exists
#
#   Precondition Test 9  - Verify that the network XML definition file provided is valid
#
#   Precondition Test 10 - Verify that the mandatory configuration settings for the
#                          network XML definition file have been provided
#                          and are valid
#
#   Precondition Test 11 - Verify that the virtual machine network has been created 
#                          from an xml file
#
#   Precondition Test 12 - Verify that virtual machine NAT network is active and 
#                          set to autostart, only supported for KVM currently
#
#   Precondition Test 13 - Set a new UUID for the virtual machine hdd, this test is specific
#                          to VirtualBox and is a fix for a known UUID conflict issue
#
#   Precondition Test 14 - Verify that virtual machine domain has been created 
#                          from an xml file
#
#   Precondition Test 15 - Verify that virtual machine can be started
#
#   Precondition Test 16 - Verify that virtual machine has been stopped
#
#   Precondition Test 17 - Verify that virtual machine has web interface support
#
#   Precondition Test 18 - Verify that it is possible to login on web interface
#
#   Precondition Test 19 - Setup and configure the initial CernVM image through the
#                          web interface
#
#   Precondition Test 20 - Verify that it is possible to login on web interface using
#                          the new web interface administrator password
#
#   Precondition Test 21 - Enable automatic SSH login to the machine for the user
#                          specified using keys instead of passwords, and verify that it
#                          is possible to login automatically
#
#   Precondition Test 22 - Set the root password using the CernVM web interface
#
#   Precondition Test 23 - Enable automatic SSH login to the machine for the root
#                          user using keys instead of passwords, and verify that it
#                          is possible to login automatically
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
#   CernVM Test Case 0  - Check login via ssh as user created through web interface
#
#   CernVM Test Case 1  - Check login via ssh as root
#
#   CernVM Test Case 2  - No error messages at boot
#
#   CernVM Test Case 3  - Check for correct time / running ntpd
#
#   CernVM Test Case 4  - Create a new user using the CernVM web interface
#
#   CernVM Test Case 5  - Verify that the user is created and can be accessed
#                         from ssh login
#
#   CernVM Test Case 6  - Restart through the web interface and check that there
#                         are no error messages at boot
#
#   CernVM Test Case 7  - Shutdown the system and disconnect the network, then start
#                         the image, it should take longer to boot but the system
#                         should not hang on startup
#
#   CernVM Test Case 8  - Check that cernvmfs automount scripts works correctly
#                         and is able to mount any experiment group to /cvmfs/
#
#   CernVM Test Case 9  - Check the cvmfs cache list, verify that the cache list is 
#                         available after restarting the cvmfs daemon
#
#   CernVM Test Case 10 - Migrate to another experiment such as LHCB using the web
#                         interface and make sure the relative tests are loaded 
#
#   CernVM Test Case 11 - Check that cernvmfs automount scripts works correctly
#                         and is able to mount the new experiment group to /cvmfs/
#
#   CernVM Test Case 12 - Check the cvmfs cache list for the new experiment group,
#                         verify that the cache list is available after restarting
#                         the cvmfs daemon 
#
#   CernVM Test Case 13 - Change the group of the primary user
#
# =============================================================================

. ./tapper-autoreport --import-utils
. ./general-interface
. ./virt-interface
. ./web-interface
. ./cernvm-preconditions
. ./cernvm-testcases
. ./testsuite-trace

######## INTERNAL MANDATORY CONFIGURATIONS ##########
###
### ALL OF THESE SETTINGS ARE MANDATORY AND MUST BE
### SET IN THE CONFIGURATION FILE FOR SCRIPT TO WORK
###

######### Mandatory Test Suite Settings ##########
SUITENAME="${CVM_TS_SUITENAME}"             # Mandatory, the suite name for the tests
SUITEVERSION="${CVM_TS_SUITEVERSION}"   # Mandatory, the suite version, use default value
REPORT_SERVER="${CVM_TS_REPORT_SERVER}"     # Mandatory, Tapper server hostname/ip to send reports to
DOWNLOAD_PAGE="${CVM_TS_DOWNLOAD_PAGE}"     # Mandatory, a default url is provided in the configuration file


######### Mandatory Precondition and Test Case List ##########
PRECONDITION_TEST_LIST=(${CVM_PRECONDITION_TEST_LIST[@]})
TEST_CASE_LIST=(${CVM_TEST_CASE_LIST[@]})


######### Mandatory CernVM Image Settings ##########
HYPERVISOR="${CVM_VM_HYPERVISOR}"           # Mandatory, valid hypervisors are vmware,vbox,kvm,xen
TEMPLATE="${CVM_VM_TEMPLATE}"               # Mandatory, the hypervisor template file in the templates folder
NET_TEMPLATE="${CVM_VM_NET_TEMPLATE}"       # Mandatory, the network template file, only applies to kvm/virtualbox/xen
IMAGE_TYPE="${CVM_VM_IMAGE_TYPE}"           # Mandatory, currently only basic and desktop supported
IMAGE_VERSION="${CVM_VM_IMAGE_VERSION}"     # Mandatory, version to download
ARCH="${CVM_VM_ARCH}"                       # Mandatory, valid architectures are x86 and x86_64

###
###
###
######## INTERNAL MANDATORY CONFIGURATIONS ##########



######## INTERNAL OPTIONAL CONFIGURATIONS ###########
###
### ALL OF THESE ARE OPTIONAL CONFIGURATION SETTINGS
### THAT WILL USE INTERNAL DEFAULTS IF NOT SPECIFIED 
###

######### Optional Trace and Debugging Settings ##########
TRACE_VERBOSITY="${CVM_TS_TRACE_VERBOSITY:-2}"            # Optional, trace verbosity valid values are 0 - 3

######### Optional Host Settings ##########
IMAGES_DIR="${CVM_TS_IMAGES_DIR:-/usr/share/images}"    # Optional, root directory for cernvm images
TEST_RUN_ID_FILE="${CVM_VM_TEST_RUN_ID_FILE:-runid}" # Optional name of the test run ID file 
OSTYPE="${CVM_TS_OSTYPE:-$(get_os_type)}"               # Optional, by default automatically determined by script 
OSNAME="${CVM_TS_OSNAME:-$(get_os_name ${OSTYPE})}"     # Optional, by default automatically determined by script 
HOSTNAME="${CVM_TS_HOSTNAME}"                           # Optional, set this to override the system hostname


######### Optional CernVM Image Settings ##########
IMAGE_RELEASE_ID="${CVM_VM_IMAGE_RELEASE_ID}" # Optional, used to narrow down testing of the same release version
TEST_DATE="$(date +%Y-%m-%d-%H-%M-%S)"
TEST_DATE_SHORT="$(date +%Y%m%d%H%M%S)"
NAME="${CVM_VM_NAME:-${HYPERVISOR}-${ARCH}-${IMAGE_VERSION}-${IMAGE_RELEASE_ID}-${TEST_DATE_SHORT}}" # Optional, default name based on hypervisor & version
CPUS="${CVM_VM_CPUS}"                       # Optional, default in template used unless overriden
MEMORY="${CVM_VM_MEMORY}"                   # Optional, default in template used unless overriden
VIDEO_MEMORY="${CVM_VM_VIDEO_MEMORY}"       # Optional, default in template used unless overriden
NET_NAME="${CVM_VM_NET_NAME}"               # Optional, default in template used unless overriden
MAC_ADDRESS="${CVM_VM_MAC_ADDRESS}"         # Optional, default in template used unless overriden
TEST_RUN_ID="${CVM_VM_TEST_RUN_ID:-$(create_run_id $TEST_RUN_ID_FILE)}"         # Optional, by default automatically determined by script

######### Optional Web Interface Settings ##########
ADMIN_USERNAME="${CVM_WEB_ADMIN_USERNAME:-admin}"
ADMIN_DEFAULT_PASS="${CVM_WEB_ADMIN_DEFAULT_PASS:-password}"
ADMIN_PASS="${CVM_WEB_ADMIN_PASS:-VM4l1f3}"

# CernVM image user settings, specify the settings for new account
USER_NAME="${CVM_WEB_USER_NAME:-lhcb}"
USER_PASS="${CVM_WEB_USER_PASS:-VM4l1f3}"
USER_GROUP="${CVM_WEB_USER_GROUP:-lhcb}"

# CernVM image root account settings, specify password for root account
ROOT_PASS="${CVM_WEB_ROOT_PASS:-VM4l1f3}"

# CernVM image desktop settings
STARTXONBOOT="${CVM_WEB_STARTXONBOOT:-on}"       # Start X on boot, either "on" or "off"
RESOLUTION="${CVM_WEB_RESOLUTION:-1024x768}"     # CernVM image desktop resolution
KEYBOARD_LOCALE="${CVM_WEB_KEYBOARD_LOCALE:-us}" # CernVM image keyboard locale

# CernVM image primary group (experiment) settings
EXPERIMENT_GROUP="${CVM_WEB_EXPERIMENT_GROUP:-ATLAS}" # Group name, should be all capitals


######### Optional Test Case Settings ##########
USER_NAME2="${CVM_TC_USER_NAME:-bob}"   # Best to leave as default as it does affect testing
USER_PASS2="${CVM_TC_USER_PASS:-R00tM3}" # Best to leave as default as it does affect testing

# CernVM image primary group to migrate to for test case
EXPERIMENT_GROUP2="${CVM_TC_EXPERIMENT_GROUP:-LHCB}" # Group name, should be all capitals

# New group for primary user to change to
USER_GROUP2="${CVM_TC_USER_GROUP:-lhcb}"

###
###
###
######## INTERNAL OPTIONAL CONFIGURATIONS ###########


######## DEFAULT INTERNAL CONFIGURATIONS ############
###
### ALL OF THESE ARE CONFIGURATION SETTINGS INTERNAL
### TO THE SCRIPTS AND SHOULD NOT BE ALTERED BY USER 
###

######### Path Settings ##########
TEMPLATE_DIR="$(pwd)/templates"
IMAGE_FOLDER="${IMAGES_DIR}/${HYPERVISOR}/${TEST_RUN_ID}" # Unique image download location
LOG_FOLDER="${IMAGE_FOLDER}/logs" # Unique image download location
TRACE_LOGFILE="${CVM_TS_TRACE_LOGFILE:-$LOG_FOLDER/cernvm-trace.log}" # Optional, name of trace logfile


######### CernVM Image Settings ##########
IMAGE_URL=""                        # Leave blank, url to download CernVM image
CERNVM_IMAGE=""                     # Leave blank, location of the CernVM image file
VM_XML_DEFINITION=""                # Leave blank, the virtual machine definition file
NET_XML_DEFINITION=""               # Leave blank, the network definition file
IP_ADDRESS=""                       # DO NOT TOUCH, SPECIFYING CUSTOM IP ADDRESSES IS NOT SUPPORTED YET
VM_UUID=$(uuid)                     # Must be set as a valid uuid
NET_UUID=$(uuid)                    # Must be set as a valid uuid
URI=""                              # Leave blank, virsh URI for the hypervisor, exported by script


######### Auto-Tapper Report Settings ##########
CHANGESET="0"
REPORTGROUP=selftest-$(date | md5sum | cut -d" " -f1)
NOSEND=0
NOUPLOAD=0


######### Tapper AutoReport Settings ##########
TAP[0]="ok - autoreport selftest"

HEADERS[0]="# Tapper-CernVM-Version: ${IMAGE_VERSION}"
HEADERS[1]="# Tapper-CernVM-ReleaseID: ${IMAGE_RELEASE_ID}"
HEADERS[2]="# Tapper-CernVM-Name: ${NAME}"
HEADERS[3]="# Tapper-CernVM-Architecture: ${ARCH}"
HEADERS[4]="# Tapper-CernVM-Image-Path: ${IMAGE_FOLDER}"
HEADERS[5]="# Tapper-CernVM-Test-Start: ${TEST_DATE}"
HEADERS[6]="# Tapper-CernVM-Description: CernVM Image Testing"

OUTPUT[0]="Please review the attached files"
OUTPUT[1]="for more information about"
OUTPUT[2]="test failures"

TAPDATA[0]="timecpb: 12"
TAPDATA[1]="timenocpb: 15"
TAPDATA[2]="ratio: 0.8"
TAPDATA[3]="vendor: $(get_vendor)"
TAPDATA[4]="cpu_family: $(get_cpu_family)"
append_tapdata "number_of_tap_reports: $(get_tap_counter)"

###
###
###
######## DEFAULT INTERNAL CONFIGURATIONS ############



######## CERNVM PRECONDITION TEST LIST ############
###
### THE FOLLOWING IS A LIST OF ALL AVAILABLE PRECONDITION
### TESTS WHICH MAY BE EXECUTED, REFER TO DEVELOPER MANUAL
### FOR MORE INFORMATION ON PRECONDITION TESTS
###

######### Precondition Test Descriptions ##########
PRECONDITION_TEST_DESC[0]="Precondition Test 0 - Verify that the download page exists and that there \
is a valid download url for the CernVM image specified, returns the url to download the image"

PRECONDITION_TEST_DESC[1]="Precondition Test 1 - Download and extract the CernVM image"

PRECONDITION_TEST_DESC[2]="Precondition Test 2 - Create an XML definition file for the virtual machine \
based on the template XML definition file and settings provided"

PRECONDITION_TEST_DESC[3]="Precondition Test 3  - Verify that the virtual machine XML definition file exists"

PRECONDITION_TEST_DESC[4]="Precondition Test 4  - Verify that the XML definition file provided is valid"

PRECONDITION_TEST_DESC[5]="Precondition Test 5  - Verify that the mandatory configuration settings for the \
virtual machine XML definition file have been provided and are valid"

PRECONDITION_TEST_DESC[6]="Precondition Test 6  - Verify that the hypervisor for the current virtual machine \
tested is accessible, set the URI as a global variable"

PRECONDITION_TEST_DESC[7]="Precondition Test 7 - Create an XML definition file for the virtual machine network \
based on the template network XML definition file and settings defined"

PRECONDITION_TEST_DESC[8]="Precondition Test 8 - Verify that the network XML definition file exists"

PRECONDITION_TEST_DESC[9]="Precondition Test 9 - Verify that the network XML definition file provided is valid"

PRECONDITION_TEST_DESC[10]="Precondition Test 10 - Verify that the mandatory configuration settings for the \
network XML definition file have been provided and are valid"

PRECONDITION_TEST_DESC[11]="Precondition Test 11 - Verify that the virtual machine network has been \
created from an xml file"

PRECONDITION_TEST_DESC[12]="Precondition Test 12  - Verify that virtual machine NAT network is active and \
set to autostart, only supported for KVM currently"

PRECONDITION_TEST_DESC[13]="Precondition Test 13  - Set a new UUID for the virtual machine hdd, this test is \
specific to VirtualBox and is a fix for a known UUID conflict issue"

PRECONDITION_TEST_DESC[14]="Precondition Test 14 - Verify that virtual machine domain $VMNAME has been \
created from an xml file"

PRECONDITION_TEST_DESC[15]="Precondition Test 15 - Verify that virtual machine $VMNAME has been started"

PRECONDITION_TEST_DESC[16]="Precondition Test 16 - Verify that virtual machine $VMNAME has been stopped"

PRECONDITION_TEST_DESC[17]="Precondition Test 17 - Verify that virtual machine $VMNAME has web interface support"

PRECONDITION_TEST_DESC[18]="Precondition Test 18 - Verify that it is possible to login on web interface"

PRECONDITION_TEST_DESC[19]="Precondition Test 19 - Setup and configure the initial CernVM image through \
the web interface"

PRECONDITION_TEST_DESC[20]="Precondition Test 20 - Verify that it is possible to login on web interface using \
the new web interface administrator password"

PRECONDITION_TEST_DESC[21]="Precondition Test 21 - Enable automatic SSH login to the machine for the user
specified using keys instead of passwords, and verify that it is possible to login automatically"

PRECONDITION_TEST_DESC[22]="Precondition Test 22 - Set the root password using the CernVM web interface"

PRECONDITION_TEST_DESC[23]="Precondition Test 23 - Enable automatic SSH login to the machine for the root \
user using keys instead of passwords, and verify that it is possible to login automatically"


######### Precondition Test List ##########
PRECONDITION_TEST[0]='IMAGE_URL=$(image_url $DOWNLOAD_PAGE $IMAGE_VERSION $HYPERVISOR $ARCH $IMAGE_TYPE)'
PRECONDITION_TEST[1]='CERNVM_IMAGE=$(download_extract ${IMAGE_URL} ${IMAGE_FOLDER} ${LOG_FOLDER}/cernvm_image_download.log)'
PRECONDITION_TEST[2]='VM_XML_DEFINITION=$(create_def $TEMPLATE $IMAGE_FOLDER)'
PRECONDITION_TEST[3]='verify_exists ${VM_XML_DEFINITION}'
PRECONDITION_TEST[4]='validate_def_xml ${VM_XML_DEFINITION}'
PRECONDITION_TEST[5]='validate_def_settings ${VM_XML_DEFINITION}'
PRECONDITION_TEST[6]='URI=$(verify_hypervisor ${VM_XML_DEFINITION})'
PRECONDITION_TEST[7]='NET_XML_DEFINITION=$(create_net_def $NET_TEMPLATE $IMAGE_FOLDER)'
PRECONDITION_TEST[8]='verify_exists ${NET_XML_DEFINITION}'
PRECONDITION_TEST[9]='validate_def_xml ${NET_XML_DEFINITION}'
PRECONDITION_TEST[10]='validate_net_settings ${NET_XML_DEFINITION}'
PRECONDITION_TEST[11]='create_net ${NET_XML_DEFINITION} ${NET_NAME}'
PRECONDITION_TEST[12]='verify_vm_net ${NET_NAME}'
PRECONDITION_TEST[13]='set_vmhdd_uuid ${CERNVM_IMAGE}'
PRECONDITION_TEST[14]='create_vm ${VM_XML_DEFINITION} $NAME'
PRECONDITION_TEST[15]='start_vm ${VM_XML_DEFINITION} ${NET_XML_DEFINITION} $NAME'
PRECONDITION_TEST[16]='stop_vm $NAME'
PRECONDITION_TEST[17]='web_check_interface ${IP_ADDRESS} ${LOG_FOLDER}/web_interface.log'
PRECONDITION_TEST[18]='web_check_login ${IP_ADDRESS} $ADMIN_USERNAME $ADMIN_DEFAULT_PASS ${LOG_FOLDER}/web_interface_login.log'
PRECONDITION_TEST[19]='configure_image_web ${IP_ADDRESS} $ADMIN_USERNAME $ADMIN_DEFAULT_PASS'
PRECONDITION_TEST[20]='web_check_login ${IP_ADDRESS} $ADMIN_USERNAME $ADMIN_PASS ${LOG_FOLDER}/web_interface_login2.log'
PRECONDITION_TEST[21]='verify_autologin_ssh ${IP_ADDRESS} $USER_NAME $USER_PASS'
PRECONDITION_TEST[22]='web_root_password ${IP_ADDRESS} $ROOT_PASS $ADMIN_PASS ${LOG_FOLDER}/web_root_pass.log'
PRECONDITION_TEST[23]='verify_autologin_ssh ${IP_ADDRESS} root $ROOT_PASS'

###
###
###
######## CERNVM PRECONDITION TEST LIST ############




######## CERNVM TEST CASE LIST ############
###
### THE FOLLOWING IS A LIST OF ALL AVAILABLE CERNVM TEST
### CASES WHICH MAY BE EXECUTED, REFER TO DEVELOPER MANUAL
### FOR MORE INFORMATION ON CERNVM TEST CASES
###

######### CernVM Test Case Descriptions ##########
TEST_CASE_DESC[0]="CernVM Test Case 0 - Check login via ssh as user created through web interface"

TEST_CASE_DESC[1]="CernVM Test Case 1 - Check login via ssh as root"

TEST_CASE_DESC[2]="CernVM Test Case 2 - No error messages at boot"

TEST_CASE_DESC[3]="CernVM Test Case 3 - Check for correct time / running ntpd"

TEST_CASE_DESC[4]="CernVM Test Case 4 - Create a new user using the CernVM web interface"

TEST_CASE_DESC[5]="CernVM Test Case 5 - Verify that the user is created and can be accessed \
from ssh login"

TEST_CASE_DESC[6]="CernVM Test Case 6 - Restart through the web interface and check that \
there are no error messages at boot"

TEST_CASE_DESC[7]="CernVM Test Case 7 - Shutdown the system and disconnect the network, then start the \
the image, it should take longer to boot but the system should not hang on startup"

TEST_CASE_DESC[8]="CernVM Test Case 8 - Check that cernvmfs automount scripts works correctly and is \
able to mount any experiment group to /cvmfs/"

TEST_CASE_DESC[9]="CernVM Test Case 9 - Check the cvmfs cache list, verify that the cache list is \
available after restarting the cvmfs daemon"

TEST_CASE_DESC[10]="CernVM Test Case 10 - Migrate to another experiment such as LHCB using the web \
interface and make sure the relative tests are loaded"

TEST_CASE_DESC[11]="CernVM Test Case 11 - Check that cernvmfs automount scripts works correctly and \
is able to mount the new experiment group to /cvmfs/"

TEST_CASE_DESC[12]="CernVM Test Case 12 - Check the cvmfs cache list for the new experiment group, \
verify that the cache list is available after restarting the cvmfs daemon"

TEST_CASE_DESC[13]="CernVM Test Case 13 - Change the group of the primary user"


######### CernVM Test Case List ##########
TEST_CASE[0]='check_ssh ${IP_ADDRESS} $USER_NAME'
TEST_CASE[1]='check_ssh ${IP_ADDRESS} root'
TEST_CASE[2]='check_boot_error ${IP_ADDRESS} ${LOG_FOLDER}/boot_error.log'
TEST_CASE[3]='check_time ${IP_ADDRESS}'
TEST_CASE[4]='web_create_user ${IP_ADDRESS} $USER_NAME2 $USER_PASS2 $USER_GROUP ${LOG_FOLDER}/web_interface_newuser.log'
TEST_CASE[5]='check_ssh ${IP_ADDRESS} $USER_NAME2'
TEST_CASE[6]='check_web_restart ${IP_ADDRESS} ${LOG_FOLDER}/web_interface_reboot.log ${LOG_FOLDER}/web_restart_boot.log'
TEST_CASE[7]='check_no_network ${IP_ADDRESS} $NAME ${NET_NAME} ${VM_XML_DEFINITION} ${NET_XML_DEFINITION}'
TEST_CASE[8]='check_cvmfs_automount ${IP_ADDRESS} $EXPERIMENT_GROUP'
TEST_CASE[9]='check_cvmfs_cache ${IP_ADDRESS} ${LOG_FOLDER}/cvmfs_cache.log'
TEST_CASE[10]='migrate_experiment ${IP_ADDRESS} $EXPERIMENT_GROUP2 ${LOG_FOLDER}/migrate_experiment.log'
TEST_CASE[11]='check_cvmfs_automount ${IP_ADDRESS} $EXPERIMENT_GROUP2'
TEST_CASE[12]='check_cvmfs_cache ${IP_ADDRESS} ${LOG_FOLDER}/cvmfs_cache_new_group.log'
TEST_CASE[13]='change_user_group ${IP_ADDRESS} $USER_NAME $USER_PASS $USER_GROUP2 ${LOG_FOLDER}/change_user_group.log'

###
###
###
######## CERNVM TEST CASE LIST ############



main_after_hook ()
{
    valuex=17
    echo "# Be sure to review the attached files, in particular"
    echo "# the boot_error.log incase there was an error that"
    echo "# did not get caught by the tests."
}


# Mandatory if trace enabled, create trace log file
create_trace_log $TRACE_LOGFILE


#
# Execute the CernVM Precondition Tests specified in config file
# Create/configure, start, and control virtual machines tests
#
for j in $(eval echo {0..$((${#PRECONDITION_TEST_LIST[@]} - 1))})
do
    
    # For certain Precondition Tests, first meet the required dependencies
    case "${PRECONDITION_TEST_LIST[${j}]}" in
        "7")
          # Export the URI, required environment variable for virsh
          export URI
          ;;
        "11")
          # Set the network name, for VMware it is only a pseudo network name
          # because libvirt/virsh does not support VMware networking currently
          NET_NAME=$(get_net_name $HYPERVISOR ${NET_XML_DEFINITION})
          ;;
        "17")
          # Start the virtual machine, which must be running for the proceeding tests
          start_vm ${VM_XML_DEFINITION} ${NET_XML_DEFINITION} $NAME

          # Set the network MAC address and IP address
          MAC_ADDRESS="$(get_mac_address ${VM_XML_DEFINITION})"
          IP_ADDRESS="$(get_ip_address $HYPERVISOR ${MAC_ADDRESS} ${NET_XML_DEFINITION})"
          ;;
        "*")
          ;;
    esac
    
    # Log a message to the trace file giving the name and description of the test
    generic_msg "\nEXECUTING ${PRECONDITION_TEST_DESC[${PRECONDITION_TEST_LIST[${j}]}]}"

    # Execute the Precondition Test specified in PRECONDITION_TEST_LIST
    eval "${PRECONDITION_TEST[${PRECONDITION_TEST_LIST[${j}]}]}"

    # Report the results of precondition test
    RESULT="$?"
    ok $RESULT "${PRECONDITION_TEST_DESC[${PRECONDITION_TEST_LIST[${j}]}]}"

    # If a precondition test failed stop testing and submit the report
    if [ "${RESULT}" -ne 0 ]
    then
        # Add a failure message that testing cannot continue
        ok 1 "FAILURE - A PRECONDITION TEST FAILED, TESTING CANNOT CONTINUE"

        # Add all the log files up to this point and submit report
        add_file ${LOG_FOLDER}/cernvm_image_download.log
        add_file ${LOG_FOLDER}/web_interface.log
        add_file ${LOG_FOLDER}/web_interface_login.log
        add_file ${LOG_FOLDER}/web_interface_login2.log
        add_file ${LOG_FOLDER}/web_root_pass.log

        # Submit report, return error
        . ./tapper-autoreport
        exit 1
    fi
done



#
# CernVM Test Cases
# Execute CernVM image specific Test Cases specified in config file
#
for j in $(eval echo {0..$((${#TEST_CASE_LIST[@]} - 1))})
do
    
    # For certain Test Cases, first meet the required dependencies
    case "${TEST_CASE_LIST[${j}]}" in
        "5")
          # Before executing Test Case 5 execute a precondition test
          # which enables automatic SSH login to the machine for the user
          verify_autologin_ssh ${IP_ADDRESS} $USER_NAME2 $USER_PASS2 
          ;;
        "*")
          ;;
    esac

    # Log a message to the trace file giving the name and description of the test
    generic_msg "\nEXECUTING ${TEST_CASE_DESC[${TEST_CASE_LIST[${j}]}]}"

    # Execute the Test Case specified in TEST_CASE_LIST
    eval "${TEST_CASE[${TEST_CASE_LIST[${j}]}]}"

    # Report the results of the Test Case
    RESULT="$?"
    ok $RESULT "${TEST_CASE_DESC[${TEST_CASE_LIST[${j}]}]}"
done


# Shutdown the virtual machine and cleanup the test environment for next set of tests
stopvm $NAME

# Add all of the log files to the tapper report and submit the report
add_file ${LOG_FOLDER}/cernvm-trace.log
add_file ${LOG_FOLDER}/cernvm_image_download.log
add_file ${LOG_FOLDER}/web_root_pass.log
add_file ${LOG_FOLDER}/web_interface_login2.log
add_file ${LOG_FOLDER}/web_apply_settings.log
add_file ${LOG_FOLDER}/web_config_group.log
add_file ${LOG_FOLDER}/web_config_desktop.log
add_file ${LOG_FOLDER}/web_create_new_user.log
add_file ${LOG_FOLDER}/web_config_password.log
add_file ${LOG_FOLDER}/web_config_proxy.log
add_file ${LOG_FOLDER}/web_config_login.log
add_file ${LOG_FOLDER}/web_config_check.log
add_file ${LOG_FOLDER}/web_interface_login.log
add_file ${LOG_FOLDER}/web_interface.log
add_file ${LOG_FOLDER}/boot_error.log
add_file ${LOG_FOLDER}/web_interface_newuser.log
add_file ${LOG_FOLDER}/web_interface_reboot.log
add_file ${LOG_FOLDER}/web_restart_boot.log
add_file ${LOG_FOLDER}/cvmfs_cache.log
add_file ${LOG_FOLDER}/migrate_experiment.log
add_file ${LOG_FOLDER}/cvmfs_cache_new_group.log
add_file ${LOG_FOLDER}/change_user_group.log

. ./tapper-autoreport

exit 0
