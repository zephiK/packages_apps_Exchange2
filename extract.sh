#!/bin/bash

# Script to OptiCharge and decompress Google Exchange2 APK 
# Usage : ./extract.sh /path/to/com.google.android.gm.exchange*.apk
#
# http://www.apkmirror.com/apk/google-inc/exchange-services/

EXCHANGE=$(cat VERSION)
if ! apktool d -f -s "$@" 1>/dev/null; then
	echo "Failed to extract with apktool!"
	exit 1
fi
EXCHANGEDIR=$(\ls -d com.google.android.gm.exchange* || (echo "Input file is not an Exchange2 apk!" ; exit 1))

NEWEXCHANGE=$(cat $EXCHANGEDIR/apktool.yml | grep versionName | awk '{print $2}')
if [[ $NEWEXCHANGE != $EXCHANGE ]]; then
	echo "Updating current Exchange $EXCHANGE to $NEWEXCHANGE ..."
	echo $NEWEXCHANGE > VERSION
	rm Exchange2.apk
	rm -rf $EXCHANGEDIR
	7z x -otmp "$@" 1>/dev/null
	cd tmp
	find . -name '*.png' -print0 | xargs -0 -P8 -L1 pngquant --ext .png --force --speed 1
	7z a -tzip -mx0 ../tmp.zip . 1>/dev/null
	cd ..
	rm -rf tmp
	zipalign -v 4 tmp.zip Exchange2.apk 1>/dev/null
	rm tmp.zip
	rm -rf Exchange
else
	echo "Input Exchange apk is the same version as before."
	echo "Not updating ..."
fi
rm -rf $EXCHANGEDIR
