#!/bin/bash

if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    sudo apt-get install -y  \
       libc6-dev make \
       autoconf libtool pkg-config \
       libxml2 apache2-dev

    # dirty hack to get Swift module for APR working on Linux
    head -n -6 /usr/include/apr-1.0/apr.h > /tmp/zz-apr.h
    echo ""                              >> /tmp/zz-apr.h
    echo "// mod_swift build hack"       >> /tmp/zz-apr.h
    echo "typedef int pid_t;"            >> /tmp/zz-apr.h
    tail -n 6 /usr/include/apr-1.0/apr.h >> /tmp/zz-apr.h
    sudo mv /usr/include/apr-1.0/apr.h /usr/include/apr-1.0/apr-original.h
    sudo mv /tmp/zz-apr.h /usr/include/apr-1.0/apr.h
    # cat /usr/include/apr-1.0/apr.h # testing
else
  echo "OS: $TRAVIS_OS_NAME"
  brew update
  brew install httpd
fi
