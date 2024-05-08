#!/bin/sh
#
# Copyright (c) 2018-2020 Dave Hall <skwashd@gmail.com>
# MIT Licensed, see LICENSE for more information.
#

# Ensure certs are up to date
update-ca-certificates

# make saure we have the latest packages
/sbin/apk update
/sbin/apk upgrade