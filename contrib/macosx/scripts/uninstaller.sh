#!/bin/bash

cd "${0%/*}"
INSTALLPATH="`pwd`"
cd ..

echo "Stopping and unloading service"
sudo launchctl stop com.teclib.assetsync-agent
sudo launchctl unload /Library/LaunchDaemons/com.teclib.assetsync-agent.plist

# Still wait until process has been stopped
read PID XXX <<<`ps -ec -o pid,command | grep assetsync-agent`
if [ "$PID" !=  "" ]; then
    let TIMEOUT=300
    while sudo kill -0 $PID 2>/dev/null
    do
        sleep .1
        (( --TIMEOUT )) || break
    done
    if [ "$TIMEOUT" == "0" ]; then
        echo "killing process: $PID"
        sudo kill $PID
    fi
fi

echo "Saving conf.d content, just in case"
if [ -d "$INSTALLPATH/etc/conf.d" ]; then
    cp -af "$INSTALLPATH/etc/conf.d" /tmp
fi

while read FILE
do
  echo "removing '$FILE'"
  [ -n "$FILE" -a -e "$FILE" ] || continue
  sudo rm -f -R "$FILE"
done <<-FILES
    $INSTALLPATH
    /var/log/assetsync-agent.log
    /usr/local/bin/dmidecode
    /Library/LaunchDaemons/com.teclib.assetsync-agent.plist
FILES

# Unregister package
sudo pkgutil --forget com.teclib.assetsync-agent $INSTALLPATH
