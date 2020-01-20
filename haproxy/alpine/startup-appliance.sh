#!/bin/sh

cd /opt/haproxy

if [ $# -eq 1 ]; then
   # server name as sole optional parameter
   sed -i "s/my.ha.proxy/$1/g" /opt/haproxy/haproxy.cfg 
fi

# Start HAProxy:
/opt/oqssa/sbin/haproxy -f /opt/haproxy/haproxy.cfg

