#!/bin/bash

me=$(basename "$0")
if pidof -o %PPID -x "$me" >/dev/null; then
    #Another script instance is already running.
    exit 1
fi

dontstarve_dir="$HOME/.klei/DoNotStarveTogether"
install_dir="$dontstarve_dir/.dontstarvetogether_dedicated_server"

export PATH="$PATH:/usr/games"
#^ Fix "steamcmd: command not found" in cron job
current_version=$(steamcmd +force_install_dir "$install_dir" +login anonymous +app_info_update 1 +app_status 343050 +quit | grep -Eo '(BuildID )([0-9]*)' | grep -Eo '[0-9]*')
latest_version=$(python3 -c "from steam.client import SteamClient;client = SteamClient();client.anonymous_login();print(client.get_product_info(apps=[343050])['apps'][343050]['depots']['branches']['public']['buildid'])")

if [[ -z "$current_version" || -z "$latest_version" ]]; then
    #Error while retrieving either version.
    exit 1
fi

if [ "$current_version" -ge "$latest_version" ]; then
    #Up to date.
    exit 0
fi

sleep 60 #Failsafe to prevent the following commands to run before the servers initially boot up

# Add all the servers to shutdown here
screen -S DST_server_$COUNT -X stuff "^C"

###

sleep 10
steamcmd +force_install_dir "$install_dir" +login anonymous +app_update 343050 validate +quit

# Add all the servers to start again below
screen -d -m -S DST_server_$COUNT "$PATH/run_dedicated_servers.sh"

exit 0
