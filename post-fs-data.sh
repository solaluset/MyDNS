#!/system/bin/sh
MODDIR=${0%/*}
. $MODDIR/utils.sh

# point the script back to module directory
# (in case mount point gets changed)
sed -i "s|=.*MODDIR_PLACEHOLDER|=$MODDIR # MODDIR_PLACEHOLDER|" "$MODDIR/system/bin/mydns"

# generate resolv.conf
upstream_servers=$(load_cfg_val upstream_server)
write_resolv_conf
