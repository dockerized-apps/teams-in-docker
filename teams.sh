#!/bin/bash

CONTAINER_HOME=~/.local/share/x11docker/teams
CONSTAINER_NAME="teams"

# check if ${CONSTAINER_NAME} container is running and use existing container if so
if docker exec "${CONSTAINER_NAME}" true >/dev/null 2>&1; then
	docker exec "${CONSTAINER_NAME}" "${CONSTAINER_NAME}" "$@"
	exit $?
fi

if [[ "$(docker images -q '${CONSTAINER_NAME}' 2>/dev/null)" == "" ]]; then
	echo "building image ${CONSTAINER_NAME}"
	docker build --pull -t "${CONSTAINER_NAME}" .
else
	echo "image ${CONSTAINER_NAME} already exists"
fi

# ensure xdg socket is setup correctly
rm -f "$CONTAINER_HOME/.xdg.sock"
mkdir -p "$CONTAINER_HOME"
if ! mkfifo "$CONTAINER_HOME/.xdg.sock"; then
	echo "Failed to create $CONTAINER_HOME/.xdg.sock for xdg-open integration" >&2
	exit 1
fi

# read loop for opening urls with xdg
while [ -p "$CONTAINER_HOME/.xdg.sock" ]; do
	read url <"$CONTAINER_HOME/.xdg.sock"
	xdg-open "$url"
done &

x11docker --pulseaudio --webcam --hostdisplay --clipboard --gpu --env LANG --home="$CONTAINER_HOME" --name "${CONSTAINER_NAME}" -- "${CONSTAINER_NAME}" /usr/share/teams/teams --disable-namespace-sandbox --disable-setuid-sandbox "$@"

# cleanup xdg socket
kill %1 # kill xdg-open loop
rm -f "$CONTAINER_HOME/.xdg.sock"
