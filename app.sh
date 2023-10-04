#!/usr/bin/env bash

source `dirname $0`/bootstrap/env.sh

if [ -z "$WORKSPACE" ] || [ -z "$RTE_SDK" ] || [ -z "$RTE_TARGET" ] ; then
  echo "Environment variables not properly set. Did you run $(dirname $0)/bootstrap/env.sh?"
  exit 1
fi

APP_BINARY=$WORKSPACE/build/example

if [ ! -f "$APP_BINARY" ] ; then
  echo  "$APP_BINARY not found. Did you run $(dirname $0)/build.sh?"
  exit 1
fi

nr_hugepages=`cat /proc/sys/vm/nr_hugepages`
if [ "$nr_hugepages" -le "0" ] ; then
  echo "Hugepages not configured. Did you run $(dirname $0)/bootstrap/hugepages.sh?"
  exit 1
fi

LD_LIBRARY_PATH="$RTE_SDK/$RTE_TARGET/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH" $APP_BINARY "$@"
