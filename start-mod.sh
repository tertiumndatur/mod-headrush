#!/bin/sh

killall jackd

eval $(dbus-launch --sh-syntax)

cleanup() {
    echo "Terminating processes..."
    kill "$JACKD_PID" "$MOD_HOST_PID" "$SERVER_PID" 2>/dev/null
    wait "$JACKD_PID" 2>/dev/null
    wait "$MOD_HOST_PID" 2>/dev/null
    wait "$SERVER_PID" 2>/dev/null
    exit
}

trap cleanup EXIT INT


jackd -R -d alsa -d hw:HG02 -p 128 &
JACKD_PID=$!

sleep 1

/usr/mod-headrush/mod-host -n -p 5555 -f 5556 &
MOD_HOST_PID=$!

sleep 1

export MOD_DEV_ENVIRONMENT=0
export MOD_USER_FILES_DIR=/usr/mod-headrush/mod-user-data

python3 /usr/mod-headrush/mod-ui/server.py &
SERVER_PID=$!


wait $SERVER_PID