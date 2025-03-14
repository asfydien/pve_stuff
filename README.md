# Belajar Linux SysAdmin dengan Proxmox VE
> [!NOTE]
> Penggunaan Proxmox VE di Lab. Jaringan sangat membatu siswa memahami cara kerja Sistem Operasi Jaringan, Linux, VPS (KVM, OpenVz), dll. 
_Yuu, mari bermain dengan **bash**..._

> [!CAUTION]
> Repository ini dibuat hanya sebagai catatan kecil untuk pengingat hasil pengalaman di lab, bukan tutorial lengkap, silahkan abaikan jika belum dipahami untuk menghindari resiko kesalahan...
## Perangkat dan Bahan yang digunakan
Untuk melayani 36-75 siswa dengan spesifikasi yang terbatas, kita butuh sedikit bersabaran. Namun, dengan beberapa penyesuaian, kita masih bisa memaksimalkan performa. _Push To The Limit!_
| Perangkat | Spesifikasi |Ket|
|-|-|-|
|PC/Server  ||
|_- Prosesor_|Intel Core i3 10105F|4 Core 8 Thread, cukup untuk 16-18 CT (bukan VM) berjalan bersamaan|
|_- RAM_|DDR4 16GB|Setiap siswa di izinkan hanya menggunakan 512Mb per CT|
|Storange||Wajib SSD min Sata 3
|_- SSD 1_|128G| Proxmox|
|_- SSD 2_|256G| VM/CT siswa|
|LAN|10/100/1000|Bottleneck di Router dan Switch yang masih Fast Ethernet 10/100 

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
  
## Membuat template yang sudah terkonfigurasi APT Proxy
Untuk menghemat _bandwidth internet_ ketika siswa melakukan proses _upgrade_ dan instalasi paket menggunakan perintah `apt-get`, kita bisa membuat sebuah CT husus yang dijadikan server, dalam prakteknya kita buat sebuah CT Debian 12 yang sudah terinstall `apt-chacher-ng` dan diberi IP `10.10.2.99`

#### 1. Membuat APT Proxy Server
Buat CT baru, bisa menggunakan Debian atau Ubuntu, beri IP 10.10.2.99 lalu install `apt-chacher-ng`
  ```shell
  apt update
  apt upgrade
  apt install apt-chacher-ng
  ```
  Pastikan server yang dijadikan APT Proxy harus otomatis berjalan `Options -> Start at boot = yes`, karena CT yang siswa gunakan akan secara otomatis mengakses server tersebut!

#### 2. Membuat Template yang sudah terkonfigurasi APT Proxy 
Pada sisi siswa, supaya memudahkan, kita modifikasi Template debian bawaan `debian-12-standard_12.7-1_amd64.tar.zst` menjadi template baru `debian-12-custom_for_kahiang.tar.zst` yang sudah terkonfigurasi aptproxy, dimana siswa diwajibkan menggunakan `debian-12-custom_for_kahiang.tar.zst` ketika membuat CT baru

Berikut perintah untuk membuat template tersebut, pelajari [`inject_aptproxy.sh`](https://github.com/asfydien/pve_stuff/blob/main/inject_aptproxy.sh) untuk menyesuaikan sesuai kebutuhan
```shell
wget https://raw.githubusercontent.com/asfydien/pve_stuff/refs/heads/main/inject_aptproxy.sh
chmod +x inject_aptproxy.sh
./inject_aptproxy.sh
```

## Mengaktifkan TUN untuk VPN
Langkah mudah supaya CT bisa mengakses adapter TUN, kita bisa memasukan dua baris perintah berikut ke dalam baris terakhir file konfogurasi CT pada lokasi `/etc/pve/lxc/` 
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

## Menghapus banyak CT sekaligus (Bulk)
Ketika ingin menghapus semua CT yang dibuat siswa, kita harus me _remove_ nya satu persatu, supaya lebih mudah kita gunakan _script_, dengan syarat CT/VM yang di buat siswa memiliki ID yang berurutan!
```shell
wget https://raw.githubusercontent.com/asfydien/pve_stuff/refs/heads/main/hapus_ct.sh
chmod +x hapus_ct.sh
./hapus_ct.sh
```
