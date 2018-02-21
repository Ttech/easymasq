#!/bin/sh
# a simple, easy to use shell downloader
# you will need wget or curl, sed, and tr to make this run
# supports easylist files and adblock/dns blacklisting files (host files etc)

# feel free to change these temp files
TMP="/tmp/easymasqlist.tmp" # total temp for final processing
LTMP="/tmp/easymasq.genlist" # current list temp

#TODO: update this to make it a bit more powerful when checking for pull request
pull(){
	which curl > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		curl -s "$1"
	else
		wget -q $1 -O -
	fi
}

if [ $# -ne 2 ]; then
	echo "invalid arguments"
	echo "command [SOURCE LIST] [DESTINATION]"
	exit 1
fi

while IFS= read -r list
do
	if echo "$list" | grep -qv "^#\|^$"; then
		pull $list > $LTMP
		if [ -f $LTMP ]; then
			if grep -q "||.*^" $LTMP; then
				# its easy list
				echo "processing easylist file from $list as $LTMP"
				grep -v "^#" $LTMP | sed -n "s/||\(.*\)\^.*/\1/p">>$TMP
			elif grep -q "address="; then
				# its a dnsmasq list
				grep -v "^#" $LTMP | sed -n "s/address=\/\(.*\)\/.*/\1/p">>$TMP
			else
				# its not an easy list
				echo "processing dns list file from $list as $LTMP"
				grep -v "^#" $LTMP | sed -e "s/127.0.0.1//g" -e "s/0.0.0.0//g" | tr -d "[:blank:]">>$TMP
			fi
			rm "$LTMP"
		fi
	fi
done <"$1"

# and complete
if [ -f $TMP ]; then
	echo "complete... new file located at $2"
	if [ $# -gt 2 -a "$3" == "plain" ]; then
		cat $TMP | sort | uniq > $2
	else
		cat $TMP | sort | uniq | sed -e "s/^\(.*\)/0.0.0.0 \1/g" > $2
	fi
	if [ -f "$2" ]; then
		rm "$TMP" 2>/dev/null
	fi
else
	echo "completed temp file is missing, cannot copy to destination"
fi
