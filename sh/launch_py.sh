#!/bin/bash
if [ $# -eq 0 ]; then
  echo "No Arg Found";
  exit 0;
else
  python ../src/__init__.py "${1}"
fi
exit 0;