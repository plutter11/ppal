#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server_2
# Image to install with is 'ghcr.io/parkervcp/installers:debian'


# Install packages. Default packages below are not required if using our existing install image thus speeding up the install process.
#apt -y update
#apt -y --no-install-recommends install curl lib32gcc-s1 ca-certificates

SRCDS_APPID=2394010

## just in case someone removed the defaults.
if [[ "${STEAM_USER}" == "" ]] || [[ "${STEAM_PASS}" == "" ]]; then
    echo -e "steam user is not set.\n"
    echo -e "Using anonymous user.\n"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "user set to ${STEAM_USER}"
fi

## download and install steamcmd
cd /tmp
mkdir -p /mnt/server_2/steamcmd
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server_2/steamcmd
mkdir -p /mnt/server_2/steamapps # Fix steamcmd disk write error when this folder is missing
cd /mnt/server_2/steamcmd

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server_2

## install game using steamcmd
./steamcmd.sh +force_install_dir /mnt/server_2 +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update ${SRCDS_APPID} $( [[ -z ${SRCDS_BETAID} ]] || printf %s "-beta ${SRCDS_BETAID}" ) $( [[ -z ${SRCDS_BETAPASS} ]] || printf %s "-betapassword ${SRCDS_BETAPASS}" ) ${INSTALL_FLAGS} validate +quit ## other flags may be needed depending on install. looking at you cs 1.6

## set up 32 bit libraries
mkdir -p /mnt/server_2/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server_2/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

## add below your custom commands if needed
## copy template config file
echo "Copy template config file into config folder!"

sed -i 's/bIsUseBackupSaveData=True/bIsUseBackupSaveData=False/g' /mnt/server_2/DefaultPalWorldSettings.ini

cp /mnt/server_2/DefaultPalWorldSettings.ini /mnt/server_2/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini


## install end
echo "-----------------------------------------"
echo "Installation completed..."
echo "-----------------------------------------"