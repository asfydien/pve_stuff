# Belajar Linux SysAdmin dengan Proxmox VE
> [!NOTE]
> Penggunaan Proxmox VE di Lab. Jaringan sangat membatu siswa memahami cara kerja Sistem Operasi Jaringan, Linux, VPS (KVM, OpenVz), dll. 
_Yuu, mari bermain dengan **bash**..._

> [!CAUTION]
> Repository ini dibuat hanya sebagai catatan kecil untuk pengingat hasil pengalaman di lab, bukan tutorial lengkap, silahkan abaikan jika belum dipahami untuk menghindari resiko kesalahan...
## 1. Perangkat dan Bahan yang digunakan
Untuk mendukung 36-75 siswa dengan spesifikasi hardware terbatas, kita perlu sedikit sabar. Tapi, dengan beberapa penyesuaian, performa tetap bisa dimaksimalkan. _Push To The Limit!_
#### 1.1. Perangkat Keras
| Perangkat | Spesifikasi |Ket|
|-|-|-|
|PC/Server  ||
|_- Prosesor_|Intel Core i3 10105F|4 Core 8 Thread, cukup untuk 16-18 Container (CT) berjalan bersamaan (bukan VM)|
|_- RAM_|DDR4 16GB|Setiap siswa hanya boleh pakai 512MB per CT|
|Pnyimpanan||Wajib SSD min Sata 3
|_- SSD 1_|128G| Untuk sistem Proxmox|
|_- SSD 2_|256G| Untuk VM/CT siswa|
|LAN|10/100/1000|Bottleneck di router dan switch yang masih Fast Ethernet 10/100 

### 1.2. Perangkat Lunak 
| Perangkat Lunak | Versi |Sumber|Ket|
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

## 2. Membuat akun untuk siswa
Ga lucu kalau siswa login sebagai root, kan? Supaya lebih aman, kita buat akun khusus untuk siswa. Buka **Shell** di Proxmox, lalu jalankan:

```shell
wget https://github.com/asfydien/pve_stuff/raw/refs/heads/main/buat_user_siswa.sh
chmod +x buat_user_siswa.sh
./buat_user_siswa.sh
```  
  
## 3. Membuat Template dengan Konfigurasi APT Proxy
Untuk menghemat _bandwidth internet_ ketika siswa melakukan proses _upgrade_ dan instalasi paket menggunakan perintah `apt-get`, kita bisa membuat sebuah CT husus yang dijadikan server, dalam prakteknya kita buat sebuah CT Debian 12 yang sudah terinstall `apt-chacher-ng` dan diberi IP `10.10.2.99`

### 3.1. Membuat APT Proxy Server
Buat CT baru, bisa menggunakan Debian atau Ubuntu, beri IP 10.10.2.99 lalu install `apt-chacher-ng`
  ```shell
  apt update
  apt upgrade
  apt install apt-chacher-ng
  ```
  Pastikan CT ini otomatis nyala saat boot `Options -> Start at boot = yes`, CT siswa bisa langsung akses server ini.

### 3.2. Membuat Template yang sudah terkonfigurasi APT Proxy 
Pada sisi siswa, supaya memudahkan, kita modifikasi Template debian bawaan `debian-12-standard_12.7-1_amd64.tar.zst` menjadi template baru `debian-12-custom_for_kahiang.tar.zst` yang sudah terkonfigurasi aptproxy, dimana siswa diwajibkan menggunakan `debian-12-custom_for_kahiang.tar.zst` ketika membuat CT baru

Berikut perintah untuk membuat template tersebut, pelajari [`inject_aptproxy.sh`](https://github.com/asfydien/pve_stuff/blob/main/inject_aptproxy.sh) untuk menyesuaikan sesuai kebutuhan
```shell
wget https://raw.githubusercontent.com/asfydien/pve_stuff/refs/heads/main/inject_aptproxy.sh
chmod +x inject_aptproxy.sh
./inject_aptproxy.sh
```
Cek skrip inject_aptproxy.sh untuk menyesuaikan dengan kebutuhan.

## 4. Mengaktifkan TUN untuk VPN
Agar CT bisa pakai adapter TUN untuk VPN, tambahkan dua baris ini ke file konfigurasi CT di `/etc/pve/lxc/` 
```
lxc.cgroup.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net dev/net none bind,create=dir
```

Lalu bagaimana jika CT yang mau kita edit lebih dari 1 atau bahkan puluhan, ya wayahna kita harus main _script_
```shell
wget https://raw.githubusercontent.com/asfydien/pve_stuff/refs/heads/main/aktivasi_tun_vpn.sh
chmod +x aktivasi_tun_vpn.sh
./aktivasi_tun_vpn.sh
```
> [!TIP]
> Supaya CT baru siswa yang dibuat secara otomatis di aktifkan mode TUN nya, kita masukan _script_ di atas ke dalam _Cron Job_ milik Proxmox
> ```shell
> crontab -e
> ```
> masukan perintah berikut, lalu simpan <kbd>Ctrl</kbd> + <kbd>o</kbd>
> ```
> */5 * * * * /root/aktivasi_tun_vpn.sh
> ```

## 5. Menghapus banyak CT sekaligus (Bulk)
Kalau mau hapus banyak CT siswa sekaligus, biasanya ribet kalau satu-satu. Pakai skrip ini, asal ID CT/VM siswa berurutan:
```shell
wget https://raw.githubusercontent.com/asfydien/pve_stuff/refs/heads/main/hapus_ct.sh
chmod +x hapus_ct.sh
./hapus_ct.sh
```
## 6. Tentang Repository
Repository ini berisi kumpulan skrip untuk mempermudah penggunaan Proxmox VE di Lab. Jaringan. Skrip-skrip ini dibuat berdasarkan pengalaman praktis dan diharapkan membantu mengelola lingkungan belajar dengan lebih efisien.
