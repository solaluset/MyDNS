#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/utils.sh"

# link back to module directory
# (to not depend on mount point)
real=$MODDIR/mydns
linked=$MODDIR/system/bin/mydns
if [ "$(readlink -f $linked)" != "$real" ]; then
  ln -fs "$real" "$linked"
fi

# generate resolv.conf
upstream_servers=$(load_cfg_val upstream_server)
write_resolv_conf
