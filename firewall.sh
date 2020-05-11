#!/bin/sh


# delete all the rules
	# L’option -F (ou --flush) se charge de supprimer les chaînes d’une table.
	# L’option -X (ou --delete-chain) supprime les chaînes personnalisées définies par l’utilisateur.
sudo iptables -t filter -F
sudo iptables -t filter -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X

# set default policy
	# -P the policy target must be either ACCEPT or DROP
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# trust ourselves
	# L’option -j (ou --jump) spécifie la cible de règle, autrement dit, 
	# elle indique ce qu’il faut faire si le paquet correspond à la règle.
sudo iptables -A INPUT lo -j ACCEPT
sudo iptables -A OUTPUT lo -j ACCEPT


# allow Ping
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT

# allow ssh
	# --sport is short for --source-port
	# --dport is short for --destination-port
sudo iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 2222 -j ACCEPT
