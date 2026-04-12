#!/bin/sh
free -h | awk '/Mem:/ {print $4 "/" $3 "/" $2}'
