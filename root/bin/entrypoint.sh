#!/bin/sh

set -e

if [ -z $1 ]; then
    bin/console theme:compile || true
    exec busybox init
elif [ -e bin/console ]; then
    bin/console $@
else
    php $@
fi
