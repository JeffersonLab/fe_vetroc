#!/bin/sh
# Usage: gtp_burn_firmware.sh firmware_filename.rbf
dd if=$1 of=/dev/mtdblock5 bs=4k
sync