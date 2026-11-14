# Project 02 — MikroTik Routing & Basic Firewall

**Bidang:** Network Engineering  
**Fase:** 2 — MikroTik Routing  
**Jenis:** Kombinasi perangkat fisik dan virtual  
**Status:** Konfigurasi dan pengujian dasar selesai

## Ringkasan
Membangun konektivitas dua LAN menggunakan R1 MikroTik hAP lite RB941-2nD dan R2 MikroTik CHR pada VirtualBox. Materi meliputi IP addressing, DHCP, static route, default route, NAT, DNS, dan firewall filter dasar.

> Cisco Packet Tracer digunakan untuk menggambar desain/topologi. Konfigurasi diterapkan pada perangkat MikroTik, bukan router Cisco di Packet Tracer. Ini adalah praktik pembelajaran di lingkungan lab, bukan jaringan produksi.

## Topologi dan IP addressing

| Perangkat | Interface | IP / metode | Peran |
|---|---|---|---|
| R1 hAP lite | ether2 | 192.168.10.1/24 | Gateway LAN A |
| R1 hAP lite | ether3 | 10.10.10.1/29 | Transit ke R2 |
| R1 hAP lite | wlan1 | DHCP; screenshot 192.168.1.34/24 | WAN/upstream |
| R2 CHR | ether1 | DHCP; lease 10.10.10.3/29 | Transit ke R1 |
| R2 CHR | ether3 | 192.168.20.1/24 | Gateway LAN B |

Transit menggunakan subnet `10.10.10.0/29`. Diagram rancangan awal menampilkan `10.10.10.2/29` pada sisi R2; label tersebut perlu diselaraskan menjadi `10.10.10.3/29` sesuai konfigurasi lab aktual.

## Routing

### R1
| Destination | Next hop/interface | Distance | Jenis |
|---|---|---:|---|
| 0.0.0.0/0 | 192.168.1.1 | 1 | Default route dinamis |
| 10.10.10.0/29 | ether3 | 0 | Connected |
| 192.168.1.0/24 | wlan1 | 0 | Connected |
| 192.168.10.0/24 | ether2 | 0 | Connected |
| 192.168.20.0/24 | 10.10.10.3 | 1 | Static |

### R2
| Destination | Next hop/interface | Distance | Jenis |
|---|---|---:|---|
| 0.0.0.0/0 | 10.10.10.1 | 1 | Default route dinamis |
| 10.10.10.0/29 | ether1 | 0 | Connected |
| 192.168.20.0/24 | ether3 | 0 | Connected |

## DHCP, NAT, dan DNS
- R1 DHCP Server: `ether2` untuk LAN A, pool `192.168.10.2–192.168.10.254`.
- R1 DHCP Server: `ether3` untuk transit, pool `10.10.10.2–10.10.10.6`.
- R2 DHCP Server: `ether3` untuk LAN B, pool `192.168.20.2–192.168.20.254`.
- R2 DHCP Client: `ether1` untuk memperoleh alamat transit.
- R1 NAT: `srcnat masquerade`, keluar `wlan1`.
- R2 NAT: `srcnat masquerade`, keluar `ether1`.
- Kedua router menggunakan DNS `8.8.8.8` dan `allow-remote-requests=yes`.

Trafik LAN B mengalami NAT pada R2 lalu NAT kembali pada R1 (double NAT).

## Firewall filter R2
| No. | Chain | Action | Kondisi |
|---:|---|---|---|
| 0 | input | accept | established,related |
| 1 | input | drop | invalid |
| 2 | input | accept | new dari 192.168.20.0/24 |
| 3 | input | drop | in-interface=ether1 |
| 4 | forward | accept | src 192.168.20.0/24, out ether1 |

Rule `input` mengontrol trafik yang ditujukan ke router. Rule `forward` mengizinkan trafik LAN B yang diteruskan melalui `ether1`. Tidak ada rule drop umum pada chain `forward`, sehingga tidak dapat disimpulkan bahwa seluruh trafik forward lain otomatis ditolak.

## Pengujian
| Sumber | Tujuan | Hasil |
|---|---|---|
| Ubuntu / LAN B | 192.168.20.1 | Ping berhasil |
| Ubuntu / LAN B | 8.8.8.8 | Ping berhasil |
| Windows / LAN A | 192.168.20.1 | Request timed out |

Ping Windows menuju `192.168.20.1` ditujukan ke interface LAN R2. Trafik masuk melalui `ether1` dan sesuai dengan rule input drop dari `ether1`.

### Counter firewall R2
| No. | Chain | Action | Packets | Interpretasi |
|---:|---|---|---:|---|
| 0 | input | accept | 1,011 | Established/related diterima |
| 1 | input | drop | 0 | Tidak ada paket invalid yang cocok saat dibaca |
| 2 | input | accept | 751 | Paket input dari LAN B diterima |
| 3 | input | drop | 305 | Paket input dari ether1 dijatuhkan |
| 4 | forward | accept | 77 | Paket LAN B diteruskan ke ether1 |

Counter adalah akumulasi paket saat dibaca, bukan hitungan khusus satu ping.

## Evaluasi dan rekomendasi
1. Buat DHCP static lease untuk R2 berdasarkan MAC address agar IP transit `10.10.10.3` tetap, karena static route R1 menunjuk alamat tersebut.
2. Export R1 menunjukkan `dhcp_pool0` dan `dhcp_pool1` dibuat tetapi tidak direferensikan oleh DHCP Server. Periksa sebelum menghapus.
3. Rule forward saat ini mengizinkan LAN B menuju `ether1`, tetapi belum membentuk kebijakan default-deny untuk trafik forward lainnya.
4. Rule accept LAN B pada input berbasis source subnet. Untuk pembatasan lebih ketat, evaluasi penambahan kondisi interface masuk yang sesuai.
5. Perbarui label transit sisi R2 pada diagram menjadi `10.10.10.3/29`.

Rekomendasi di atas merupakan evaluasi lanjutan dan tidak diklaim sudah diterapkan.

## Kesimpulan
Lab menunjukkan konektivitas LAN A dan LAN B melalui dua router MikroTik, penggunaan static/default route, DHCP, NAT, DNS, serta firewall dasar. Hasil ping dan counter firewall menjadi bukti pengujian. Proyek ini adalah dokumentasi praktik pembelajaran di lingkungan lab.

