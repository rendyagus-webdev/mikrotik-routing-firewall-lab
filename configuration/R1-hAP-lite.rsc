# 2026-11-14 20:35:47 by RouterOS 7.21.5
# software id = 8B0R-PMNF
#
# model = RB941-2nD
# serial number = HCB07HD4EJN
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
add authentication-types=wpa-psk,wpa2-psk mode=dynamic-keys name=profile1 \
    supplicant-identity=""
/interface wireless
set [ find default-name=wlan1 ] disabled=no security-profile=profile1 ssid=\
    "KOS MUNZIR 4G"
/ip pool
add name=dhcp_pool0 ranges=192.168.10.2-192.168.10.10
add name=dhcp_pool1 ranges=10.10.10.2
add name=dhcp_pool2 ranges=10.10.10.2-10.10.10.6
add name=dhcp_pool3 ranges=192.168.10.2-192.168.10.254
/ip dhcp-server
add address-pool=dhcp_pool2 interface=ether3 name=dhcp2
add address-pool=dhcp_pool3 interface=ether2 name=dhcp1
/ip address
add address=192.168.10.1/24 interface=ether2 network=192.168.10.0
add address=10.10.10.1/29 interface=ether3 network=10.10.10.0
/ip dhcp-client
add interface=wlan1
/ip dhcp-server network
add address=10.10.10.0/29 gateway=10.10.10.1
add address=192.168.10.0/24 gateway=192.168.10.1
/ip dns
set allow-remote-requests=yes servers=8.8.8.8
/ip firewall nat
add action=masquerade chain=srcnat out-interface=wlan1
/ip route
add disabled=no dst-address=192.168.20.1/24 gateway=10.10.10.3 routing-table=\
    main
/system clock
set time-zone-name=Asia/Jakarta
/system identity
set name=R1
