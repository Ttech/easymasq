# easymasq
Because sometimes you don't need the entire pi to block ads

## what is it?
easymasq is a simple script designed to pull from AdBlock Plus / UBlock Domain Lists or DNS Host Files (PiHole) and generate merged host file for use in DNSMASQ or /etc/hosts.

## why make a script when Pi Hole exists?
this tool is meant to be used on very lightweight systems, or when you do not wish to need many dependencies. it requires almost no resources and does not automate anything. that is left to your discretion, meaning you can set it up to run daily, weekly, monthly, or manually. 

## why didn't you use getopt(s)?
because many embedded systems use busybox, toybox, or similar lightweight environments getopt may not exist in every situation. i tried to keep the commands simple, so it shouldn't cause too much trouble. eventually i'll find a way to add getopt in a way that will allow it to gracefully fail.

## how do you use it?
its pretty simple, just run the command 
```
chmod +x easymasq.sh
./easymasq BLOCKLIST HOSTFILE
```
some may have noticed it has an optional parameter
```
./easymasq BLOCKLIST HOSTFILE plain
```
this will output a hostname only list, useful for further processing or effort from another script.

