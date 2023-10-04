#!/usr/bin/env bash

source `dirname $0`/bootstrap/env.sh

if [ -z "$WORKSPACE" ] || [ -z "$RTE_SDK" ] || [ -z "$RTE_TARGET" ] ; then
  echo "Environment variables not properly set. Did you run $(dirname $0)/env.sh?"
  exit 1
fi

# enable debugging (./build.sh -d)
CMAKE_BUILD_TYPE=RelWithDebInfo
while getopts "d" OPTION; do
  case $OPTION in
  d)
    CMAKE_BUILD_TYPE=Debug
    ;;
  *)
    echo "Invalid arguments"
    exit 1
    ;;
  esac
done

mkdir -p $WORKSPACE/build
cd $WORKSPACE/build
cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_PREFIX_PATH=${RTE_SDK}/${RTE_TARGET}/lib/x86_64-linux-gnu/pkgconfig/ ..
make -j
