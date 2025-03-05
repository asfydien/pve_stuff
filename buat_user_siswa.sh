#!/bin/bash

# Ga lucu kan, siswa masuk sebagai root dan merestart proxmox!
# Kita buatkan user heuseus untuk siswa

# Nama grup yang akan dibuat
GROUP_NAME="SISWA"

# Daftar izin yang akan diberikan ke grup SISWA
PERMISSIONS=(
    "/storage/local PVEAuditor"
    "/storage/local-vm PVEDatastoreUser"
    "/vms PVEVMAdmin"
    "/sdn/zones/localnetwork PVESDNUser"
)

# Nama user dan password default
USERNAME="siswa"
PASSWORD="#Pastibisa1"
REALM="pve"  # Menggunakan Proxmox VE Authentication Server
USER_FULL="$USERNAME@$REALM"

# Path lengkap pveum untuk menghindari command not found
PVEUM_CMD="/usr/sbin/pveum"

# 1. Menentukan IP utama Proxmox (ambil dari interface utama)
IP_PROXMOX=$(hostname -I | awk '{print $1}')  # Ambil IP pertama

# 2. Membuat grup SISWA jika belum ada
if ! $PVEUM_CMD group list | grep -q "^$GROUP_NAME "; then
    echo "Membuat grup $GROUP_NAME..."
    $PVEUM_CMD group add $GROUP_NAME
else
    echo "Grup $GROUP_NAME sudah ada."
fi

# 3. Menambahkan izin ke grup SISWA
echo "Menambahkan izin ke grup $GROUP_NAME..."
for PERM in "${PERMISSIONS[@]}"; do
    PATH_PERM=$(echo "$PERM" | cut -d' ' -f1)
    ROLE_PERM=$(echo "$PERM" | cut -d' ' -f2)
    $PVEUM_CMD aclmod "$PATH_PERM" -group "$GROUP_NAME" -role "$ROLE_PERM"
done

# 4. Membuat user siswa jika belum ada
if ! $PVEUM_CMD user list | grep -q "^$USER_FULL "; then
    echo "Membuat user $USER_FULL dengan password default..."
    $PVEUM_CMD user add "$USER_FULL" -group $GROUP_NAME -password "$PASSWORD"
else
    echo "User $USER_FULL sudah ada."
fi

# 5. Menampilkan informasi login
echo ""
echo "User '$USER_FULL' telah dibuat atau sudah ada."
echo "Gunakan informasi berikut untuk login:"
echo "==========================================="
echo "URL      : https://$IP_PROXMOX:8006"
echo "User     : $USERNAME"
echo "Password : $PASSWORD"
echo "Realm    : Proxmox VE authentication (PVE)"
echo "==========================================="

echo "Proses selesai!"
