#!/bin/bash

# Gunakan script ini untuk menghapus sekaligus CT dengan ID yang terurut

# Daftar ID CT yang akan dihapus
CT_IDS=($(seq 1001 1037) $(seq 2001 2037)) # ct tjkt-1 dan tjkt-2
EXISTING_CTS=($(pct list | awk 'NR>1 {print $1}'))  # Ambil daftar CT yang ada
DELETED_CTS=()
NOT_FOUND_CTS=()

for CT_ID in "${CT_IDS[@]}"; do
    if [[ " ${EXISTING_CTS[*]} " =~ " ${CT_ID} " ]]; then
        echo "Menghapus CT $CT_ID..."

        # Hentikan jika masih berjalan
        if pct status "$CT_ID" | grep -q 'status: running'; then
            echo "  -> Menghentikan CT $CT_ID..."
            pct stop "$CT_ID"
            sleep 1  # Kurangi waktu jeda untuk efisiensi
        fi

        # Hapus CT
        echo "  -> Menghapus CT $CT_ID..."
        pct destroy "$CT_ID" && DELETED_CTS+=("$CT_ID")
    else
        echo "CT $CT_ID tidak ditemukan, melewati..."
        NOT_FOUND_CTS+=("$CT_ID")
    fi
done

# Tampilkan daftar CT yang berhasil dihapus
if [ ${#DELETED_CTS[@]} -gt 0 ]; then
    echo -e "\nCT yang berhasil dihapus: ${DELETED_CTS[*]}"
fi

# Tampilkan daftar CT yang tidak ditemukan
if [ ${#NOT_FOUND_CTS[@]} -gt 0 ]; then
    echo -e "\nCT yang tidak ditemukan: ${NOT_FOUND_CTS[*]}"
fi

echo -e "\nProses penghapusan selesai."
