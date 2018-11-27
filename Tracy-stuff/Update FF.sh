#!/bin/sh
# updateFirefox.sh
#to determine if there's a update for Firefox and, if there is, deploy it
#
#to show script startup in maint_logfile
echo 'start updateFirefox.sh'
#

date
#

ffv=$(/Applications/Firefox.app/Contents/MacOS/firefox -v)
set -- $ffv
ffvn=$3
echo "Installed Firefox version is $ffvn"

# somehow find current version
curl -O FireFox*.dmg "https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US" > /tmp/firefox.txt

# parse text file to find dmg file name and version
nffvf=$(grep dmg /tmp/firefox.txt | sed 's/.*href=\"\(.*.dmg\).>.*/\1/')
nffv=$(grep dmg /tmp/firefox.txt | sed 's/.*releases.\(.*\).mac.*/\1/')

echo "Latest Firefox version is $nffv"
if  [[ "$ffvn" < "$nffv" ]] ; then
echo Updating Firefox to $nffv from $ffvn
#download actual dmg file
echo Getting "$nffvf"
curl -o /tmp/Firefox.dmg "$nffvf"

#mount dmg
hdiutil mount -nobrowse "/tmp/Firefox.dmg"
if [ $? = 0 ]; then   # if mount is successful

#remove previous version of firefox
if [ -d /Applicarions/Firefox.app ]; then
rm -rd /Applications/Firefox.app
fi

#install new version
cp -R /Volumes/Firefox/Firefox.app /Applications
sleep 15
#Unmount
hdiutil detach /Volumes/Firefox
sleep 5
    fi

#remove files
rm /tmp/Firefox.dmg

fi
rm /tmp/firefox.txt
echo 'end updateFirefox.sh'
exit 0