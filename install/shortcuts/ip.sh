#!/bin/bash
xmessage `ifconfig wlan0 | grep 'inet ' | awk '{print $2}'`
