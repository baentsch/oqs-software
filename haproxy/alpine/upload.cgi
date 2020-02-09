#!/bin/sh

echo "Content-type: text/html"
echo ""

echo '<html>'
echo '<head>'
echo '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
echo '<title>Just a simple POST test</title>'
echo '</head>'
echo '<body>'

echo "<p>Start</p>"

if [ "$REQUEST_METHOD" = "POST" ]; then
    echo "<p>Post Method</p>"
    if [ "$CONTENT_LENGTH" -gt 0 ]; then
	echo "Received OK $CONTENT_LENGTH bytes"
    #in_raw=`cat`
    #echo "in_raw: $in_raw"
    fi
fi
echo '</body>'
echo '</html>'

exit 0

