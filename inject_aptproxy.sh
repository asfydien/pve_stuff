#!/bin/bash

# Script ini dugunakan untuk membuat template Debian derivatif, dimana template baru disisipkan konfogurasi proxy menuju server apt-cacher-ng

# Konfigurasi
TEMPLATE_NAME="debian-12-standard_12.7-1_amd64.tar.zst"  # nama template asli
NEW_TEMPLATE_NAME="debian-12-custom_for_kahiang.tar.zst"
TEMPLATE_DIR="/var/lib/vz/template/cache"
WORK_DIR="/root/debian-template"
APT_PROXY_IP="10.10.2.99"  # <<== Ganti dengan IP apt-cacher-ng
APT_PROXY_FILE="etc/apt/apt.conf.d/00aptproxy"

# Pastikan script dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
   echo "Script ini harus dijalankan sebagai root!"
   exit 1
fi

# Pastikan pzstd terpasang
if ! command -v pzstd &> /dev/null; then
    echo "Error: pzstd tidak ditemukan! Instal dengan: apt install zstd"
    exit 1
fi

echo "==> Mengekstrak template Debian..."
mkdir -p "$WORK_DIR"
cd "$WORK_DIR" || exit

# Ekstrak template menggunakan tar biasa
if [[ -f "$TEMPLATE_DIR/$TEMPLATE_NAME" ]]; then
    pzstd -d -c "$TEMPLATE_DIR/$TEMPLATE_NAME" | tar -xf -
else
    echo "Template tidak ditemukan di $TEMPLATE_DIR!"
    exit 1
fi

echo "==> Menambahkan konfigurasi apt-cacher-ng..."
mkdir -p "$(dirname "$APT_PROXY_FILE")"
echo "Acquire::HTTP::Proxy \"http://$APT_PROXY_IP:3142\";" > "$APT_PROXY_FILE"

echo "==> Membersihkan file sementara sebelum kompresi..."
rm -rf dev/* proc/* sys/* run/* tmp/* var/log/* var/cache/apt/*

echo "==> Mengemas ulang template dengan tar + pzstd..., slowly but yahut..."
tar -cf - -C "$WORK_DIR" . | pzstd -19 -f -o "$TEMPLATE_DIR/$NEW_TEMPLATE_NAME"

echo "==> Membersihkan file sementara..."
cd ~
rm -rf "$WORK_DIR"

echo "==> Selesai! Template baru tersedia di: $TEMPLATE_DIR/$NEW_TEMPLATE_NAME"
echo "Gunakan template ini saat membuat CT baru."
