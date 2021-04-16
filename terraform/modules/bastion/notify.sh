#!/bin/bash

if [[ "$(date +%u)" -lt 5 && \
	"$(date +%H)" -gt 8 && \
	"$(date +%H)" -lt 18 ]]; then
	exit 0
]]


if [ "$PAM_TYPE" != "close_session" ]; then
	subject="SSH Login: $PAM_USER logged into $(hostname) from $PAM_RHOST"	mailx -r "xxxxxxxx" \
	-s "SSH Login: $PAM_USER logged into $(hostname) from $PAM_HOST" \
	"$PAM_USER" << EOF
Last logins on $(hostname)
==========================
$(last -w -i)

Most recent auth.log
====================
$(tail /var/log/auth.log)
EOF
fi
