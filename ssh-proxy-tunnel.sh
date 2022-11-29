#!/bin/bash
APP_NAME="ssh-pt"
ACTION=$1; shift
CTRLSOCK='/tmp/sshtunnel'

help_text() {
    echo "usage: $APP_NAME [action] ..."
    echo "    $APP_NAME up [-a:macOS network service] [-h:ssh-host] - To open a SSH proxy tunnel"
    echo "    $APP_NAME down [-h:ssh-host]                          - To close a SSH proxy tunnel"
    echo "    $APP_NAME ps                                          - Shows currently opened tunnels"
    echo "    $APP_NAME help                                        - Shows this help message"
    echo "    $APP_NAME howto                                       - Shows how-to help message"
}

if [ "$ACTION" == "help" ]; then
    help_text
    exit 1
fi

if [ "$ACTION" == "howto" ]; then
    help_text
    echo ''
    echo "It's quite simple, just make sure you can SSH into your remote server and you're good to go."
    echo " - $APP_NAME up username@example.com [optional ssh args...]"
    echo ''
    echo "In case you don't have direct access to your server and can't port forward I recommend using one of the following services:"
    echo " - https://tailscale.com/download/    - TailScale"
    echo " - https://www.zerotier.com/download/ - ZeroTier"
    echo ''
    echo 'I am not affiliated with any of these companies but just like using their services. There might be better options out there so do your own research!'
    exit 1
fi

if [ "$ACTION" == "ps" ]; then
    if [ "$(ps aux | grep -w 'ssh -f -N -M -S' | grep -v 'grep')" == "" ]; then
        echo 'No SSH proxy tunnels currently opened.'
    else
        ps aux | grep -w 'ssh -f -N -M -S' | grep -v 'grep' | awk '{print $9" "$19" "$16}' | column -t
    fi
    exit 1
fi

while getopts ":a:h:v" opt; do
  case $opt in
    a) NETWORKSERVICE="$OPTARG";;
    h) HOST="$OPTARG";;
    v) VERBOSE="1";;
    \?) echo "Invalid option -$OPTARG" >&2 exit 1 ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

if [ "$NETWORKSERVICE" == "" ]; then
    NETWORKSERVICE="Wi-Fi"
fi

if [ "$NETWORKSERVICE" != "" ]; then
    if [ "$(networksetup -listallnetworkservices | grep -w "$NETWORKSERVICE")" == "" ]; then
        echo "Unknown network service \""$NETWORKSERVICE"\""
        echo "Available services: "
        networksetup -listallnetworkservices 
        exit 1
    fi
fi

if [ "$HOST" == "" ]; then
    HOST=$1
fi

if [ "$HOST" == "" ]; then
    echo "$APP_NAME: option requires an argument -- [ssh-host]"
    help_text
    exit 1
fi

CTRLSOCK=$HOST

# Take first part of host as socket path
CTRLSOCK=$(echo $CTRLSOCK | awk '{print $1}')

# Remove @ sign from path
CTRLSOCK=${CTRLSOCK//[@]/_}
CTRLSOCK='/tmp/'$CTRLSOCK'.socket'


if [ "$ACTION" == "" ]; then
    echo "$APP_NAME: option requires an argument -- [action]"
    help_text
    exit 1
fi

if [ "$VERBOSE" == "1" ]; then
    echo 'Network service: '$NETWORKSERVICE
    echo 'Host: '$HOST
    echo 'Action: '$ACTION
    echo 'Control socket: '$CTRLSOCK
fi

if [ "$ACTION" == "down" ]; then
    if [ "$(ps aux | grep -w 'ssh -f -N -M -S '"$CTRLSOCK"' -D 1080 '$HOST | grep -v 'grep' | awk '{print $2}')" == "" ]; then
        echo 'No SSH proxy tunnel seems to be running for "'$HOST'"'
        exit 1
    else
        if [[ "$OSTYPE" == "darwin"* ]]; then
            networksetup -setsocksfirewallproxystate $NETWORKSERVICE Off
        else
            echo 'System is not macOS, please manually disable your SOCKS v5 proxy.'
        fi
        kill $(ps aux | grep -w 'ssh -f -N -M -S '"$CTRLSOCK"' -D 1080 '$HOST | awk '{print $2}') > /dev/null 2>&1
        echo 'SSH proxy tunnel disabled for "'$HOST'"'
        exit 1
    fi
fi

if [ "$ACTION" == "up" ]; then
    if [ "$(ps aux | grep -w 'ssh -f -N -M -S '"$CTRLSOCK"' -D 1080 '"$HOST" | grep -v 'grep' | awk '{print $2}')" == "" ]; then
        echo "Opening SSH proxy tunnel, authenticate to finish opening the tunnel ..."

        if ssh -f -N -M -S $CTRLSOCK -D 1080 $HOST ; [ $? -eq 255 ]
        then
            echo "Unknown error opening SSH proxy tunnel. SSH exited abnormally, exit code: " $?
            exit 1
        else 
            if [[ "$OSTYPE" == "darwin"* ]]; then
                networksetup -setsocksfirewallproxy $NETWORKSERVICE 127.0.0.1 1080
            else
                echo 'System is not macOS, please manually setup your SOCKS v5 proxy.'
            fi

            echo "SSH proxy tunnel succesfully opened."
            exit 1
        fi
    else
        echo 'SSH proxy tunnel already seems to be running for "'$HOST'"'
        exit 1
    fi
fi

