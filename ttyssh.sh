#!/bin/bash

ssh -i /KioskAndMgr/keys/ttymgr_key root@$(mysql ttymgr -e "select ip from enrolled where cn='${1}.labs.ulukai.net'"|column -t|sed '1d')

