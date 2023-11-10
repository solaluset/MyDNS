#!/bin/sh

if [ "$1" = "" ]; then
  echo "Usage: $0 <installation directory>"
  exit 1
fi

dest=$(realpath "$1")
if [ "$PREFIX" = "" ]; then
  PREFIX=/usr/local
fi
PREFIX=$(realpath "$PREFIX")
echo "Installing to $dest"
echo "Prefix set to $PREFIX"

mkdir -p "$dest"
cd "$(dirname "$0")"

for file in *; do
  if [ "$file" = "META-INF" ]; then
    continue
  fi
  if [ "$file" = "default.conf" ]; then
    sed -Ez 's/(upstream_server=[^\n]+\n)+/upstream_server=inherit\n/' default.conf > "$dest/default.conf"
    continue
  fi
  if [ -f "$file" -a -x "$file" ]; then
    install -o 0 -g 0 -m 755 "$file" "$dest"
    sed -z -i 's|^#!/system/|#!/|' "$dest/$file"
  else
    cp -r "$file" "$dest"
  fi
done

sed -i "s/ANDROID=1/ANDROID=0/;s/PREFIX=/PREFIX='$(echo "$PREFIX" | sed 's|/|\\/|g')'/" "$dest/utils.sh"
ln -fs "$dest/mydns" "$PREFIX/bin"
