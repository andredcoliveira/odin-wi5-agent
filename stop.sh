#!/bin/sh

echo "Killing Click"
kill $(pgrep click) >/dev/null 2>&1

echo "Cleaning old Click files"
rm mon* >/dev/null 2>&1

## OVS
$OVS_CTL status >/dev/null 2>&1
if [ $? == 0 ]; then
  echo "Resetting OpenvSwitch"
  # Reset the configuration into a clean state
  $OVS_VSCTL emer-reset
fi
