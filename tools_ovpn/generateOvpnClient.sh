#!/bin/bash

. "$(dirname ${0})/$(basename ${0} ".sh").conf"
export EASYRSA_PKI="${DIR_PKI}"

CN_NODE=""
if [ "${#}" -eq 1 ]
then
	CN_NODE="${1}"
else
	read -p "Enter CN node name for [${CN_BASE}]: " CN_NODE
fi

CN_FULL="${CN_NODE}.${CN_BASE}"
CN_OVPN="${DIR_CONF_OVPN}/${CN_NODE}.ovpn"
if [ -e "${CN_OVPN}" ]
then
	echo "OVPN profil already exists"
	exit 1
else
	cn_count=$(grep -rli "${CN_FULL}" "${DIR_PKI}" |wc -l)
	if [ 0 -ne "${cn_count}" ]
	then
		echo "Use of existing CN node [${CN_FULL}]"
	else
		${BIN_EASYRSA} build-client-full ${CN_FULL} nopass
	fi

	cp "${PATH_OVPN_TEMPLATE}" "${CN_OVPN}"
	echo "<ca>" >> "${CN_OVPN}"
	cat "${DIR_PKI}/ca.crt" >> "${CN_OVPN}"
	echo "</ca>" >> "${CN_OVPN}"
	echo "<tls-crypt>" >> "${CN_OVPN}"
	cat "${PATH_TLS_KEY}" >> "${CN_OVPN}"
	echo "</tls-crypt>" >> "${CN_OVPN}"
	echo "<cert>" >> "${CN_OVPN}"
	sed -ne '/BEGIN CERTIFICATE/,$ p' "${DIR_PKI}/issued/${CN_FULL}.crt" >> "${CN_OVPN}"
	echo "</cert>" >> "${CN_OVPN}"
	echo "<key>" >> "${CN_OVPN}"
	cat "${DIR_PKI}/private/${CN_FULL}.key" >> "${CN_OVPN}"
	echo "</key>" >> "${CN_OVPN}"
fi

exit 0

