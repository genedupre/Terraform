%{ for addr in ip_addrs ~}
server ${addr};
%{ endfor ~}