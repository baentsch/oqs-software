#!/bin/bash

cd ../alpine 

# So we can be called from both alpine and ..:
if [ $? -ne 0 ]; then
   cd alpine
fi

docker build -t haproxy-alpine .

cd ..
