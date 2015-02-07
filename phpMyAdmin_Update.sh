#!/bin/bash

# The MIT License (MIT)

# Copyright (c) 2015 Paweł Kubrak <peku33@gmail.com>

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


UNZIP_CMD=`which unzip`
if test -z "$UNZIP_CMD"
then
	echo "* unzip command not found"
	exit 2
fi

WGET_CMD=`which wget`
if test -z "$WGET_CMD"
then
	echo "* wget command not found"
	exit 2
fi

MKTEMP_CMD=`which mktemp`
if test -z "$MKTEMP_CMD"
then
	echo "* mktemp command not found"
	exit 2
fi

if test ${#} != 1
then
	echo "* Usage: $0 <phpMyAdmin directory>"
	echo ""
	echo "* This simple script will:"
	echo "* 1. Download and unpack latest phpMyAdmin (zip) into temporary directory"
	echo "* 2. Remove <phpMyAdmin directory>_old and rename <phpMyAdmin directory> to <phpMyAdmin directory>_old"
	echo "* 3. Move downloaded phpMyAdmin to <phpMyAdmin directory>"
	echo "* 4. Copy config.inc.php from <phpMyAdmin directory>_old to <phpMyAdmin directory>"
	echo "* 5. Done"
	echo ""
	
	exit 1
fi

#1
DOWNLOAD_URL="http://sourceforge.net/projects/phpmyadmin/files/latest/download"
TEMP_FILE_NAME=`${MKTEMP_CMD}` || exit 1
TEMP_DIR_NAME=`${MKTEMP_CMD} -d` || exit 1

echo "* Downloading ${DOWNLOAD_URL} -> ${TEMP_FILE_NAME}"
${WGET_CMD} -q -O ${TEMP_FILE_NAME} ${DOWNLOAD_URL} || exit 1
echo "* Unpacking ${TEMP_FILE_NAME} -> ${TEMP_DIR_NAME}"
${UNZIP_CMD} -q -d ${TEMP_DIR_NAME} ${TEMP_FILE_NAME} || exit 1
echo "* Removing ${TEMP_FILE_NAME}"
rm ${TEMP_FILE_NAME}

# 2
PMA_DIR=${1%/}
PMA_DIR_OLD="${PMA_DIR}_old"

echo "* Backing up old version (${PMA_DIR_OLD})"
if test -e ${PMA_DIR}
then
	if test -e ${PMA_DIR_OLD}
	then
		echo "* ${PMA_DIR_OLD} exists, removing"
		rm -rf ${PMA_DIR_OLD} || exit 1
	fi
	
	echo "* Renaming old version (${PMA_DIR} -> ${PMA_DIR_OLD})"
	mv -T ${PMA_DIR} ${PMA_DIR_OLD} || exit 1
fi

# 3
echo "* Creating new version"
mkdir -p ${PMA_DIR} || exit 1
TEMP_DIR_PMA_DIR_NAME=`ls ${TEMP_DIR_NAME}`
echo "* Moving ${TEMP_DIR_NAME}/${TEMP_DIR_PMA_DIR_NAME} -> ${PMA_DIR}"
mv -T "${TEMP_DIR_NAME}/${TEMP_DIR_PMA_DIR_NAME}" "${PMA_DIR}" || exit 1

# 4
CONFIG_FILE_NAME='config.inc.php'
echo "* Restoring old config ($PMA_DIR_OLD/$CONFIG_FILE_NAME)"
if test -f "${PMA_DIR_OLD}/${CONFIG_FILE_NAME}"
then
	echo "* Old config exists, copying"
	cp -v "${PMA_DIR_OLD}/${CONFIG_FILE_NAME}" "${PMA_DIR}/${CONFIG_FILE_NAME}"
else
	echo "* Old config does not exist, skipping"
fi

echo "* Cleaning up"
rm -rf ${TEMP_DIR_NAME}
