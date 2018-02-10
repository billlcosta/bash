#!/bin/bash
#=======================================================#
#			Samba 4				#
# Created by.: pH					#
# Contact.: billlcosta@gmail.com			#
# Version.: 1.0						#
# Note.: Samba 4 Domain Controller			#
#							#
#=======================================================#

debian() {
	
	# Update system
	/usr/bin/apt-get update -y
	
	result=`echo $?`
	clear
		if [ "$result" = 0 ]; then
			echo "[ Sistema Operacional Atualizado ]"
			echo "[ Iniciando a instalação dos pacotes/dependências... ]"
			sleep 3
			clear
		else
			clear
			echo "ERROR.: Falha ao atualizar o Sistema Operacional."
			sleep 3
			exit
		fi

	# Install packages/dependencies
	/usr/bin/apt-get install gcc libreadline-dev git build-essential libattr1-dev libblkid-dev libgnutls28-dev autoconf python-dev \
	python-dnspython libacl1-dev gdb pkg-config libpopt-dev libldap2-dev dnsutils acl attr libbsd-dev docbook-xsl libcups2-dev wget perl ntp -y

	result=`echo $?`
	clear
		if [ "$result" = 0 ]; then
			echo "[ Pacotes e dependências instalados com sucesso. ]"
			echo "[ Atualizando Timezone, data e hora do servidor... ]"
			sleep 3
			clear
		else
			clear
			echo "ERROR.: Falha ao instalar pacotes/dependências."
			sleep 3
			exit
		fi
	
	# Ajust Timezone/Date/Time
	/bin/rm -rf /etc/localtime ; /bin/ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
	echo "server pool.ntp.br" >> /etc/ntp.conf
	/usr/bin/systemctl restart ntpd
	/usr/bin/systemctl enable ntpd
	
	echo "[ Data e hora atualizadas ]"
	echo "[ Baixando, compilando e instalando o Samba 4...]"
	sleep 3
	clear

	# Download, compile and install Samba 4
	/usr/bin/wget https://ftp.samba.org/pub/samba/samba-latest.tar.gz
	/bin/tar zxf samba-latest.tar.gz
	cd samba-4* && ./configure && /usr/bin/make && /usr/bin/make install && cd -

	echo "Instalação e compilação do samba realizada com sucesso."
	sleep 3

	echo "Promovendo o samba a Domain Controlles. Digite as informações solicitadass..."
	sleep 3
	/usr/local/samba/bin/samba-tool domain provision
	
	# Final adjustments
	echo "export PATH=$PATH:/usr/local/samba/sbin:/usr/local/samba/bin" >> /etc/profile
	echo "export PATH=$PATH:/usr/local/samba/sbin:/usr/local/samba/bin" >> /etc/bashrc
	/bin/cp /usr/local/samba/private/krb5.conf /etc/

	clear

	# Add script
	/bin/cp -par samba_debian /etc/init.d/samba
	/bin/chmod +x /etc/init.d/samba
	/bin/systemctl enable samba

	echo "Samba configurado com sucesso como Domain Controller."
	echo "Pressione Enter para sair"
	read
}

centos() {
	
	# Update system
	/usr/bin/yum update -y
	result=`echo $?`
	clear

		if [ "$result" = 0 ]; then
			echo "[ Sistema Operacional Atualizado ]"
			echo "[ Iniciando a instalação dos pacotes/dependências... ]"
			sleep 3
			clear
		else
			clear
			echo "ERROR.: Falha ao atualizar o Sistema Operacional."
			sleep 3
			exit
		fi

	# Install packages/dependencies
	/usr/bin/yum install epel-release install gcc libacl-devel libblkid-devel gnutls-devel wget perl ntp openldap-devel readline-devel \
	python-devel gdb pkgconfig krb5-workstation zlib-devel setroubleshoot-server setroubleshoot-plugins policycoreutils-python \
       	libsemanage-python setools-libs-python setools-libs popt-devel libpcap-devel sqlite-devel libidn-devel libxml2-devel \
	libacl-devel libsepol-devel libattr-devel  keyutils-libs-devel cyrus-sasl-devel cups-devel ntp perl wget -y

	result=`echo $?`
	clear
		if [ "$result" = 0 ]; then
			echo "[ Pacotes e dependências instalados com sucesso. ]"
			echo "[ Atualizando Timezone, data e hora do servidor... ]"
			sleep 3
			clear
		else
			clear
			echo "ERROR.: Falha ao instalar pacotes/dependências."
			sleep 3
			exit
		fi
	
	# Ajust Timezone/Date/Time
	/bin/rm -rf /etc/localtime ; /bin/ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
	echo "server pool.ntp.br" >> /etc/ntp.conf
	/usr/bin/systemctl restart ntpd
	/usr/bin/systemctl enable ntpd
	
	echo "[ Data e hora atualizadas ]"
	echo "[ Baixando, compilando e instalando o Samba 4...]"
	sleep 3
	clear

	# Download, compile and install Samba 4
	/usr/bin/wget https://ftp.samba.org/pub/samba/samba-latest.tar.gz
	/usr/bin/tar zxf samba-latest.tar.gz
	cd samba-4* && ./configure && /usr/bin/make && /usr/bin/make install && cd -
	/bin/mv /etc/krb5.conf /etc/krb5.conf_original

	echo "Instalação e compilação do samba realizada com sucesso."
	sleep 3

	echo "Promovendo o samba a Domain Controlles. Digite as informações solicitadass..."
	sleep 3
	/usr/local/samba/bin/samba-tool domain provision
	

	echo " Aplicando ajustes finais..."
	sleep 3

	# Final adjustments
	echo "export PATH=$PATH:/usr/local/samba/sbin:/usr/local/samba/bin" >> /etc/profile
	echo "export PATH=$PATH:/usr/local/samba/sbin:/usr/local/samba/bin" >> /etc/bashrc
	/bin/cp /usr/local/samba/private/krb5.conf /etc/

	clear

	# Add script
	/bin/cp -par samba_centos /etc/init.d/samba
	/bin/chmod +x /etc/init.d/samba
	/sbin/chkconfig add samba
	/sbin/chkconfig samba on

	echo "Samba configurado com sucesso como Domain Controller."
	echo "Pressione Enter para sair"
	read
}

#=============#
#=== Usage ===#
#=============#

if [ "$1" = "debian" ]; then

	debian

elif [ "$1" = "centos" ]; then

	centos

elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then

	echo "
	|--------------------------------------------------------------------------------------------------------|
	|                            Implementação do Samba 4 - Domain Controller                                |
	|                           ---------------------------------------------                                |
	|                                                                                                        |
	|                                                                                                        |
	| Criado por.: pH                                                                                        |
	| Contato.: billlcosta@gmail.com                                                                         |
	| Versão do script.: 1.0                                                                                 |
	|                                                                                                        |
	| Script desenvolvido para configuração do serviço Samba 4 (ultima versão stable) atuando como Domain    |
	|Controller. Todo o procedimento será realizado de forma automatizada, sem interação.                    |
	|                                                                                                        |
	| Nota.: O script foi desenvolvido para ambientes Debian 8 e Cent'OS 7.3 e seus derivados                |
	|                                                                                                        |
	|                                                                                                        |
	|                           Pacotes necessarios (serão instalados automaticamente)                       |
	|                           ------------------------------------------------------                       |
	|                                                                                                        |
	|                                                                                                        |
	| gcc libacl-devel libblkid-devel gnutls-devel wget perl ntp openldap-devel readline-devel               |
	| python-devel gdb pkgconfig krb5-workstation zlib-devel setroubleshoot-server                           |
	| setroubleshoot-plugins policycoreutils-python libsemanage-python setools-libs-python setools-libs      |
	| popt-devel libpcap-devel sqlite-devel libidn-devel libxml2-devel libacl-devel libsepol-devel           |
	| libattr-devel  keyutils-libs-devel cyrus-sasl-devel cups-devel                                         |
	|                                                                                                        |
	|                                                                                                        |
	|                                       Requisitos de Instalação                                         |
	|                                       ------------------------                                         |
	| * Acesso a Internet                                                                                    |
	| * Desabilitar o SELinux                                                                                |
	|                                                                                                        |
	|                                                                                                        |
	|                                               Instalação                                               |
	|                                              ------------                                              |
	|                                                                                                        |
	|                                                                                                        |
	| Debian 8 -  ./samba.sh debian                                                                          |
	| Cent'OS 7.3 - ./samba.sh centos                                                                        |
	|                                                                                                        |
	|--------------------------------------------------------------------------------------------------------|"

else

	echo "
	|--------------------------------------------------------------------------------------------------------|
	|                            Implementação do Samba 4 - Domain Controller                                |
	|                           ---------------------------------------------                                |
	|                                                                                                        |
	|                                                                                                        |
	| Criado por.: pH                                                                                        |
	| Contato.: billlcosta@gmail.com                                                                         |
	| Versão do script.: 1.0                                                                                 |
	|                                                                                                        |
	| Script desenvolvido para configuração do serviço Samba 4 (ultima versão stable) atuando como Domain    |
	|Controller. Todo o procedimento será realizado de forma automatizada, sem interação.                    |
	|                                                                                                        |
	| Nota.: O script foi desenvolvido para ambientes Debian 8 e Cent'OS 7.3 e seus derivados                |
	|                                                                                                        |
	|                                                                                                        |
	|                           Pacotes necessarios (serão instalados automaticamente)                       |
	|                           ------------------------------------------------------                       |
	|                                                                                                        |
	|                                                                                                        |
	| gcc libacl-devel libblkid-devel gnutls-devel wget perl ntp openldap-devel readline-devel               |
	| python-devel gdb pkgconfig krb5-workstation zlib-devel setroubleshoot-server                           |
	| setroubleshoot-plugins policycoreutils-python libsemanage-python setools-libs-python setools-libs      |
	| popt-devel libpcap-devel sqlite-devel libidn-devel libxml2-devel libacl-devel libsepol-devel           |
	| libattr-devel  keyutils-libs-devel cyrus-sasl-devel cups-devel                                         |
	|                                                                                                        |
	|                                                                                                        |
	|                                       Requisitos de Instalação                                         |
	|                                       ------------------------                                         |
	| * Acesso a Internet                                                                                    |
	| * Desabilitar o SELinux                                                                                |
	|                                                                                                        |
	|                                                                                                        |
	|                                               Instalação                                               |
	|                                              ------------                                              |
	|                                                                                                        |
	|                                                                                                        |
	| Debian 8 -  ./samba.sh debian                                                                          |
	| Cent'OS 7.3 - ./samba.sh centos                                                                        |
	|                                                                                                        |
	|--------------------------------------------------------------------------------------------------------|"

fi
