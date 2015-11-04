#!/bin/bash
# Author: Thomas F. Düllmann
# Description:
#  This script retrieves the latest (nightly/snaphot) Kieker binary version.
#  from the oss.sonatype.org repository. 
#  To achieve this the metadata files are read to find out the latest version .

# Greps the first given input ($1) with the second ($2), removes all HTML tags and removes spaces
function stripHtml {
  echo `cat $1 | grep $2 | sed -e 's/<[^>]*>//g' | tr -d " "`
}

BASE_URL="https://oss.sonatype.org/content/groups/staging/net/kieker-monitoring/kieker"

# Download base maven-metadata.xml to find out the latest version
TMP_FILE_1=`mktemp`
METADATA="$BASE_URL/maven-metadata.xml"
curl -s $METADATA > $TMP_FILE_1
LATEST_VERSION_SNAPSHOT=`stripHtml $TMP_FILE_1 "latest"`

# Housekeeping
rm $TMP_FILE_1

if [ -f Dockerfile ]; then
  sed -i "s%KIEKER_VERSION .*%KIEKER_VERSION $LATEST_VERSION_SNAPSHOT%g" Dockerfile
fi

