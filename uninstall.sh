#!/system/bin/sh
MODDIR=${0%/*}

. "$MODDIR/utils.sh"

rm -fr "$DATADIR"
if [ $ANDROID = 0 ]; then
  rm -fr "$PREFIX/bin/mydns"
fi
