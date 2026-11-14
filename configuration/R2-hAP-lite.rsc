# 2026-11-14 13:30:45 by RouterOS 7.22
# system id = F40uokMdzWN
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/ip pool
add name=dhcp_pool0 ranges=192.168.20.2-192.168.20.254
/ip dhcp-server
add address-pool=dhcp_pool0 interface=ether3 name=dhcp1
/ip address
add address=192.168.20.1/24 interface=ether3 network=192.168.20.0
/ip dhcp-client
add interface=ether1 name=client1
/ip dhcp-server network
add address=192.168.20.0/24 gateway=192.168.20.1
/ip dns
set allow-remote-requests=yes servers=8.8.8.8
/ip firewall filter
add action=accept chain=input connection-state=established,related
add action=drop chain=input connection-state=invalid
add action=accept chain=input connection-state=new src-address=\
    192.168.20.0/24
add action=drop chain=input connection-state="" in-interface=ether1
add action=accept chain=forward out-interface=ether1 src-address=\
    192.168.20.0/24
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1
/system identity
set name=R2
