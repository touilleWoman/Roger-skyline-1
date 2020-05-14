#!/bin/sh


echo "delete all the rules"
	# L’option -F (ou --flush) se charge de supprimer les chaînes d’une table.
	# L’option -X (ou --delete-chain) supprime les chaînes personnalisées définies par l’utilisateur.
	# default option is -t filter: iptables -F == iptables -t filter -F
sudo iptables -t filter -F
sudo iptables -t filter -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X

echo "set default policy, refuse all"
	# -P the policy target must be either ACCEPT or DROP
sudo iptables -t filter -P INPUT DROP
sudo iptables -t filter -P FORWARD DROP
sudo iptables -t filter -P OUTPUT DROP

echo "allow state ESTABLISHED and localhost"
#sudo iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT 
sudo iptables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT

	# L’option -j (ou --jump) spécifie la cible de règle, autrement dit, 
	# elle indique ce qu’il faut faire si le paquet correspond à la règle.
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT


echo "allow Ping"
sudo iptables -A INPUT -p icmp -j ACCEPT
sudo iptables -A OUTPUT -p icmp -j ACCEPT

echo "allow ssh"
	# --sport is short for --source-port
	# --dport is short for --destination-port
sudo iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 2222 -j ACCEPT

echo "allow Web"
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

echo "Dos protection"
	#Block Invalid Packets
sudo iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

sudo iptables -A FORWARD -p tcp --syn -m limit --limit 1/second -j ACCEPT
#sudo iptables -A FORWARD -p udp -m limit --limit 1/second -j ACCEPT
sudo iptables -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 1/second -j ACCEPT

echo "protection anti brut force ssh"
sudo iptables -A INPUT -p tcp --dport 2222 -m conntrack --ctstate NEW -m recent --set
sudo iptables -A INPUT -p tcp --dport 2222 -m conntrack --ctstate NEW -m recent --update --seconds 3 --hitcount 2 -j DROP

echo "protections anti-scan"
sudo iptables -N port-scanning
sudo iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST\
		 -m limit --limit 1/s --limit-burst 2 -j RETURN
sudo iptables -A port-scanning -j DROP
