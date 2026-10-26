#!/bin/bash
set -e

OMNIROUTE_PORT=20128

# 1. Allow docker0 to route to loopback
sudo sysctl -w net.ipv4.conf.docker0.route_localnet=1

# 2. Redirect port 20128 traffic from docker0 to 127.0.0.1 (NAT table)
sudo iptables -t nat -C PREROUTING -i docker0 -p tcp --dport $OMNIROUTE_PORT -j DNAT --to-destination 127.0.0.1:$OMNIROUTE_PORT 2>/dev/null || \
sudo iptables -t nat -A PREROUTING -i docker0 -p tcp --dport $OMNIROUTE_PORT -j DNAT --to-destination 127.0.0.1:$OMNIROUTE_PORT

# 3. ABSOLUTE SAFETY: Allow ONLY port 20128 to localhost, DROP all other 127.0.0.0/8 traffic from Docker
sudo iptables -C INPUT -i docker0 -d 127.0.0.0/8 -p tcp --dport $OMNIROUTE_PORT -j ACCEPT 2>/dev/null || \
sudo iptables -I INPUT 1 -i docker0 -d 127.0.0.0/8 -p tcp --dport $OMNIROUTE_PORT -j ACCEPT

sudo iptables -C INPUT -i docker0 -d 127.0.0.0/8 -j DROP 2>/dev/null || \
sudo iptables -I INPUT 2 -i docker0 -d 127.0.0.0/8 -j DROP

# 4. Allow it through UFW (if UFW is present)
if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow in on docker0 to 127.0.0.1 port $OMNIROUTE_PORT proto tcp >/dev/null
fi

echo "Omniroute bridge successfully configured with zero-compromise isolation."
