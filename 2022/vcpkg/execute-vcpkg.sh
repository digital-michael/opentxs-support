#!/bin/sh 

# 
# Requires Developer Command Prompt for VC 2019/2022
#   Example for a .BAT launcher:
#       CALL "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 
# 

DEBUG_MODE=0
FULL_CLEAN=0
SHUTDOWN_AFTER=0

function help {
cat << EndOfHelp

    ${0} [order dependent options] name(.config) 
                - executes a vcpkg build according to the settings found in name(.config)

    Options                 Description
    =========               ==================== 
    -h | --help             display this help

    -d | --dry-run          Show the commands which will be run but make not changes.
                            NOTE: use this option to verify paths and operations against 
                                those paths, especially 'rm -rf ' operations.

    -c | -config-only       create default configuration only.
                            NOTE: do this step first, modify the default valutes 
                                in the configuration file and then use the other features

            Default: default
            Example: --config-only          - creates default.config
            Example: --config-only default  - creates default.config
            Example: --config-only test     - creates test.config
            Example: --config-only release  - creates release.config


    -p | --config-path      set the location to look for .config files

            Default: current directory
            Example: --config-path /d/src


    -f | --full-clean       remove system installed libraries and localy build artifacts

    -s | --shutdown-after   shutdown the workstation after completing an error-free build


    Configuration File 
    ==============================
        Example: "test" will load "test.config" from the established config-path
        Example: "static" will load "static.config" from the established config-path 


    Examples
    ==============================
    ${0} --config-only
    ${0} --config-only default              
                                            - creates a default.config file and and starts the 
                                              vcpkg build process 

    ${0} --config-only test                 
                                            - create a test.config file and stop

    ${0} --dry-run test
                                            - displays the process and commands to be used without 
                                               executing those commands. Used to verify each step
                                               and make changes to test.config prior to execution

    ${0} --config-path ${HOME} test         
                                            - load test.config from the specified config-path 
                                              and starts the vcpkg build process

    ${0} --config-path /d/src/config test   
                                            - load test.config from the specified config-path 
                                              and starts the vcpkg build process

    ${0} --config-path /d/src/config test --shutdown-after  
                                            - load test.config from the specified config-path 
                                              and starts the vcpkg build process, and then 
                                              shutdown the workstation after completing if 
                                              there were no vcpkg build errors
    
EndOfHelp
exit 0
}

# handle CLI command line options
function parse_cli {

  while true;
  do
	case "$1" in 
      -h | --help ) 
        help; 
        exit; 
        ;;
      -d | --dry-run )
        DEBUG_MODE=1
        shift 1
        echo "Configured for dry run"
        ;;
      -c | --config-only )
        CONFIG_ONLY=1
        #CONFIG_NAME="${2}"
        shift 1
        echo "Configured for config only"
        ;;
      -p | --config-path )
        CONFIG_PATH=${2}
        shift 2
        echo "Configured for config path: ${CONFIG_PATH}"
        ;;
      -f | --full-clean )
        FULL_CLEAN=1
        shift 1
        echo "Configured for full clean"
        ;;
      -s | --shutdown-after )
        SHUTDOWN_AFTER=1
        shift 1
        echo "Configured to shutdown after a successful build"
        ;;
      * )
        if [[ ! -z "${1}" ]];
        then 
            CONFIG_NAME="${1}"
        else    
            CONFIG_NAME="default"
        fi
        echo "Configuration name ${CONFIG_NAME}"
        break;
        ;;
    esac
  done
}

# read or create and read a <configuration filename>.config for config-path
function configure {
    CONFIG_ONLY=0
    CONFIG_NAME="default"

    parse_cli "${@}"
   
    if [[ ! -z "${CONFIG_PATH}" ]];
    then
        CONFIG_FILE="${CONFIG_PATH}/${CONFIG_NAME}"
        if [[ ! -f ${CONFIG_FILE} ]];
        then
            CONFIG_FILE="${CONFIG_PATH}/${CONFIG_NAME}.config"
        fi
    else
        CONFIG_FILE="./${CONFIG_NAME}"
        if [[ ! -f ${CONFIG_FILE} ]];
        then
            CONFIG_FILE="./${CONFIG_NAME}.config"
        fi
    fi
   if [ -f "${CONFIG_FILE}" ]; 
   then
       echo "Configuration file: ${CONFIG_FILE}"
   else
       echo "Configuration file: ${CONFIG_FILE} does not exist; creating ${CONFIG_FILE}"
       #SRC=`pwd`/forks/wallet/deps
       SRC=`find . -maxdepth 2 -name 'wallet' -type d -exec realpath {} \; | head -n 1`/deps
       cat > ${CONFIG_FILE} << EndOfConfig 
# Autogenerated ( `date` ): change as necessary
WARNING=1

VCPKG_VERSION="2021.12.01"

VCPKG_DIR="`find . -maxdepth 2 -name 'vcpkg' -type d -exec realpath {} \; | head -n 1`"
WALLET_DIR="`find . -maxdepth 2 -name 'wallet' -type d -exec realpath {} \; | head -n 1`" 
OPENTXS_DIR="`find . -maxdepth 2 -name 'opentxs' -type d -exec realpath {} \; | head -n 1`" 

TARGETS="x64-windows-static x64-windows"
SRC="${SRC}" 
OVERLAY_TRIPLET="${SRC}/opentxs/vcpkg/triplets"
OVERLAY_PORTS="${SRC}/opentxs/vcpkg/ports"
RESPONSE_FILE="${SRC}/vcpkg.qml.txt"

# TO SHUTDOWN WINDOWS use: shutdown.exe -s -t 00  
# TO SLEEP WINDOWS use   : rundll32.exe powrprof.dll, SetSuspendState Sleep
POST_BUILD_CMD="echo ${0} is done."

EndOfConfig
       CONFIG_ONLY=1
       echo "Please review ${CONFIG_FILE} before using it."
    fi 

    source "${CONFIG_FILE}"
   
    if [[ $CONFIG_ONLY -eq 1 ]] ;
    then
        echo "Configuration file: ${CONFIG_FILE}"
        exit 0
    fi

    if [[ $DEBUG_MODE == 1 ]];
    then
        CMD='echo -e \t '
    else
        CMD=""
    fi

    if [[ ${WARNING} -eq 1 ]];
    then
       echo "Configured for enabled warning"
    fi
    echo
}



function check_files_and_directories {
# TODO: check directories for:
# SRC
# SRC/vcpkg
# SRC/forks/opentxs
# SRC/forks/wallet
   if [[ ! -d ${VCPKG_DIR} ]];
   then
        echo "ERROR: Required directory VCPKG_DIR: ${VCPKG_DIR} not found"
        exit 1
   else 
      echo "Validated required directory VCPKG_DIR: ${VCPKG_DIR}"
   fi

   if [[ ! -d ${SRC} ]];
   then
        echo "ERROR: Required directory SRC: ${SRC} not found"
        exit 1   
   else 
      echo "Validated required directory SRC: ${SRC}"
   fi

   if [[ ! -d ${OVERLAY_TRIPLET} ]];
   then
        echo "ERROR: Required directory OVERLAY_TRIPLET ${OVERLAY_TRIPLET} not found"
        exit 1
   else 
      echo "Validated required directory OVERLAY_TRIPLET: ${OVERLAY_TRIPLET}"
   fi

   if [[ ! -d ${OVERLAY_PORTS} ]];
   then
        echo "ERROR: Required directory OVERLAY_PORTS: ${OVERLAY_PORTS} not found"
        exit 1
   else 
      echo "Validated required directory  OVERLAY_PORTS: ${OVERLAY_PORTS}"
   fi

   if [[ ! -f ${RESPONSE_FILE} ]];
   then
        echo "ERROR: Required file RESPONSE_FILE: ${RESPONSE_FILE} not found"
        exit 1
   else 
      echo "Validated required file RESPONSE_FILE: ${RESPONSE_FILE}"
   fi

}


function verify_param {
    VALUE="$1"
    SYMBOL="$2"
    CONTAINS="$3"
    ERROR=$4

    if [[ -z "${VALUE}" ]];
    then 
        echo "Failed to Verify ${SYMBOL}; empty"
        if [[ $ERROR -ne 0 ]]; then WARNING=$ERROR; fi
    elif [[ ! -z "${CONTAINS}" ]] && [[ "${VALUE}" != *"${CONTAINS}"* ]];
    then 
        echo "Failed to Verify ${SYMBOL}; doesn't contain keyword(s): '$CONTAINS'"
        echo "     Value: $VALUE"
       if [[ $ERROR -ne 0 ]]; then WARNING=$ERROR; fi
    else
        echo "Verified ${SYMBOL}"
    fi
}


function verify_configuration {
    verify_param "$WARNING" "WARNING" "" 0

    verify_param "$VCPKG_VERSION" "VCPKG_VERSION" "" 0

    verify_param "$VCPKG_DIR" "VCPKG_DIR" "vcpkg" 1
    verify_param "$WALLET_DIR" "WALLET_DIR" "wallet" 0
    verify_param "$OPENTXS_DIR" "OPENTXS_DIR" "opentxs" 0

    verify_param "$TARGETS" "TARGETS" "windows" 1
    verify_param "$SRC" "SRC" "wallet" 1
    verify_param "$OVERLAY_TRIPLET" "OVERLAY_TRIPLET" "triplets" 1
    verify_param "$OVERLAY_PORTS" "OVERLAY_PORTS" "ports" 1
    verify_param "$RESPONSE_FILE" "RESPONSE_FILE" "vcpkg" 0

    verify_param "$POST_BUILD_CMD" "POST_BUILD_CMD" "" 0

}


# Fetch updated vcpkg to specified version
function get_sanitized_vcpkg_version {
    cd ${VCPKG_DIR}
    ${CMD} git remote update
    if [[ ! -z "${VCPKG_VERSION}" ]];
    then 
       ${CMD} git reset --hard "${VCPKG_VERSION}"
    else
      ${CMD} git pull
    fi
    ${CMD} vcpkg/bootstrap-vcpkg.sh -disableMetrics
     cd ${VCPKG_DIR}/..
}


# Update port versions list
function vcpkg_update {
    ${CMD} vcpkg/vcpkg update
}


# Upgrade port versions
function vcpkg_upgrade {
    ${CMD} vcpkg/vcpkg upgrade
    ${CMD} vcpkg/vcpkg remove --outdated --recurse 
}


function clean_everything {
    echo "Full clean requested"
    clean_build
    ${CMD} rm -rf $HOME/AppData/Local/vcpkg ${VCPKG_DIR}/installed/
}


# clean up from between runs
function clean_build {
   ${CMD} rm -rf ${VCPKG_DIR}/buildtrees/ ${VCPKG_DIR}/downloads/ ${VCPKG_DIR}/packages/​
}


# PARAMS with order and an example
#  - TRIPLET - x64-windows-static
#  - OVERLAY_TRIPLET - ${SRC}/opntexs/vcpkg/triplets
#  - OVERLAY_PORTS - ${SRC}/opentxs/vcpkg/ports
#  - RESPONSE_FILE -  ${SRC}/deps/vcpkg.qml.txt
function vcpkg_install {
    TRIPLET="${1}"
    OVERLAY_TRIPLET="${2}"
    OVERLAY_PORTS="${3}"
    RESPONSE_FILE="${4}"

    RESPONSE="`tr -d '\r' < ${RESPONSE_FILE}`"

    if [[ $DEBUG_MODE == 1 ]];
    then
        ${CMD} vcpkg/vcpkg.exe install --triplet=${TRIPLET} --overlay-triplets=${OVERLAY_TRIPLET} --overlay-ports=${OVERLAY_PORTS} ${RESPONSE}
    else
        vcpkg/vcpkg.exe install --triplet=${TRIPLET} --overlay-triplets=${OVERLAY_TRIPLET} --overlay-ports=${OVERLAY_PORTS} ${RESPONSE}
        return $?
    fi
}


# Make results available
function vcpkg_integrate {
    ${CMD} vcpkg/vcpkg integrate install
}


function shutdown_afterwards {
    ${CMD} shutdown.exe -s -t 00  
}


# TRIPLET - 'x64-windows-static' or 'x64-windows'
function vcpkg_buildFor {
    TRIPLET="${1}"

    echo
    echo =========================================
    echo === build for: ${TRIPLET} ====
    echo =========================================
    
    echo
    echo ==== Stage 0: vcpkg version
    clean_build

    echo
    echo ==== Stage 1: vcpkg version
    get_sanitized_vcpkg_version
    
    echo
    echo ==== Stage 2: update port definitions \(skipped\)
    # vcpkg_update
    
    echo
    echo ==== Stage 3: upgrade ports and clean up outdated ports \(skipped\)
    # vcpkg_upgrade
    
    echo
    echo ==== Stage 4: execute library builds for ${TRIPLET} 
    vcpkg_install "${TRIPLET}" "${OVERLAY_TRIPLET}" "${OVERLAY_PORTS}" "${RESPONSE_FILE}"
    CODE="$?"
    if [[ $CODE -ne 0 ]];
    then
       echo "Stage 4: failed $CODE"
       exit $CODE
    fi
    
    echo
    echo ==== Stage 5: manually free up disk space 
    clean_build 

    echo
 }


#
# Main
#

echo Started at `date`
echo 

configure "${@}"
verify_configuration
check_files_and_directories

if [[ ${WARNING} == 1 ]]; 
then
    cat << EndOfWarning
WARNING:  
   This tool is uses 'rm -rf ' against defined paths, some specified in 
   the name(.config) file, and some assumed for the Windows Platform.

   It is recommended to use --dry-run and review the commands with particular
   focus on the 'rm -rf ' to insure knowledge of changes made to your workstation.

   IMPORTANT: mis-configuraitons in name(.config) file can destroy your functioning workstaion.

   To disable this message, edit your .config file and set WARNING to 0

   Press CTRL-C now to stop or press ENTER to proceed

EndOfWarning
read
fi

if [[ ${FULL_CLEAN} == 1 ]]; 
then
   clean_everything
fi

for i in ${TARGETS}
do
   vcpkg_buildFor "$i"
done

echo
echo ==== notify of new libraries
vcpkg_integrate

echo Completed at `date`
echo

if [[ ! -z "${POST_BUILD_CMD}" ]]; 
then
   ${CMD} ${POST_BUILD_CMD} 
fi

if [[ ${SHUTDOWN_AFTER} == 1 ]]; 
then
   shutdown_afterwards
fi

