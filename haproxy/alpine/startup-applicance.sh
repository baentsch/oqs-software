#!/bin/sh

cd /opt/haproxy

# Start HAProxy:
/opt/oqssa/sbin/haproxy -D -f /opt/haproxy/haproxy.cfg

/bin/sh
