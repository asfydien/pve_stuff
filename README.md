Penggunaan Proxmox VE di Lab. Jaringan sangat membatu siswa memahami belajar Sistem Operasi Jaringan, Linux, VPS (KVM, OpenVz), dll. 
_Yuu, mari bermain dengan **bash**..._

# Latihan Linux SysAdmin dengan Proxmox VE
## Alat dan Bahan
Untuk melayani 36-75 siswa dengan spesifikasi yang terbatas, kita mesti sedikit kesabaran. Namun, dengan beberapa penyesuaian, kita masih bisa memaksimalkan performa. _Push To The Limit!_
| Perangkat | Spesifikasi |Ket|
|-|-|-|
|PC/Server  ||
|_- Prosesor_|Intel Core i3 10105F|
|_- RAM_|DDR4 16GB|
|Storange||
|_- SSD 1_|128G| Proxmox|
|_- SSD 2_|256G| VM/CT siswa|
|LAN|10/100/1000|

| Software | Versi |Sumber|Ket|
|-|-|-|-|
|Proxmox VE|8.3|https://www.proxmox.com/en/downloads|
|Template Debian|12|
|Windows|10/11|
|OpenSSH|9.x|https://github.com/powershell/win32-openssh/releases|
|Webmin|2.202|https://sourceforge.net/projects/webadmin/files/webmin/2.202/|Versi 2.300 ada kendala ketika mengelola database
|PuTTY|0.8|https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html|
|WinSCP|6.3.x|https://www.winscp.net/|
|Wordpress|6.7.x|https://id.wordpress.org/download/|
|OpenVPN Connect|3.6.0.4074|https://openvpn.net/client/client-connect-vpn-for-windows/|Pastikan gunakan versi terbaru

## Membuat akun untuk siswa
Ga lucu siswa masuk sebagai _root_, supaya sedikit lebih aman kita buat akun khusus untuk siswa, buka **Shell** milik proxmox...

```shell
wget https://github.com/asfydien/pve_stuff/raw/refs/heads/main/buat_user_siswa.sh
chmod +x buat_user_siswa.sh
./buat_user_siswa.sh
```  
  
## Membuat template yang sudah terkonfigurasi aptproxy
Untuk menghemat bandwidth internet ketika siswa melakukan proses upgrade dan instalasi paket menggunakan perintaj apt, kita bisa membuat sebuah CT husus yang dijadikan server apt-chacher-ng, dalam kasus ini kita buat sebuah CT Debian 12 yang sudah terinstall apt-chacher-ng dan diberi IP 10.10.2.99

Untuk server aptproxy
```shell
apt update
apt upgrade
apt install apt-chacher-ng
```

Kita buat Template baru, pastikan template debian sudah di download, selanjutnya edit script sesuai kondisi
```shell
wget https://raw.githubusercontent.com/asfydien/pve_stuff/refs/heads/main/inject_aptproxy.sh
chmod +x inject_aptproxy.sh
./inject_aptproxy.sh
```

## Mengaktifkan TUN untuk VPN
Supaya CT bisa mengakses adapter TUN, kita bisa memasukan dua baris perintah berikut ke dalam baris terakhir file konfogurasi CT pada lokasi /etc/pve/lxc/ 
```
lxc.cgroup.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net dev/net none bind,create=dir
```

Lalu bagaimana jika CT yang mau kita edit lebih dari 1 atau bahkan puluhan, ya wayahna kita harus main script
```shell
wget https://raw.githubusercontent.com/asfydien/pve_stuff/refs/heads/main/aktivasi_tun_vpn.sh
chmod +x aktivasi_tun_vpn.sh
./aktivasi_tun_vpn.sh
```

Supaya CT baru siswa yang dibuat secara otomatis di aktifkan mode TUN nya, kita masukan script di atas ke dalam cron job proxmox
```shell
crontab -e
```
masukan perintah berikut, lalu simpan
```
