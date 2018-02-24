#!/bin/sh -x
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

if [ $# -lt 2 ]; then
	echo "invalid arguments"
	echo "command SOURCE DESINATION [type] [whitelist]"
	exit 1
fi

while IFS= read -r list
do
	if echo "$list" | grep -qv "^#\|^$"; then
		pull $list > $LTMP
		if [ -f $LTMP ]; then
			if grep -q "||.*^" $LTMP; then
				# its easy list
				logger "processing easylist file from $list as $LTMP"
				grep -v "^#" $LTMP | sed -n "s/||\(.*\)\^.*/\1/p" | grep -v "@@" >>$TMP
			else
				# its not an easy list
				logger "processing dns list file from $list as $LTMP"
				grep -v "^#" $LTMP | sed -e "s/127.0.0.1//g" -e "s/0.0.0.0//g" | tr -d "[:blank:]">>$TMP
			fi
			rm "$LTMP"
		fi
	fi
done <"$1"

# and complete
if [ -f $TMP ]; then
	logger "complete... new file located at $2"
	if [ -f $4 ]; then
		while IFS= read -r whitelist
		do
			echo "removing $whitelist from final list due to being whitelisted"
			sed -i "/$whitelist/d" $TMP
		done < "$4"
	fi
	if [ $# -gt 2 -a "$3" == "plain" ]; then
		cat $TMP | sort | uniq > $2
	else
		cat $TMP | sort | uniq | sed -e "s/^\(.*\)/0.0.0.0 \1/g" > $2
	fi
	if [ -f "$2" ]; then
		rm "$TMP" 2>/dev/null
	fi
else
	logger "completed temp file is missing, cannot copy to destination"
fi
