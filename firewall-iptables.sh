#!/bin/sh
#---------------------------------------------------------------------------------------------------------------#
#                                              Default Firewall State Full					       
#
# Version.: 2.0			 									      
# Modified.: 18/02/2016									       	       
# Modified by.: PH
# Contact.: Phillipe Farias | billlcosta@gmail.com
#
#
# Check List NIST - NIST Special Pub Recomendations for Firewall Policy Setup
#
# 1 - Loopback & Pseudo Interfaces Default Policy
# 2 - Anomaly IP
# 3 - Anomaly by Protocol
# 4 - Transformations
# 5 - Policy by Protocol
# 6 - Policy by Service
# 7 - Policy by Host
# 8 - Policy by Network
# 9 - IP Flow
# 10 - Default Firewall Policy
#
#---------------------------------------------------------------------------------------------------------------#

iptables="sudo $(which iptables)"

stop() {
        # Set your default policy of filter chain (tables input, output and forward)
        	$iptables -P INPUT ACCEPT
		$iptables -P OUTPUT ACCEPT
       		$iptables -P FORWARD ACCEPT

        # Set default policy of nat table
        	$iptables -t nat -P PREROUTING ACCEPT
	        $iptables -t nat -P POSTROUTING ACCEPT
	        $iptables -t nat -P OUTPUT ACCEPT

        # Flush rules of chain filter and nat
        	$iptables -F
		$iptables -F -t nat

        # Erases any chain outside standard of filter and nat
        	$iptables -X
}


start() {
		#Ativacao dos Modulos 
			sudo $(which  modprobe) ip_conntrack
			sudo $(which  modprobe) ip_tables
			sudo $(which  modprobe) ipt_MASQUERADE
			sudo $(which  modprobe) ipt_state
			sudo $(which  modprobe) iptable_nat
			sudo $(which  modprobe) ipt_LOG
			sudo $(which  modprobe) ipt_REJECT
			sudo $(which  modprobe) ip_nat_ftp
			sudo $(which  modprobe) ipt_string
			sudo $(which  modprobe) ipt_connlimit
		
		#Permite multiplas conexoes PPTP / GRE
			sudo $(which  modprobe) ip_gre
			sudo $(which  modprobe) nf_nat_pptp
			sudo $(which  modprobe) nf_conntrack_pptp
  
		#-----------------#
		#--- Variables ---#
		#-----------------#
		
		#--- Interfaces ---#
			lan_if="Set your lan interface here"
			wan_if="Set your wan interface here" 
			
		#--- IPs Address
			ip1="Set your IP address of wan interface here"
			ip2="Set your IP address of lan interface here"
			lan_network="x.x.x.x/xx"
			
		#--- Static variables ---#
			dns_hosts_wan="{8.8.8.8, 8.8.4.4, 208.67.222.222, 208.67.220.220}"
			ntp_hosts="{a.ntp.br, b.ntp.br}"
			
#---------------------------------------------------------------------------------------------------------------#			
#--				 1. Loopback & Pseudo Interfaces Default Policy 			     ---#
#---------------------------------------------------------------------------------------------------------------#

	 #Default Policy on Loopback Interfaces
		$iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -i lo -j ACCEPT
		$iptables -A OUTPUT -s 127.0.0.1 -d 127.0.0.1 -o lo -j ACCEPT
			  
#---------------------------------------------------------------------------------------------------------------#			
#---                                           	2. Anomaly IP 		     				     ---#
#---------------------------------------------------------------------------------------------------------------#

#Set your rules of anomaly by IP (input and outpu) here!

	 #Anomaly IP
		$iptables -N VALID_CHECK
		$iptables -A VALID_CHECK -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
		$iptables -A VALID_CHECK -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
		$iptables -A VALID_CHECK -p tcp --tcp-flags ALL ALL -j DROP
		$iptables -A VALID_CHECK -p tcp --tcp-flags ALL FIN -j DROP
		$iptables -A VALID_CHECK -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
		$iptables -A VALID_CHECK -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
		$iptables -A VALID_CHECK -p tcp --tcp-flags ALL NONE -j DROP
		$iptables -A INPUT -m state --state INVALID -j DROP
	  
#---------------------------------------------------------------------------------------------------------------#			
#---						 3. Anomaly by Protocol 				     ---#
#---------------------------------------------------------------------------------------------------------------#

#Set your rules of anomaly by protocol (input and outpu) here!

#-----------------------#
#---	  DoS 	     ---#
#-----------------------#

	#FLow of connections (HTTP)
		$iptables -A INPUT -d $ip1 -p tcp --syn --dport 80 -m connlimit --connlimit-above 30 --connlimit-mask 32 -j REJECT --reject-with tcp-reset

#---------------------------------------------------------------------------------------------------------------#			
#---						 4. Transformations 					     ---#
#---------------------------------------------------------------------------------------------------------------#

#Set your rules of transformations here!

#---------------------------------------------------------------------------------------------------------------#			
#---						 5. Policy by Protocol 					     ---#
#---------------------------------------------------------------------------------------------------------------#

#Set your rules of policy by protocol here!

#------------------------------------#
#---      INPUT/OUTPUT Rules      ---#
#------------------------------------#

	#--- DNS (WAN)
		$iptables -A INPUT -s $dns_hosts_wan -d $ip1 -m state --state ESTABLISHED,RELATED -i $wan_if -p udp --sport 53 -j ACCEPT
		$iptables -A OUTPUT -s $ip1 -d $dns_hosts_wan -m state --state NEW,ESTABLISHED,RELATED -o $wan_if -p udp --dport 53 -j ACCEPT
	
	#--- DNS (LAN)
		$iptables -A INPUT -d $ip2 -m state --state ESTABLISHED,RELATED -i $lan_if -p udp --sport 53 -j ACCEPT
		$iptables -A OUTPUT -s $ip2 -m state --state NEW,ESTABLISHED,RELATED -o $lan_if -p udp --dport 53 -j ACCEPT
	
	#--- NTP
	    $iptables -A INPUT -s $ntp_hosts -d $ip1 -m state --state ESTABLISHED,RELATED -i $wan_if -p udp --sport 123 -j ACCEPT
	    $iptables -A OUTPUT -s $ip1 -d $ntp_hosts -m state --state NEW,ESTABLISHED,RELATED -o $wan_if -p udp --dport 53 -j ACCEPT
	
	#--- SSH (WAN)
		$iptables -A INPUT -d $ip1 -m state --state NEW,ESTABLISHED,RELATED -i $wan_if -p tcp --dport 22 -j ACCEPT
		$iptables -A INPUT -d $ip1 -m state --state ESTABLISHED,RELATED -i $wan_if -p tcp --sport 22 -j ACCEPT
		$iptables -A OUTPUT -s $ip1 -m state --state NEW,ESTABLISHED,RELATED -o $wan_if -p tcp --dport 22 -j ACCEPT	
		$iptables -A OUTPUT -s $ip1 -m state --state ESTABLISHED,RELATED -o $wan_if -p tcp --sport 22 -j ACCEPT
		
	#--- SSH (LAN)
		$iptables -A INPUT -s $lan_network -d $ip2 -m state --state NEW,ESTABLISHED,RELATED -i $lan_if -p tcp --dport 22 -j ACCEPT	
		$iptables -A INPUT -s $lan_network -d $ip2 -m state --state ESTABLISHED,RELATED -i $lan_if -p tcp --sport 22 -j ACCEPT
		$iptables -A OUTPUT -s $ip2 -d $lan_network -m state --state NEW,ESTABLISHED,RELATED -o $lan_if -p tcp --dport 22 -j ACCEPT	
		$iptables -A OUTPUT -s $ip2 -d $lan_network -m state --state ESTABLISHED,RELATED -o $lan_if -p tcp --sport 22 -j ACCEPT
	
	#HTTP/HTTPS (Only Outbound)
		$iptables -A INPUT -d $ip1 -m state --state ESTABLISHED,RELATED -i $wan_if -p tcp -m multiport --sports 80,443 -j ACCEPT
		$iptables -A INPUT -d $ip2 -m state --state ESTABLISHED,RELATED -i $lan_if -p tcp -m multiport --sports 80,443 -j ACCEPT
		$iptables -A OUTPUT -s $ip1 -m state --state NEW,ESTABLISHED,RELATED -o $wan_if -p tcp -m multiport --dports 80,443 -j ACCEPT
		$iptables -A OUTPUT -s $ip2 -m state --state NEW,ESTABLISHED,RELATED -o $lan_if -p tcp -m multiport --dports 80,443 -j ACCEPT

#-----------------------------#
#---      FORWARD Rules    ---#
#-----------------------------#

	#--- DNS
		$iptables -A FORWARD -s $lan_network -d $hosts_dns_wan -m state --state NEW,RELATED,ESTABLISHED -i $lan_if -o $wan_if -p udp --dport 53 -j ACCEPT	
		$iptables -A FORWARD -s $hosts_dns_wan -d $lan_network -m state --state RELATED,ESTABLISHED -i $wan_if -o $lan_if -p udp --sport 53 -j ACCEPT	
	
	#--- NTP
		$iptables -A FORWARD -s $lan_network -d $hosts_ntp -m state --state NEW,RELATED,ESTABLISHED -i $lan_if -o $wan_if -p udp --dport 53 -j ACCEPT	
		$iptables -A FORWARD -s $hosts_ntp -d $lan_network -m state --state RELATED,ESTABLISHED -i $wan_if -o $lan_if -p udp --sport 53 -j ACCEPT	
	
	#--- SMTP/POP/IMAP
		$iptables -A FORWARD -s $lan_network -m state --state NEW,RELATED,ESTABLISHED -i $lan_if -o $wan_if -p tcp -m multiport --dports 25,110,587,143,465 -j ACCEPT	
		$iptables -A FORWARD -d $lan_network -m state --state RELATED,ESTABLISHED -i $wan_if -o $lan_if -p tcp -m multiport --sports 25,110,587,143,465 -j ACCEPT
		
	#--- HTTP/HTTPS
		$iptables -A FORWARD -s $lan_network -m state --state NEW,RELATED,ESTABLISHED -i $lan_if -o $wan_if -p tcp -m multiport --dports 80,443 -j ACCEPT	
		$iptables -A FORWARD -d $lan_network -m state --state RELATED,ESTABLISHED -i $wan_if -o $lan_if -p tcp -m multiport --sports 80,443 -j ACCEPT
	
	#--- ICMP (Only Ping)
		$iptables -A FORWARD -m state --state NEW,ESTABLISHED,RELATED -i $wan_if -o $lan_if -p icmp --icmp-type 0 -j ACCEPT
		$iptables -A FORWARD -m state --state NEW,ESTABLISHED,RELATED -i $wan_if -o $lan_if -p icmp --icmp-type 8 -j ACCEPT
		$iptables -A FORWARD -m state --state NEW,ESTABLISHED,RELATED -i $lan_if -o $wan_if -p icmp --icmp-type 0 -j ACCEPT
		$iptables -A FORWARD -m state --state NEW,ESTABLISHED,RELATED -i $lan_if -o $wan_if -p icmp --icmp-type 8 -j ACCEPT		
		
#---------------------------------------------------------------------------------------------------------------#			
#---						 6. Policy by Service 					     ---#
#---------------------------------------------------------------------------------------------------------------#

#Set your rules of policy by services here!

#----------------------------#
#---   PREROUTING Rules   ---#
#----------------------------#

	#--- Examples of rules from port redirect.:

		#$iptables -t nat -A PREROUTING -d $ip1 -m state --state NEW,ESTABLISHED,RELATED -p tcp --dport 3000 -j DNAT --to-destination 10.10.20.1:3000

#---------------------------------------------------------------------------------------------------------------#			
#---						 7. Policy by host 					     ---#
#---------------------------------------------------------------------------------------------------------------#

#Set your rules of policy by host here!

#-----------------------------#
#---      FORWARD Rules    ---#
#-----------------------------#

	#--- Example of rule by time
		#$iptables -A FORWARD -s 10.3.6.114 -m state --state NEW,ESTABLISHED,RELATED -i $lan_if -o $wan_if -m time --datestart 2015-08-26T08:00:00 --datestop 2015-08-30T19:00:00 -p tcp -m multiport --dports 3000,80,443 -j ACCEPT
		#$iptables -A FORWARD -d 10.3.6.114 -m state --state ESTABLISHED,RELATED -i $wan_if -o $lan_if -m time --datestart 2015-08-26T08:00:00 --datestop 2015-08-30T19:00:00  -p tcp -m  multiport --sports 3000,80,443 -j ACCEPT

#---------------------------------------------------------------------------------------------------------------#			
#---						 8. Policy by Network 					     ---#
#---------------------------------------------------------------------------------------------------------------#

#Set your rules of policy by network here!

#----------------------------#
#---   POSTROUTING  Rules ---#
#----------------------------#

	#--- Masquerade
                $iptables -t nat -A POSTROUTING -o $wan_if -j MASQUERADE

#---------------------------------------------------------------------------------------------------------------#			
#---						 9. IP Flow                                                  ---#
#---------------------------------------------------------------------------------------------------------------#

#Set your rules of IP flow here!

	#Enable IP Forward:
		echo 1 > /proc/sys/net/ipv4/ip_forward

	#Enable Drop IP Spoofing
		echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter

	#Enable TCP SYN Cookie Protection
		echo 1 >/proc/sys/net/ipv4/tcp_syncookies

	#Enable broadcast echo protection
		echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

	#Enable ICMP Request
		echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all

	#Enable IP spoofing protection, turn on Source Address Verification
		for f in /proc/sys/net/ipv4/conf/*/rp_filter; do
		    echo 1 > $f
		done
		
#---------------------------------------------------------------------------------------------------------------#			
#---						10. Default Firewall Policy 				     ---#
#---------------------------------------------------------------------------------------------------------------#

	#Default Firewall Policy
			$iptables -P INPUT DROP
			$iptables -P OUTPUT DROP
	        	$iptables -P FORWARD DROP

}	 

#---------------------------------------------------------------------------------------------------------------#
#---						 Esquema de utilizacao 					     ---#
#---------------------------------------------------------------------------------------------------------------#

if [ "$1" == "stop" ]; then
        echo "Stoping Firewall..."
        stop
        $iptables -F -t nat
        echo "Stoped!"
elif [ "$1" == "stop_notnat" ]; then
        echo "Stoping Firewall preserving NAT's..."
        stop
        echo "Stoped!"
elif [ "$1" == "restart" ]; then
        echo "Restarting Firewall..."
        stop
        start
        echo "Firewall Restarted!"
elif [ "$1" == "start" ]; then
        echo "Starting Firewall..."
        start
        echo "Firewall Started!"
elif [ "$1" == "status" ]; then
        $iptables -L -n
        $iptables -L -n -t nat
else
        echo "Usage: $0 {start|stop|stop_notnat|restart|status}"
        exit
fi
