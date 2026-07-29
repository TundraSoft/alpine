#!/bin/sh
# Health check script for S6-based container
# Validates that the S6 supervisor (s6-svscan) is running
# Requires root access to read full process list

ps aux | grep -q '[s]6-svscan' || exit 1
