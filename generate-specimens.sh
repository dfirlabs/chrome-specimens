#!/bin/bash
#
# Script to generate Google Chrome/Chromium test files
# Requires a 32-bit or 64-bit version of Ubuntu 14.04
#
# Reference of Google Chrome/Chromium command line options:
# https://peter.sh/experiments/chromium-command-line-switches/#load-extension
#
# Repositories of older versions of Google Chrome/Chromium:
# https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html

EXIT_SUCCESS=0;
EXIT_FAILURE=1;

CHROMIUM_FLAGS="--password-store=basic --no-first-run";

PLASO_MSI="plaso-20180630.1.win32.msi";

test_chromium()
{
	local CHROME_VERSION=$1;
	local BASE_POSITION=$2;

	local URL="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/linux_rel%2F${BASE_POSITION}%2Fchrome-linux.zip?alt=media";

	wget -O "chromium-${CHROME_VERSION}.zip" "${URL}";

	# Remove Google Chrome/Chromium.
	rm -rf chrome-linux;

	# Remove cache and config directories.
	rm -rf "${HOME}/.cache/chromium";
	rm -rf "${HOME}/.config/chromium";

	# Install Google Chrome/Chromium.
	unzip -x "chromium-${CHROME_VERSION}.zip";

	rm -f "chromium-${CHROME_VERSION}.zip";

	chrome-linux/chrome --version;

	# Run actions to create test data.
	chrome-linux/chrome ${CHROMIUM_FLAGS} https://raw.githubusercontent.com/dfirlabs/chrome-specimens/master/generate-specimens.sh &
	chrome-linux/chrome ${CHROMIUM_FLAGS} https://raw.githubusercontent.com/log2timeline/l2tbinaries/master/win32/${PLASO_MSI} &

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
	tar Jcfv "specimens/chromium-${CHROME_VERSION}.tar.xz" "${HOME}/.config/chromium" "${HOME}/.cache/chromium";

	return ${EXIT_SUCCESS};
}

MACHINE=`uname -m`;

if test "${MACHINE}" != "i686" && test "${MACHINE}" != "x86_64";
then
	echo "Unsupported architecture: ${MACHINE}";

	exit ${EXIT_FAILURE};
fi

# Install dependencies.
sudo apt-get update

sudo apt-get install -y aptitude libwww-perl

sudo aptitude update

sudo aptitude upgrade libnss3

kill -9 `pgrep chrome | tr '\n' ' '` &>/dev/null;

CHROME_VERSIONS=`git ls-remote --tags https://github.com/chromium/chromium.git | sed 's?^.*refs/tags/??' | grep -e '[0-9][0-9]*[.][0-9][0-9]*[.][0-9][0-9]*[.][0-9][0-9]*' | sort -nr`;

LAST_BASE_POSITION=0;

for CHROME_VERSION in ${CHROME_VERSIONS};
do
	URL="https://omahaproxy.appspot.com/deps.json?version=${CHROME_VERSION}";

	# TODO: handle '"chromium_base_position": null'
	BASE_POSITION=`GET ${URL} | grep '"chromium_base_position":' | sed 's/^.* "chromium_base_position": "\([0-9][0-9]*\)", .*$/\1/'`;

	if test -z "${BASE_POSITION}";
	then
		echo "No base position found for Chrome: ${CHROME_VERSION}";

		continue;
	fi
	if test ${BASE_POSITION} -eq ${LAST_BASE_POSITION};
	then
		continue;
	fi
	LAST_BASE_POSITION=${BASE_POSITION};

	# CONTENT=`GET https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html?prefix=Linux/${BASE_POSITION}/ | grep "chrome-linux.zip"`;

	URL="https://www.googleapis.com/storage/v1/b/chromium-browser-snapshots/o?delimiter=/&prefix=Linux/${BASE_POSITION}/&fields=items(kind,mediaLink,metadata,name,size,updated),kind,prefixes,nextPageToken";
	CONTENT=`GET ${URL}/ | grep "chrome-linux.zip"`;

	if test -z "${CONTENT}";
	then
		echo "No chrome-linux.zip found for Chrome: ${CHROME_VERSION}, base position: ${BASE_POSITION}";

		continue;
	fi
	test_chromium ${CHROME_VERSION} ${BASE_POSITION};
done

# Remove cache and config directories.
rm -rf "${HOME}/.cache/chromium";
rm -rf "${HOME}/.config/chromium";

exit ${EXIT_SUCCESS};

