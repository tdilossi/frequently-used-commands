#!/bin/sh

dmgfile="flash.dmg"
volname="Flash"
logfile="/var/log/jamf.log"

latestver=`/usr/bin/curl --connect-timeout 8 --max-time 8 -sf "http://fpdownload2.macromedia.com/get/flashplayer/update/current/xml/version_en_mac_pl.xml" 2>/dev/null | xmllint --format - 2>/dev/null | awk -F'"' '/<update version/{print $2}' | sed 's/,/./g'`

# Get the version number of the currently-installed Flash Player, if any.
shortver=${latestver:0:2}
url="https://fpdownload.adobe.com/get/flashplayer/pdc/${latestver}/install_flash_player_osx.dmg"

# Determine if the installed version is older than the current version of Flash
flashPlayer="/Library/Internet Plug-Ins/Flash Player.plugin"

if [ ! -e "$flashPlayer" ]
    then
        currentinstalledver="0"
        echo "Flash Player is not installed"
    else
        currentinstalledver=`/usr/bin/defaults read "${flashPlayer}/Contents/version" CFBundleShortVersionString`
        echo "Flash Player v${currentinstalledver} is installed!"
fi

# Compare the two versions, if they are different then download and install the new version.
if [ "${currentinstalledver}" != "${latestver}" ]; then

    echo "Current Flash version: v${currentinstalledver}" >> ${logfile}
    echo "Available Flash version:  v${latestver}" >> ${logfile}

    echo "Downloading Flash Player v${latestver}." >> ${logfile}
    /usr/bin/curl -s -o `/usr/bin/dirname $0`/flash.dmg $url

    echo "Mounting installer disk image." >> ${logfile}
    /usr/bin/hdiutil attach `dirname $0`/flash.dmg -nobrowse -quiet

    echo "Installing..." >> ${logfile}
    /usr/sbin/installer -pkg /Volumes/Flash\ Player/Install\ Adobe\ Flash\ Player.app/Contents/Resources/Adobe\ Flash\ Player.pkg -target / > /dev/null
    /bin/sleep 10

    echo "Unmounting installer disk image." >> ${logfile}
    /usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep ${volname} | awk '{print $1}') -quiet
    /bin/sleep 10

    echo "Deleting disk image." >> ${logfile}
    /bin/rm `/usr/bin/dirname $0`/${dmgfile}

    newlyinstalledver=`/usr/bin/defaults read "/Library/Internet Plug-Ins/Flash Player.plugin/Contents/version" CFBundleShortVersionString`
    if [ "${latestver}" = "${newlyinstalledver}" ]; then
        echo "SUCCESS: Flash has been updated to version ${newlyinstalledver}" >> ${logfile}
    else
        echo "ERROR: Flash update unsuccessful, version remains at ${currentinstalledver}." >> ${logfile}
        echo "--" >> ${logfile}
    fi

# If Flash is already up to date, exit.    
else
    echo "Flash is already up to date, running ${currentinstalledver}." >> ${logfile}
fi

exit 0