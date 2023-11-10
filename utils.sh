if [ "$MODPATH" != "" ]; then
  MODDIR=$MODPATH
elif [ "$MODDIR" = "" ]; then
  MODDIR=${0%/*}
fi
ANDROID=1
if [ $ANDROID = 1 ]; then
  DATADIR=/data/mydns
  SYSDIR=$MODDIR/system
else
  DATADIR=$MODDIR
  SYSDIR=""
  PREFIX=
fi
CONFIG=$DATADIR/mydns.conf
PIDFILE=$DATADIR/dnsmasq.pid
RESTORE_IPTABLES=$DATADIR/restore_iptables

mkdir -p "$DATADIR"
if [ ! -f "$CONFIG" ]; then
  cp "$MODDIR/default.conf" "$CONFIG"
fi

if [ "$(command -v ui_print)" = "" ]; then
  alias ui_print=echo
fi

DNSMASQ=$DATADIR/dnsmasq
if [ ! -x "$DNSMASQ" ]; then
  if [ $ANDROID = 1 ]; then
    cp /data/data/com.termux/files/usr/bin/dnsmasq "$DATADIR"
    if [ $? != 0 ]; then
      ui_print "WARNING: dnsmasq not found in Termux."
      ui_print "WARNING: Standard dnsmasq may cause abnormal CPU usage."
      ui_print "WARNING: Install dnsmasq in Termux and reflash the module."
      DNSMASQ=dnsmasq
    fi
  else
    DNSMASQ=dnsmasq
  fi
fi

load_cfg_val() {
  if [ "$2" != "" ]; then
    local file="$2"
  else
    local file="$CONFIG"
  fi
  sed -n "s|^$1=||p" "$file"
}

load_config() {
  server_port=$(load_cfg_val server_port "$1")
  output_port=$(load_cfg_val output_port "$1")
  upstream_servers=$(load_cfg_val upstream_server "$1")
  dnsmasq_args=$(load_cfg_val dnsmasq_args "$1")
}

check_config() {
  local has_servers=0
  local server
  for server in $upstream_servers; do
    has_servers=1
    if ! echo ".$server" | grep -Eq '^(\.[0-9]{1,3}){4}$'; then
      echo "'$server' doesn't look like a valid IP address."
      return 1
    fi
  done
  if [ $has_servers = 0 ]; then
    echo "No upstream servers specified."
    return 1
  fi
  local port
  for port in "$server_port" "$output_port"; do
    if ! echo "$port" | grep -Eq '^[0-9]+$'; then
      echo "'$port' doesn't look like a valid port."
      return 1
    fi
  done
  if [ "$server_port" = "$output_port" ]; then
    echo "server_port and output_port cannot be the same."
    return 1
  fi
  if ! run_dnsmasq --test; then
    return 1
  fi
  return 0
}

write_resolv_conf() {
  if [ "$upstream_servers" = "inherit" ]; then
    return
  fi
  local resolv=$SYSDIR/etc/resolv.conf
  echo -n > "$resolv"
  local server
  for server in $upstream_servers; do
    echo "nameserver $server" >> "$resolv"
  done
}

run_dnsmasq() {
  "$DNSMASQ" --pid-file="$PIDFILE" --port $server_port -Q $output_port $dnsmasq_args $1
}
