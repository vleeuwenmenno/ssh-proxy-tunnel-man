#!/bin/bash
APP_NAME="ssh-pt"
HOST=${@:2}
ACTION=$1

help_text() {
    echo "usage: $APP_NAME [action] ..."
    echo "    $APP_NAME up   [ssh-host]   - To open a SSH proxy tunnel"
    echo "    $APP_NAME down [ssh-host]   - To close a SSH proxy tunnel"
    echo "    $APP_NAME ps                - Shows currently opened tunnels"
    echo "    $APP_NAME help              - Shows this help message"
    echo "    $APP_NAME tutorial          - Shows detailed help message"
}

if [ "$ACTION" == "" ]; then
    echo "$APP_NAME: option requires an argument -- [action]"
    help_text
    exit 1
fi

if [ "$ACTION" == "help" ]; then
    help_text
    exit 1
fi

if [ "$ACTION" == "tutorial" ]; then
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
    if [ "$(ps aux | grep -w 'ssh -f -N -M -S /tmp/sshtunnel -D 1080' | grep -v 'grep')" == "" ]; then
        echo 'No SSH proxy tunnels currently opened.'
    else
        ps aux | grep -w 'ssh -f -N -M -S /tmp/sshtunnel -D 1080' | grep -v 'grep' | awk '{print $9 " - " $19}'
    fi
    exit 1
fi

if [ "$HOST" == "" ]; then
    echo "$APP_NAME: option requires an argument -- [ssh-host]"
    help_text
    exit 1
fi

if [ "$ACTION" == "down" ]; then
    if [ "$(ps aux | grep -w 'ssh -f -N -M -S /tmp/sshtunnel -D 1080 '$HOST | grep -v 'grep' | awk '{print $2}')" == "" ]; then
        echo 'No SSH proxy tunnel seems to be running for "'$HOST'"'
        exit 1
    else
        networksetup -setsocksfirewallproxystate Wi-fi Off
        kill $(ps aux | grep -w 'ssh -f -N -M -S /tmp/sshtunnel -D 1080 '$HOST | awk '{print $2}') > /dev/null 2>&1
        echo 'SSH proxy tunnel disabled for "'$HOST'"'
        exit 1
    fi
fi

if [ "$ACTION" == "up" ]; then
    echo "Opening SSH proxy tunnel, authenticate to finish opening the tunnel ..."

    if ssh -f -N -M -S /tmp/sshtunnel -D 1080 $HOST ; [ $? -eq 255 ]
    then
        echo "Unknown error opening SSH proxy tunnel. SSH exited abnormally, exit code: " $?
        exit 1
    else 
        networksetup -setsocksfirewallproxy Wi-fi 127.0.0.1 1080
        echo "SSH proxy tunnel succesfully opened."
        exit 1
    fi
fi

#!/bin/bash
APP_NAME="ssh-pt"
HOST=${@:2}
ACTION=$1

help_text() {
    echo "usage: $APP_NAME [action] ..."
    echo "    $APP_NAME up   [ssh-host]   - To open a SSH proxy tunnel"
    echo "    $APP_NAME down [ssh-host]   - To close a SSH proxy tunnel"
    echo "    $APP_NAME ps                - Shows currently opened tunnels"
    echo "    $APP_NAME help              - Shows this help message"
    echo "    $APP_NAME tutorial          - Shows detailed help message"
}

if [ "$ACTION" == "" ]; then
    echo "$APP_NAME: option requires an argument -- [action]"
    help_text
    exit 1
fi

if [ "$ACTION" == "help" ]; then
    help_text
    exit 1
fi

if [ "$ACTION" == "tutorial" ]; then
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
    if [ "$(ps aux | grep -w 'ssh -f -N -M -S /tmp/sshtunnel -D 1080' | grep -v 'grep')" == "" ]; then
        echo 'No SSH proxy tunnels currently opened.'
    else
        ps aux | grep -w 'ssh -f -N -M -S /tmp/sshtunnel -D 1080' | grep -v 'grep' | awk '{print $9 " - " $19}'
    fi
    exit 1
fi

if [ "$HOST" == "" ]; then
    echo "$APP_NAME: option requires an argument -- [ssh-host]"
    help_text
    exit 1
fi

if [ "$ACTION" == "down" ]; then
    if [ "$(ps aux | grep -w 'ssh -f -N -M -S /tmp/sshtunnel -D 1080 '$HOST | grep -v 'grep' | awk '{print $2}')" == "" ]; then
        echo 'No SSH proxy tunnel seems to be running for "'$HOST'"'
        exit 1
    else
        networksetup -setsocksfirewallproxystate Wi-fi Off
        kill $(ps aux | grep -w 'ssh -f -N -M -S /tmp/sshtunnel -D 1080 '$HOST | awk '{print $2}') > /dev/null 2>&1
        echo 'SSH proxy tunnel disabled for "'$HOST'"'
        exit 1
    fi
fi

if [ "$ACTION" == "up" ]; then
    echo "Opening SSH proxy tunnel, authenticate to finish opening the tunnel ..."

    if ssh -f -N -M -S /tmp/sshtunnel -D 1080 $HOST ; [ $? -eq 255 ]
    then
        echo "Unknown error opening SSH proxy tunnel. SSH exited abnormally, exit code: " $?
        exit 1
    else 
        networksetup -setsocksfirewallproxy Wi-fi 127.0.0.1 1080
        echo "SSH proxy tunnel succesfully opened."
        exit 1
    fi
fi

