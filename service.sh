#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}
. "$MODDIR/utils.sh"

# This script will be executed in late_start service mode

add_iptables_redirect() {
  local protocol=$1
  local address=$2
  local dest_port=$3
  local src_port=$4

  local command="iptables -A OUTPUT -w -t nat -p $protocol --dport 53 -j DNAT --to-destination $address:$dest_port"
  if [ "$src_port" != "" ]; then
    command="$command --sport $src_port --destination $address"
  fi
  eval "$command"
  echo "$command" | sed "s/-A/-D/" >> "$RESTORE_IPTABLES"
}

# clear restore file
echo -n > "$RESTORE_IPTABLES"

load_config

# only output_port will be able to communicate with outer world
for server in $upstream_servers; do
  add_iptables_redirect tcp $server 53 $output_port
  add_iptables_redirect udp $server 53 $output_port
done

# redirect all outgoing connections to local server
add_iptables_redirect tcp 127.0.0.1 $server_port
add_iptables_redirect udp 127.0.0.1 $server_port

if ! run_dnsmasq; then
  echo "Unable to start, aborting."
  sh "$RESTORE_IPTABLES"
fi
