#!/bin/bash
#    Checks if Midori, XSettings and Unclutter are running and starts them if they aren't
#
#    Copyright (C) 2013  Andrew Fryer (flamewave000)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

ConcertoServerIP="http://dev-signage.manhattan.edu/frontend"
ConcertoServerMajorVer=2
ConcertoScreenNumber=1

source signage.conf
#LOG="./digitalsignage.log"
LOG="/dev/null"
empty=""

/bin/date > $LOG

if [ "$ConcertoServerMajorVer" -eq 2 ]; then
  ConcertoServerIP="$ConcertoServerFrontendURL/$ConcertoScreenNumber"
elif [ "$ConcertoServerMajorVer" -eq 1 ]; then
  ConcertoServerIP="$ConcertoServerFrontendURL/?mac=$ConcertoScreenNumber"
else
  ConcertoServerIP=$ConcertoServerFrontendURL
fi



#This checks to see if Midori is running
result=`/bin/ps -A | /bin/grep -o -E "midori"`
if [ "$result" == "$empty" ]; then
    #if not running (the return is empty) then start Midori and send it to Concerto
    /bin/echo Midori: Not running. >> $LOG
    #Obtain computer's MAC address
    mac=`/sbin/ifconfig | /bin/grep -o -E "[a-zA-Z0-9]{2}(:[a-zA-Z0-9]{2}){5}" | sed 's/://g'`
    /bin/echo -n Midori: starting browser @ $ConcertoServerIP ... >> $LOG
    #Start Midori in fullscreen mode
    /usr/bin/midori -e Fullscreen -a $ConcertoServerIP &>> $LOG &
    /bin/echo Done. >> $LOG
else
    /bin/echo Midori: Running. >> $LOG
fi

#Check if XSettings is running
result=`/usr/bin/xset q | /bin/grep -o -E "prefer blanking:[ ]*.*[ ]* allow" | /bin/grep -o -E "no"`
if [ "$result" == "$empty" ]; then
    #if it is not running, start it
    /bin/echo -n XSet: Screen blanking is turned on. Turning off... &>> $LOG
    /usr/bin/xset s off &>> $LOG
    /usr/bin/xset -dpms &>> $LOG
    /usr/bin/xset s noblank &>> $LOG
    /bin/echo done.
else
    /bin/echo XSet: Screen blanking is disabled. &>> $LOG
fi

#Check if Unclutter is running
result=`/bin/ps -A | /bin/grep -o -E "unclutter"`
if [ "$result" == "$empty" ]; then
    #if it is not running, start it
    /bin/echo Unclutter is not running. Starting Unclutter... &>> $LOG
    /usr/bin/unclutter -idle 1 &>> $LOG
    /bin/echo Done.
else
    /bin/echo Unclutter: Running. &>> $LOG
fi
