#!/bin/sh

if [ "$(sudo subscription-manager status| grep "Overall Status")" != "Overall Status: Unknown" ]; then
clear
echo "Properly Registered"
else
clear
 
echo -e "\033[32mRed Hat Registration - Start\033[0m"
    if [ -z ${1+x} ]; then
        echo -e "\033[01m\e[4mType your username for RedHat.com, followed by [ENTER]:\e[0m\033[0m"
        read rhUser
    else
        declare rhUser=$1
    fi
    if [ -z ${2+x} ]; then
        echo -e "\033[01m\e[4mType your password for RedHat.com, followed by [ENTER]:\e[0m\033[0m"
        read -s rhPass
    else
        declare rhPass=$2
    fi
    clear
    echo -e "\033[32mSet Server Hostname - Start\033[0m"
    if [ -z ${3+x} ]; then
        echo -e "\033[01m\e[4mType your desired hostname for the server, followed by [ENTER]:\e[0m\033[0m"
        read hostname
        sudo hostnamectl set-hostname $hostname
    else
        declare hostname=$3
        sudo hostnamectl set-hostname $hostname
    fi
    echo -e "\033[32mSet Server Hostname - Stop\033[0m"
    # Register Red Hat Server - Start
    
    # Default was auto-attach - for my use I don't want this
    # sudo subscription-manager register --username $rhUser --password $rhPass --auto-attach
    sudo subscription-manager register --username $rhUser --password $rhPass
    
    clear
    sudo subscription-manager refresh
    clear
    history -c
    sudo subscription-manager identity
    # Register Red Hat Server - Stop
    echo -e "\033[32mRed Hat Registration - Stop\033[0m"
 
fi
