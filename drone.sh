#!/bin/bash

if [ -z "$PLUGIN_HOSTS" ]; then
  echo "Specify at least one host!"
  exit 1
fi

if [ -z "$PLUGIN_PORT" ]; then
  echo "Port not specified, using default port 22!"
  DEFAULT_PORT="22"
else
  DEFAULT_PORT=$PLUGIN_PORT
fi

if [ -z "$RSYNC_USER" ]; then
  if [ -z "$PLUGIN_USER" ]; then
    echo "No user specified, using root!"
    USER="root"
  else
    USER=$PLUGIN_USER
  fi
else
  USER=$RSYNC_USER
fi

if [ -z "$RSYNC_KEY" ]; then
  if [ -z "$PLUGIN_KEY" ]; then
    echo "No private key specified!"
      exit 1
    else
      SSH_KEY=$PLUGIN_KEY
    fi
else
  SSH_KEY=$RSYNC_KEY
fi

# Prepare SSH
home="/root"
mkdir -p "$home/.ssh"
printf "StrictHostKeyChecking no\n" > "$home/.ssh/config"
printf "ServerAliveInterval 30\n" >> "$home/.ssh/config"
printf "ServerAliveCountMax 120\n" >> "$home/.ssh/config"
chmod 0700 "$home/.ssh/config"
keyfile="$home/.ssh/id_rsa"
echo "$SSH_KEY" | grep -q "ssh-ed25519"

if [ $? -eq 0 ]; then
  printf "Using ed25519 based key\n"
  keyfile="$home/.ssh/id_ed25519"
fi

echo "$SSH_KEY" | grep -q "ecdsa-"

if [ $? -eq 0 ]; then
  printf "Using ecdsa based key\n"
  keyfile="$home/.ssh/id_ecdsa"
fi

echo "$SSH_KEY" > $keyfile
chmod 0600 $keyfile

function join_with { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }
# Parse SSH commands
IFS=','; read -ra COMMANDS <<< "$PLUGIN_SCRIPT"
script=$(join_with ' && ' "${COMMANDS[@]}")
# Run ssh
IFS=','; read -ra HOSTS <<< "$PLUGIN_HOSTS"
IFS=','; read -ra PORTS <<< "$PLUGIN_PORTS"
result=0

for ((i=0; i < ${#HOSTS[@]}; i++))
do
  HOST=${HOSTS[$i]}
    PORT=${PORTS[$i]}
    if [ -z $PORT ]
    then
    # Default Port 22
    PORT=$DEFAULT_PORT
    fi

    if [ -n "$PLUGIN_SCRIPT" ]; then
        echo $(printf "%s" "$ ssh -p $PORT $USER@$HOST ...")
        echo $(printf "%s" " > $script ...")
        eval "ssh -p $PORT $USER@$HOST '$script'"
        result=$(($result+$?))
        echo $(printf "%s" "$ ssh -p $PORT $USER@$HOST result: $?")
        if [ "$result" -gt "0" ]; then exit $result; fi
    fi
done
exit $result
