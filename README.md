# DST_DedicatedServer_AutoUpdate
A bash script to check if your Don't Starve Together Dedicated Server is up-to-date every minute, and to update it automatically.

This script is originally intended for vanilla servers, it doesn't auto update modded dedicated servers.

Only works on GNU/Linux. Tested on Debian 11 and higher.

## Download
### GNU/Linux
```bash
wget https://raw.githubusercontent.com/Sad-theFaceless/DST_DedicatedServer_AutoUpdate/main/DST_DedicatedServer_AutoUpdate.sh && chmod +x DST_DedicatedServer_AutoUpdate.sh
```
#### Dependencies
- cron & screen
```bash
sudo apt install -y cron screen
```
- steamcmd
```bash
sudo apt update
sudo apt install -y software-properties-common
sudo apt-add-repository -y contrib
sudo apt-add-repository -y non-free
sudo dpkg --add-architecture i386;sudo apt update
sudo apt install -y libstdc++6:i386 libgcc1:i386 libcurl4-gnutls-dev:i386 lib32gcc-s1
sudo apt install -y steamcmd
```
- python3 [steam\[client\]](https://github.com/ValvePython/steam) package
```bash
sudo python3 -m pip install --break-system-packages -U steam[client]
```

## Setup
1. Launch your DST Dedicated Server(s) at least once, thanks to the [Klei's script file](https://accounts.klei.com/assets/gamesetup/linux/run_dedicated_servers.sh).

   Recommended version of the file (taking into account `steamcmd`'s global install):
```bash
#!/bin/bash

cluster_name="$SERVER_NAME" # Cluster's directory name

dontstarve_dir="$HOME/.klei/DoNotStarveTogether"
install_dir="$dontstarve_dir/.dontstarvetogether_dedicated_server"

function fail()
{
        echo Error: "$@" >&2
        exit 1
}

function check_for_file()
{
        if [ ! -e "$1" ]; then
                fail "Missing file: $1"
        fi
}

check_for_file "$dontstarve_dir/$cluster_name/cluster.ini"
check_for_file "$dontstarve_dir/$cluster_name/cluster_token.txt"
check_for_file "$dontstarve_dir/$cluster_name/Master/server.ini"
check_for_file "$dontstarve_dir/$cluster_name/Caves/server.ini"

steamcmd +force_install_dir "$install_dir" +login anonymous +app_update 343050 validate +quit

check_for_file "$install_dir/bin64"

cd "$install_dir/bin64" || fail

run_shared=(./dontstarve_dedicated_server_nullrenderer_x64)
run_shared+=(-console)
run_shared+=(-cluster "$cluster_name")
run_shared+=(-monitor_parent_process $$)

"${run_shared[@]}" -shard Caves  | sed 's/^/Caves:  /' &
"${run_shared[@]}" -shard Master | sed 's/^/Master: /'
```
^ Replace `$SERVER_NAME` accordingly.

2. Edit `DST_DedicatedServer_AutoUpdate.sh`:
   - Make sure the variables `dontstarve_dir` and `install_dir` values match the ones used in the file(s) `run_dedicated_servers.sh`.
   - Read the script's comments, add your servers while indicated, replacing `$PATH` and `$COUNT` accordingly. `$COUNT` is a number you can increment with each different server you add.

3. Create the crob job to run the script every minute:
```bash
echo -e '* * * * * $USER "$PATH/DST_DedicatedServer_AutoUpdate.sh"' | sudo tee -a "/etc/cron.d/dst"
```
^ Replace `$USER` and `$PATH` accordingly.

4. For each of your server, add the following line inside `/etc/cron.d/dst`:
```bash
@reboot $USER sleep 30 && screen -d -m -S DST_server_$COUNT "$PATH/run_dedicated_servers.sh"
```
^ Replace `$USER`, `$PATH` and `$COUNT` accordingly.

If this step is done correctly, your dedicated server(s) will launch automatically when you boot up.

You can list your screen sessions (and thus your launched dedicated servers) with the command `screen -ls`.

5. Reboot your machine.
