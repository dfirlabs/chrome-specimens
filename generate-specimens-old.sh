#!/bin/bash
#
# Script to generate Google Chrome test files
# Requires a 32-bit or 64-bit version of Ubuntu 14.04
#
# Reference of Google Chrome command line options:
# https://peter.sh/experiments/chromium-command-line-switches/#load-extension
#
# Repositories of older versions of Google Chrome:
# https://www.slimjet.com/chrome/google-chrome-old-version.php
# https://google-chrome.en.uptodown.com/ubuntu/old

CHROME_FLAGS="--password-store=basic --no-first-run";

PLASO_MSI="plaso-20180630.1.win32.msi";

test_chrome()
{
	CHROME_VERSION=$1;
	URL=$2;

	wget -O "google-chrome_${CHROME_VERSION}.deb" "${URL}";

	# Remove Google Chrome.
	sudo aptitude remove -y google-chrome-stable google-chrome-beta google-chrome-unstable

	# Remove cache and config directories.
	rm -rf "${HOME}/.cache/google-chrome";
	rm -rf "${HOME}/.config/google-chrome";

	# Install Google Chrome.
	sudo dpkg -i "google-chrome_${CHROME_VERSION}.deb";
	if test $? -ne 0;
	then
		echo "Unable to install version: ${CHROME_VERSION}";

		exit 1;
	fi

	rm -f "google-chrome_${CHROME_VERSION}.deb";

	google-chrome --version;

	# Run actions to create test data:
	google-chrome ${CHROME_FLAGS} https://raw.githubusercontent.com/dfirlabs/chrome-specimens/master/generate-specimens.sh &
	google-chrome ${CHROME_FLAGS} https://raw.githubusercontent.com/log2timeline/l2tbinaries/master/win32/${PLASO_MSI} &

	sleep 8;

	kill -15 `pgrep chrome | tr '\n' ' '` &>/dev/null;

	sleep 2;

	kill -9 `pgrep chrome | tr '\n' ' '` &>/dev/null;

	rm -f "${HOME}/Downloads/${PLASO_MSI}";

	# Preserve specimens.
	if ! test -d "specimens";
	then
		mkdir "specimens";
	fi
	tar Jcfv "specimens/google-chrome-${CHROME_VERSION}.tar.xz" "${HOME}/.config/google-chrome" "${HOME}/.cache/google-chrome";

	return ${EXIT_SUCCESS};
}

kill -9 `pgrep chrome | tr '\n' ' '` &>/dev/null;

# Install dependencies.
sudo apt-get update

sudo apt-get install -y aptitude libwww-perl

sudo aptitude update

MACHINE=`uname -m`;

DONWNLOAD_URL_FILTER="<a class=\"data download\" href=\"https://dw.uptodown.com/dwn/";

if test "${MACHINE}" = "x86_64";
then
	# Install dependencies.
	sudo aptitude install -y libindicator7 libappindicator1

	sudo aptitude upgrade libnss3 libnss3-1d sqlite3

	# NOTE: versions newer than 60.0.3112.90 seem to segfault on Ubuntu 14.04 64-bit.

	VERSIONS="68.0.3440.84 67.0.3396.79 66.0.3359.181 65.0.3325.181 64.0.3282.140 63.0.3239.108 62.0.3202.75 61.0.3163.79 60.0.3112.90 59.0.3071.86 58.0.3029.96 57.0.2987.133 56.0.2924.87 55.0.2883.75 54.0.2840.71 53.0.2785.116 52.0.2743.116 51.0.2704.84 50.0.2661.75 49.0.2623.75 48.0.2564.109";

	for VERSION in ${VERSIONS};
	do
		URL="https://www.slimjet.com/chrome/download-chrome.php?file=lnx%2Fchrome64_${VERSION}.deb";

		test_chrome "${VERSION}" "${URL}";
	done

	VERSION="42.0.2311.90";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/148005";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="41.0.2272.89";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/113089";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="40.0.2214.115";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/105795";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="39.0.2171.95";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/97075";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="38.0.2125.104";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/84387";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="37.0.2062.94";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/76997";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";
fi

if test "${MACHINE}" = "i686";
then
	# Note that upgrading libnss3 will brake older versions of Chrome.

	# Install dependencies.
	sudo aptitude install -y libindicator7 libappindicator1 libgconf2-4 libjpeg62

	VERSION="36.0.1985.143";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/74555";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="34.0.1847.116"
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/65857";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="32.0.1700.107";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/56724";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="31.0.1650.48";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/52639";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="27.0.1453.110";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/45507";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	# TODO: libudev0 which requires Ubuntu 12.04

	sudo aptitude install -y libxss1

	VERSION="25.0.1364.99";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/40995";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="24.0.1312.56";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/39767";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="23.0.1271.101"
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/38686";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="22.0.1229.79";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/35138";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="21.0.1180.81";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/33342";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="20.0.1132.57";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/31625";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="19.0.1084.52";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/29652";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="18.0.1025.168";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/28686";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="17.0.963.83";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/26838";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="16.0.912.77";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/24089";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="15.0.874.121";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/22648";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	# TODO: libnspr4-0d which requires Ubuntu 10.04

	sudo aptitude install -y xz-utils

	VERSION="14.0.835.186";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/21076";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="13.0.782.220";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/20780";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="12.0.742.124";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/20329";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="11.0.696.60";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/18878";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="10.0.648.205";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/18700";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="9.0.597.107";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/17570";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";

	VERSION="8.0.552.237";
	URL="https://google-chrome.en.uptodown.com/ubuntu/download/16454";

	URL=`GET ${URL} | grep "${DONWNLOAD_URL_FILTER}" | sed 's/.*href="\([^"]*\)".*/\1/'`;

	test_chrome "${VERSION}" "${URL}";
fi

# Remove Google Chrome.
sudo aptitude remove -y google-chrome-stable google-chrome-beta google-chrome-unstable

# Remove cache and config directories.
rm -rf "${HOME}/.cache/google-chrome";
rm -rf "${HOME}/.config/google-chrome";

