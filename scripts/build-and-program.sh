#!/bin/bash

###################################################################
# Script Name    : build-and-program.sh
# Description    : Build and program pre-defined Zephyr-apps
# Args           : See --help
# Author         : Thomas Li Fredriksen
# Email          : thomafred90@gmail.com
###################################################################

set -e

assert_prog () {
    # Assert if a program exists. Exit in failure
    #
    # Positional Args
    #   1 : Program to be asserted. Can be absolute, relative. Alternatively, use program from directory specified in $PATH-variable

    if ! (which $1 > /dev/null); then
        echo "Missing $1"
        exit 1
    fi
}

build_and_program () {
    # Build and program application
    #   Construct build-tree, builds then flashe target.
    #
    # Positional Args
    #   1 : Build directory, should be empty
    #   2 : Zephyr-app

    BUILD_DIR=$1
    APP=$2
	_CWD=$(pwd)

	cd $BUILD_DIR

    $CMAKE -GNinja -DBOARD=nrf9160_pca10090 -DCMAKE_EXPORT_COMPILE_COMMANDS=YES -DCONF_FILE=prj.conf $APP
    $NINJA

    $JLINKEXE -CommanderScript $CWD/load-hex.jlink

	cd $_CWD
}

print_help () {
    echo "Usage: build-and-program.sh [-b|--bootloader] [-a|--at]"
    echo ""
    echo "Arguments:"
    echo "  -b|--bootloader     Build and program bootloader"
    echo "  -a|--at             Build and program AT-Client"
    echo "  -h|--help           Print this help-message"
    echo ""
    echo "Project home page: https://github.com/evry-bergen/rf9160-template-project"
}

CWD="$(pwd)"
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

if [ -z ${ZEPHYR_BASE+x} ]; then
    echo "ZEPHYR_BASE is not set. Please source zephyr-env.sh in the Zephyr root directory"
    exit 1
fi

# Set some helper-variables

PROJ_DIR=$(realpath $DIR/..)

JLINKEXE="JLinkExe"
NINJA="ninja"
CMAKE="cmake"

for i in "$@"; do
    case $i in
        -b|--bootloader)
            PROGRAM_BOOTLOADER=y
            shift
            ;;
        -a|--at)
            PROGRAM_AT_CLIENT=y
            shift
            ;;
        -h|--help)
            print_help
            shift
            ;;
    esac
done

assert_prog $JLINKEXE
assert_prog $CMAKE
assert_prog $NINJA

if [ ! -z ${PROGRAM_BOOTLOADER+x} ]; then
    BOOTLOADER_BUILD_DIR=$(mktemp -d)

    echo "Building Secore-boot to directory: $BOOTLOADER_BUILD_DIR"

    build_and_program $BOOTLOADER_BUILD_DIR $PROJ_DIR/ncs/nrf/samples/nrf9160/secure_boot

    echo "Removing build-directory: $BOOTLOADER_BUILD_DIR"
    rm -fr $BOOTLOADER_BUILD_DIR
fi

if [ ! -z ${PROGRAM_AT_CLIENT+x} ]; then
    AT_CLIENT_BUILD_DIR=$(mktemp -d)

    echo "Building AT-Client to directory: $AT_CLIENT_BUILD_DIR"

    build_and_program $AT_CLIENT_BUILD_DIR $PROJ_DIR/ncs/nrf/samples/nrf9160/secure_boot

    echo "Removing build-directory: $AT_CLIENT_BUILD_DIR"
    rm -fr $AT_CLIENT_BUILD_DIR
fi
