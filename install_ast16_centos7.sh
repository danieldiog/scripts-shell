#!/bin/bash

read -p "Qual o usuário do GIT? " USUARIO_GIT
read -s -p "Qual a senha do GIT? " SENHA_GIT
echo " "
read -p "Qual a porta HTTPS? " PORTA_ACESSO_HTTPS
read -p "Qual o DNS para o CHAT? " DNS_CHAT
PORTA_ACESSO_HTTP=80

#VARIÁVEL DE LOG P/ ANALISAR ERROS
TIME=$(date +%d-%m-%Y" "%H:%M:%S)
FTP_USER=g4flex
FTP_PASS=g3quatro987123
/bin/echo "Analisando se o arquivo de log ja existe (caso exista, ele sera deletado e recriado)"

#CRIANDO ARQUIVO DE LOG ATERISK
if [ -e /var/log/log_script_g4 ]
then
	rm -rf /var/log/log_script_g4.log
	LOGFILE=/var/log/log_script_g4.log
        touch $LOGFILE
else 
	LOGFILE=/var/log/log_script_g4.log
	touch $LOGFILE
fi;


#GERANDO UM CABEÇALHO PARA O ARQUIVO DE LOG
echo "Log de configuracao do servidor G4Flex" | tee -a $LOGFILE
echo "Data de criacao: $TIME" | tee -a $LOGFILE
echo "Endereco do log: $LOGFILE" | tee -a $LOGFILE
echo "Quaisquer dúvidas/sugestões, falar com Rodrigo Mesquita" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE

#INICIANDO CONFIGURAÇÃO DO AMBIENTE ASTERISK

echo "#####################            Repositorios pre-instalacao            #####################" | tee -a $LOGFILE
	yum -y install epel-release;yum -y update yum;yum -y install nano vim

echo "Pacotes essenciais (pre-instalacao) ----------------------------------------------------------" | tee -a $LOGFILE
	yum -y install dialog man dmidecode telnet ntsysv lm_sensors tcpdump htop rsync net-tools
echo "" | tee -a $LOGFILE

sleep 2

echo " "
echo "+---------------------+" | tee -a $LOGFILE
echo "| Desabilitar SELINUX |" | tee -a $LOGFILE
echo "+---------------------+" | tee -a $LOGFILE
echo " "

	sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config 
	echo 0 > /sys/fs/selinux/enforce
echo "" | tee -a $LOGFILE
echo "SELINUX --------------------------------------------------------------------------------------" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE
	cat /etc/selinux/config | tee -a $LOGFILE
echo "SELINUX desabilitado." | tee -a $LOGFILE

echo ""
echo "+------------------------------------+" | tee -a $LOGFILE
echo "| Desabilitando e Mascando Firewalld |" | tee -a $LOGFILE # Procedimento necessario, pois usaremos o iptables
echo "+------------------------------------+" | tee -a $LOGFILE
echo ""
sleep 2
	service firewalld stop
	service disable firewalld
	systemctl mask firewalld                                                                                            # Mascarando o firewalld. isso deixa o iptables apto para atuar na maquina

echo "" | tee -a $LOGFILE
echo "Firewall -------------------------------------------------------------------------------------" | tee -a $LOGFILE 
echo "" | tee -a $LOGFILE
echo "Firewall desabilitado." | tee -a $LOGFILE	

echo ""
echo "+-----------------------------------------------------------------------------+" | tee -a $LOGFILE
echo "| Setando PROMPT=no em sysconfig/init para impedir inicializacao dos servicos |" | tee -a $LOGFILE
echo "+-----------------------------------------------------------------------------+" | tee -a $LOGFILE
echo ""
echo -e "#####ALTERADO PELA G4 PARA IMPEDIR INICIALIZAÇÃO INTERATIVA DE SERVIÇOS##### \nPROMPT=no" >> /etc/sysconfig/init
sleep 2

echo ""
echo "+--------------------------------------------------------------------+" | tee -a $LOGFILE
echo "| Configurando porta SSH para "port 5439" e bloquear login pelo root |" | tee -a $LOGFILE
echo "+--------------------------------------------------------------------+" | tee -a $LOGFILE
echo ""
	sed -i s/"#Port 22"/"Port 5439"/g /etc/ssh/sshd_config
sleep 1
	sed -i s/"#PermitRootLogin yes"/"PermitRootLogin no"/g /etc/ssh/sshd_config
	service sshd restart
echo "" | tee -a $LOGFILE 
echo "SSH ------------------------------------------------------------------------------------------" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE
echo "PermitRootLogin = no e SSH na porta 5439." | tee -a $LOGFILE

echo ""
echo "+----------------------------+" | tee -a $LOGFILE
echo "| Criando pastas necessarias |" | tee -a $LOGFILE
echo "+----------------------------+" | tee -a $LOGFILE
echo ""
cd /opt/
mkdir packages
mkdir java
mkdir install
echo "" | tee -a $LOGFILE
echo "Diretorios -----------------------------------------------------------------------------------" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE
echo "Diretorios packages, java e install criados!" | tee -a $LOGFILE

cd packages

echo ""
echo "+---------------------------------------------------+" | tee -a $LOGFILE
echo "| Instalando pacotes RPM-FORGE para as dependencias |" | tee -a $LOGFILE
echo "+---------------------------------------------------+" | tee -a $LOGFILE
echo ""
sleep 2

	if [ -e "/opt/packages/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm" ]; then
		echo "Pacotes RPM-FORGE ja instalados!" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE
	else
		echo "" | tee -a $LOGFILE
		echo "Instalacao pacotes RPM-FORGE --------------------------------------------------------------------------" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE
		wget -nc http://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
		rpm -Uhv rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm | tee -a $LOGFILE
		echo ""
		yum -y update yum | tee -a $LOGFILE
		rm -rf rpmforge-release*
	fi;

echo ""
echo "+-----------------------------------+" | tee -a $LOGFILE
echo "| Instalando os pacotes necessarios |" | tee -a $LOGFILE
echo "+-----------------------------------+" | tee -a $LOGFILE
echo ""
sleep 2
	
echo "" | tee -a $LOGFILE
echo "Pacotes necessarios --------------------------------------------------------------------------" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE

	yum -y install deltarpm # ANTES DO PACKAGES , PRECISA INSTALAR DELTARPM
	yum -y install audiofile audiofile-devel audit audit-libs audit-libs-python audit-viewer bison unzip* | tee -a $LOGFILE
	yum -y install bacula-client bzip2 cabextract crontabs curl-devel doxygen expect fftw fftw-devel flex fltk fltk-devel  | tee -a $LOGFILE
	yum -y install gamin gamin-python make.x86_64 gcc gcc-c++ glibc-devel htop iptraf lame libtermcap-devel libtiff | tee -a $LOGFILE
	yum -y install libtiff-devel libtool-ltdl libtool-ltdl-devel libxml2* lynx mlocate mod_ssl mutt | tee -a $LOGFILE
	yum -y install ncurses-devel newt-devel nmap ntp openssl openssl-devel pcmanfm postfix perl perl-Crypt-SSLeay | tee -a $LOGFILE
	yum -y install perl-Net-SSLeay screen sendmail sendmail-cf m4 mailx sox spawn speex speex-devel system-config-audit | tee -a $LOGFILE
	yum -y install tar twm unixODBC unixODBC-devel vim* vixie-cron wget xorg-x11-xkb-utils xterm zlib-devel nrpe nagios-nrpe | tee -a $LOGFILE
	yum -y install yfping nagios-plugins perl-Crypt-DES perl-Net-SNMP perl-Net-SSLeay nc nfs* system-config-firewall net-snmp* traceroute | tee -a $LOGFILE
	yum -y localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm | tee -a $LOGFILE
	yum -y install ffmpeg ffmpeg-devel jv

echo "" | tee -a $LOGFILE
echo "Pacotes necessarios baixados." | tee -a $LOGFILE	

echo ""
echo "+----------------+" | tee -a $LOGFILE
echo "| Instalando SHC |" | tee -a $LOGFILE
echo "+----------------+" | tee -a $LOGFILE
echo ""
sleep 2

echo "" | tee -a $LOGFILE
echo "SHC ------------------------------------------------------------------------------------------" | tee -a $LOGFILE
  
	wget -c http://www.datsi.fi.upm.es/~frosal/sources/shc-3.8.9b.tgz
	tar -zvxf shc-3.8.9b.tgz
	cd shc-3.8.9b
	rm -rf ../shc-3.8.9b.tgz
	make
	mkdir -p  /usr/local/man/man1
	yes | make install
	which shc
	cd ..
	 	
echo "SHC instalado!" | tee -a $LOGFILE
sleep 2	

echo ""
echo "+--------------------------+" | tee -a $LOGFILE
echo "| Instalando Postgresql 10 |" | tee -a $LOGFILE
echo "+--------------------------+" | tee -a $LOGFILE
echo ""
sleep 2
	
	if [ -e "/usr/lib/systemd/system/postgresql-10.service" ]; then
	
		echo "" | tee -a $LOGFILE
		echo "PostGreSQL-10 --------------------------------------------------------------------------------" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE
		echo "$Postgresql 10 ja instalado no servidor!" | tee -a $LOGFILE
		
	else
		echo "" | tee -a $LOGFILE
		echo "---------------------------------------- PostGreSQL-10 ---------------------------------------" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE

		#wget --no-check-certificate https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
		#rpm -Uvh pgdg-redhat-repo-latest.noarch.rpm | tee -a $LOGFILE
    #	rm -rf pgdg-redhat-repo-latest.noarch.rpm
		wget ftp://g4flex:g3quatro987123@homologacao.g4flex.com.br/pgsql10/pgdg-centos10-10-2.noarch.rpm
		rpm -Uvh pgdg-centos10-10-2.noarch.rpm | tee -a $LOGFILE
		echo ""
		yum -y install postgresql10-server postgresql10 | tee -a $LOGFILE
		echo ""
		echo ""
		
		echo ""
		echo "Iniciando database postgresql"
		sleep 3
		/usr/pgsql-10/bin/postgresql-10-setup initdb
		systemctl start postgresql-10.service
		systemctl enable postgresql-10.service
		setenforce 0
		
		sleep 2
		
		systemctl stop postgresql-10.service
	
		echo "" | tee -a $LOGFILE
		echo "Configurando o PostgreSQL: postgresql.conf" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE
	
		echo "+-----------------------------------------------------------------------------+" | tee -a $LOGFILE
		echo "| Editando o arquivo postgresql.conf                                          |" | tee -a $LOGFILE
		echo "| Alterar a linha #listen_addresses = "localhost" para listen_addresses = "*" |" | tee -a $LOGFILE
		echo "| Alterar a linha max_connections = 100 para max_connections = 1500           |" | tee -a $LOGFILE
		echo "| Alterar a linha datestyle = 'iso, dmy  para datestyle = 'iso, mdy           |" | tee -a $LOGFILE
		echo "+-----------------------------------------------------------------------------|" | tee -a $LOGFILE
		sleep 2

		cd /var/lib/pgsql/10/data
		sed -i s/"#listen_addresses = 'localhost'"/"listen_addresses = '*'"/g /var/lib/pgsql/10/data/postgresql.conf
		sed -i s/"max_connections = 100"/"max_connections = 1500"/g /var/lib/pgsql/10/data/postgresql.conf
		sed -i s/"datestyle = 'iso, dmy'"/"datestyle = 'iso, mdy'"/g /var/lib/pgsql/10/data/postgresql.conf
		sed -i 's/UTC/America\/Fortaleza/g' /var/lib/pgsql/10/data/postgresql.conf
		sed -i 's/US\/Central/America\/Fortaleza/g' /var/lib/pgsql/10/data/postgresql.conf

		echo "" | tee -a $LOGFILE
		echo "Configurando o PostgreSQL: pg_hba.conf" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE
		
		echo "+---------------------------------------------+" | tee -a $LOGFILE
		echo "| Editando o arquivo pg_hba.conf              |" | tee -a $LOGFILE
		echo "| Alterar as linhas                           |" | tee -a $LOGFILE
		echo "| local   all    all    peer                  |" | tee -a $LOGFILE
		echo "| host    all    all    127.0.0.1/32    ident |" | tee -a $LOGFILE
		echo "| host    all    all    ::1/128         ident |" | tee -a $LOGFILE
		echo "+---------------------------------------------+" | tee -a $LOGFILE
		sleep 2 
		
		mv pg_hba.conf pg_hba.conf.original
		wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/centos7/postgresql-10/pg_hba.conf
		
		echo ""                                                                      >> /var/lib/pgsql/10/data/pg_hba.conf
		echo " #--------- Editado pela G4 ---------"                                 >> /var/lib/pgsql/10/data/pg_hba.conf
		echo ""                                                                      >> /var/lib/pgsql/10/data/pg_hba.conf
		echo "# TYPE  DATABASE        USER            ADDRESS                 METHOD">> /var/lib/pgsql/10/data/pg_hba.conf
		echo ""                                                                      >> /var/lib/pgsql/10/data/pg_hba.conf
		echo "# local is for Unix domain socket connections only"                    >> /var/lib/pgsql/10/data/pg_hba.conf
		echo "local   all             all                                     trust" >> /var/lib/pgsql/10/data/pg_hba.conf
		echo "# IPv4 local connections:"                                             >> /var/lib/pgsql/10/data/pg_hba.conf
 		echo "host    all             all             127.0.0.1/32            trust" >> /var/lib/pgsql/10/data/pg_hba.conf
		echo "# IPv6 local connections:"                                             >> /var/lib/pgsql/10/data/pg_hba.conf
		echo "host    all             all             ::1/128                 trust" >> /var/lib/pgsql/10/data/pg_hba.conf
		
		chown postgres:postgres pg_hba*
		
		echo "Postgresql 10.2 instalado e configurado!" | tee -a $LOGFILE
	fi;
echo "" | tee -a $LOGFILE

echo "Nano -----------------------------------------------------------------------------------------" | tee -a $LOGFILE

echo ""
echo "+---------------------+" | tee -a $LOGFILE
echo "| Configurando o nano |" | tee -a $LOGFILE
echo "+---------------------+" | tee -a $LOGFILE
echo ""
sleep 2

cd /usr/share/
groupadd suporte
groupadd simplegroup #grupo p/ o cliente poder reiniciar o TOMCAT
wget -nc ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/arquivos_de_configuracao/asterisk.nanorc | tee -a $LOGFILE
chown root:suporte /usr/share/asterisk.nanorc
wget -nc ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/arquivos_de_configuracao/nanorc | tee -a $LOGFILE
mv nanorc .nanorc
chown root:suporte .nanorc
ln -s /usr/share/.nanorc /root/.nanorc

echo "Nano configurado!" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE

echo "" | tee -a $LOGFILE
echo "Configuracao do Bash Restrito ----------------------------------------------------------------" | tee -a $LOGFILE
     
echo "" | tee -a $LOGFILE
echo "+----------------------+" | tee -a $LOGFILE
echo "| Configurando o rbash |" | tee -a $LOGFILE
echo "+----------------------+" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE
sleep 2

cd /bin
ln -s bash rbash

echo "Bash restrito configurado!" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE

echo "Configurando Usuarios ------------------------------------------------------------------------" | tee -a $LOGFILE

echo "" | tee -a $LOGFILE
echo "+-------------------------+" | tee -a $LOGFILE
echo "| Adicionando os Usuarios |" | tee -a $LOGFILE
echo "+-------------------------+" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE
	
set +H
password="g4!@#\$Fl3x987123"
pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
	
	useradd -m -c 'Rodrigo Mesquita' -d /home/rodrigomesquita -s '/bin/bash' rodrigomesquita -p $pass -g suporte
echo 'usuario Rodrigo Mesquita criado' | tee -a $LOGFILE 
sleep 1
cd /home/rodrigomesquita/
	ln -s  /usr/share/.nanorc .nanorc	

	useradd -m -c 'Cristiano Sobrinho' -d /home/cristianosobrinho -s '/bin/bash' cristianosobrinho -p $pass -g suporte
echo 'usuario Cristiano Sobrinho criado' | tee -a $LOGFILE 
sleep 1
cd /home/cristianosobrinho/
	ln -s  /usr/share/.nanorc .nanorc

	useradd -m -c 'Daniel Diogenes' -d /home/danieldiogenes -s '/bin/bash' danieldiogenes -p $pass -g suporte
echo 'usuario Daniel Diogenes criado' | tee -a $LOGFILE 
sleep 1
cd /home/danieldiogenes/
	ln -s  /usr/share/.nanorc .nanorc

	useradd -m -c 'Leandro Sobral' -d /home/leandrosobral -s '/bin/bash' leandrosobral -p $pass -g suporte
echo 'usuario Leandro Sobral criado' | tee -a $LOGFILE 
sleep 1
cd /home/leandrosobral/
	ln -s  /usr/share/.nanorc .nanorc	

	useradd -m -c 'Tarcisio Oliveira' -d /home/tarcisiooliveira -s '/bin/bash' tarcisiooliveira -p $pass -g suporte
echo 'usuario Tarcisio Oliveira criado' | tee -a $LOGFILE
   sleep 1
cd /home/tarcisiooliveira/
   ln -s  /usr/share/.nanorc .nanorc

         useradd -m -c 'David Cavalcante' -d /home/davidcavalcante -s '/bin/bash' davidcavalcante -p $pass -g suporte
   echo 'usuario David Cavalcante criado' | tee -a $LOGFILE
   sleep 1
   cd /home/davidcavalcante/
   ln -s  /usr/share/.nanorc .nanorc

        useradd -m -c 'Helder Pereira' -d /home/helderpereira -s '/bin/bash' helderpereira -p $pass -g suporte
   echo 'usuario Helder Pereira criado' | tee -a $LOGFILE 
   sleep 1
   cd /home/helderpereira/
   ln -s  /usr/share/.nanorc .nanorc

        useradd -m -c 'Mardson Oliveira' -d /home/mardsonoliveira -s '/bin/bash' mardsonoliveira -p $pass -g suporte
   echo 'usuario Mardson Oliveira criado' | tee -a $LOGFILE 
   sleep 1
   cd /home/mardsonoliveira/
   ln -s  /usr/share/.nanorc .nanorc

        useradd -m -c 'Daniel Alves' -d /home/danielalves -s '/bin/bash' danielalves -p $pass -g suporte
   echo 'usuario Daniel Alves criado' | tee -a $LOGFILE 
   sleep 1
   cd /home/danielalves/
   ln -s  /usr/share/.nanorc .nanorc

        useradd -m -c 'Alyson Veras' -d /home/alysonveras -s '/bin/bash' alysonveras -p $pass -g suporte
   echo 'usuario Alyson Veras criado' | tee -a $LOGFILE 
   sleep 1
   cd /home/alysonveras/
   ln -s  /usr/share/.nanorc .nanorc

        useradd -m -c 'Lucas Vicente' -d /home/lucasvicente -s '/bin/bash' lucasvicente -p $pass -g suporte
   echo 'usuario Lucas Vicente criado' | tee -a $LOGFILE 
   sleep 1
   cd /home/lucasvicente/
   ln -s  /usr/share/.nanorc .nanorc

        useradd -m -c 'Hiago Araujo' -d /home/hiagoaraujo -s '/bin/bash' hiagoaraujo -p $pass -g suporte
   echo 'usuario Hiago Araujo criado' | tee -a $LOGFILE 
   sleep 1
   cd /home/hiagoaraujo/
   ln -s  /usr/share/.nanorc .nanorc

        useradd -m -c 'Yascara Ribeiro' -d /home/yascararibeiro -s '/bin/bash' yascararibeiro -p $pass -g suporte
   echo 'usuario Yascara Ribeiro criado' | tee -a $LOGFILE 
   sleep 1
   cd /home/yascararibeiro/
   ln -s  /usr/share/.nanorc .nanorc

	password="S1mpl3Cl1ent3!@#"
   pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
   useradd -m -c 'Conta para cliente utilizar alguns comandos' -d /home/simpleclient -s '/bin/rbash' simpleclient -p $pass -g simplegroup
	chage -d 0 simpleclient
echo 'usuario Simple Client criado' | tee -a $LOGFILE
   sleep 1
   cd /home/simpleclient/
   ln -s  /usr/share/.nanorc .nanorc
    /usr/bin/chage -d 0 rodrigomesquita
    /usr/bin/chage -d 0 cristianosobrinho
    /usr/bin/chage -d 0 danieldiogenes
    /usr/bin/chage -d 0 tarcisiooliveira
    /usr/bin/chage -d 0 leandrosobral
    /usr/bin/chage -d 0 helderpereira
    /usr/bin/chage -d 0 lucasvicente
    /usr/bin/chage -d 0 mardsonoliveira
    /usr/bin/chage -d 0 danielalves
    /usr/bin/chage -d 0 alysonveras
    /usr/bin/chage -d 0 hiagoaraujo
    /usr/bin/chage -d 0 yascararibeiro

echo "" | tee -a $LOGFILE
echo "Usuarios criados e configurados!" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE

echo "Sudoers --------------------------------------------------------------------------------------" | tee -a $LOGFILE

echo "" | tee -a $LOGFILE
echo "+---------------------------------+" | tee -a $LOGFILE
echo "| Adicionando usuarios no Sudoers |" | tee -a $LOGFILE	
echo "+---------------------------------+" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE
sleep 2

	if [ "`cat /etc/sudoers | grep -o "Permissao usuarios G4"`" = "Permissao usuarios G4" ]; then
       	echo "" | tee -a $LOGFILE
		echo "Usuarios ja adicionados no arquivo!" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE
	else
		cd /etc/
		cp sudoers sudoers.old
		echo " " >> /etc/sudoers 
		echo "## Permissao usuarios G4" >> /etc/sudoers
		echo "danieldiogenes    ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
		echo "rodrigomesquita   ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
		echo "leandrosobral     ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
		echo "cristianosobrinho ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
		echo "davidcavalcante   ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
		echo "tarcisiooliveira  ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
		echo "helderpereira     ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
		echo "lucasvicente      ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
		echo "mardsonoliveira   ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
		echo "danielalves       ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
		echo "alysonveras       ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
		echo "hiagoaraujo       ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
		echo "yascararibeiro    ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers
		echo "simpleclient      ALL=(ALL)    NOPASSWD: /sbin/poweroff,/sbin/shutdown" >> /etc/sudoers
		echo "" | tee -a $LOGFILE
		echo "Usuarios adicionados no Sudoers!" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE	
    fi;	

echo "Editando o bashrc ----------------------------------------------------------------------------" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE

cd /usr/src/
wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/arquivos_de_configuracao/.bashrc | tee -a $LOGFILE
yes | cp .bashrc /root/

sleep 2

echo "+--------------------------------+" | tee -a $LOGFILE
echo "| Ativando keepcache no yum.conf |" | tee -a $LOGFILE
echo "+--------------------------------+" | tee -a $LOGFILE

sed -i "s/keepcache=0/keepcache=1/g" /etc/yum.conf

if [ -e "/etc/ntp.conf.old" ]; then
	echo "" | tee -a $LOGFILE
	echo "Arquivo ntp.conf.old ja existe!" | tee -a $LOGFILE
	echo "" | tee -a $LOGFILE
else
	cd /etc
	mv ntp.conf ntp.conf.old
	wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/arquivos_de_configuracao/ntp.conf | tee -a $LOGFILE
	chown root:root /etc/ntp.conf
fi;	
	echo "ADICIONANDO PARÂMETROS EM CONEXÕES TCP PARA IMPEDIR QUE O FLEXUC CAIA QUANDO UM GRANDE NÚMERO DE USUÁRIOS ABRIREM O MONITORAMENTO" | tee -a $LOGFILE
	echo -e "\n# Recycle and Reuse TIME_WAIT sockets faster\nnet.ipv4.tcp_tw_recycle = 1\nnet.ipv4.tcp_tw_reuse = 1\nnet.ipv4.tcp_timestamps = 0" >> /etc/sysctl.conf
	echo "___Parâmetro Recycle e Reuse para TIME_WAIT tcp connections foram adicionados.. ______" | tee -a $LOGFILE

	echo "##################INSTALANDO O SNGREP########################" | tee -a $LOGFILE
	echo -e "[irontec]\nname=Irontec RPMs repository\nbaseurl=http://packages.irontec.com/centos/\$releasever/\$basearch/" > /etc/yum.repos.d/irontec.repo
	rpm --import http://packages.irontec.com/public.key | tee -a $LOGFILE
	yum -y install sngrep | tee -a $LOGFILE
	echo "################## FIM DA INSTALAÇÃO DO SNGREP################## " | tee -a $LOGFILE

		echo "" | tee -a $LOGFILE
	echo "Java -----------------------------------------------------------------------------------------" | tee -a $LOGFILE
	echo "" | tee -a $LOGFILE
	
	echo "+-----------------+" | tee -a $LOGFILE
	echo "| Instalando JAVA |" | tee -a $LOGFILE
	echo "+-----------------+" | tee -a $LOGFILE
	sleep 2

	if [ -d "/opt/java/jdk1.8.0" ]; then

		echo "Java ja esta instalado no servidor!" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE
	else
			
		cd /opt/java
		wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/aplicativos/jdk-8u111-linux-x64.tar.gz | tee -a $LOGFILE
		tar zxvf jdk-* | tee -a $LOGFILE
		mv jdk1.8.*/ jdk1.8.0
		rm -rf jdk-*
		
		JAVA_HOME=/opt/java/jdk1.8.0
		export JAVA_HOME
		echo "JAVA_HOME: $JAVA_HOME" | tee -a $LOGFILE
		PATH=$PATH:$JAVA_HOME/bin
		export PATH
		echo "PATH: $PATH" | tee -a $LOGFILE
		CLASSPATH=$JAVA_HOME/lib
		export CLASSPATH
		echo "CLASSPATH: $CLASSPATH" | tee -a $LOGFILE
		MANPATH=$MANPATH:$JAVA_HOME/man
		export MANPATH
		
		echo "JAVA_HOME=/opt/java/jdk1.8.0" >> /etc/profile
		echo "export JAVA_HOME" >> /etc/profile
		echo "PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile
		echo "export PATH" >> /etc/profile
		echo "CLASSPATH=$JAVA_HOME/lib" >> /etc/profile
		echo "export CLASSPATH" >> /etc/profile
		echo "MANPATH=$MANPATH:$JAVA_HOME/man" >> /etc/profile
		echo "export MANPATH" >> /etc/profile
		
		echo "" | tee -a $LOGFILE
		echo "Java instalado!" | tee -a $LOGFILE
		sleep 2
	fi;

echo "Copiando/compilando servicos (p/ /usr/src/) ------------------------------------------------------" | tee -a $LOGFILE
	
	echo ""
	echo "+----------------------------------------------------------------------+" | tee -a $LOGFILE
	echo "| Copiando e compilando os servicos selecionados no menu para /usr/src |" | tee -a $LOGFILE
	echo "+----------------------------------------------------------------------+" | tee -a $LOGFILE
	sleep 2
	
	cd /usr/src
	echo "" | tee  -a $LOGFILE
	echo "SpanDSP --------------------------------------------------------------------------------------" | tee -a $LOGFILE
	echo "" | tee -a $LOGFILE
	
	echo ""
	echo "+----------------------+" | tee -a $LOGFILE
	echo "| Instalando o SpanDSP |" | tee -a $LOGFILE
	echo "+----------------------+" | tee -a $LOGFILE
	echo ""
	sleep 3
	cd /usr/src
	wget -nc ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/drivers/spandsp-0.0.6pre18.tgz | tee -a $LOGFILE
	tar zxvf spandsp* | tee -a $LOGFILE
	cd spandsp*
	make clean | tee -a $LOGFILE
	./configure --prefix=/usr | tee -a $LOGFILE
	make | tee -a $LOGFILE
	make install | tee -a $LOGFILE
	cd ..
	echo "" | tee -a $LOGFILE
	echo "Modulo do Span finalizado!" | tee -a $LOGFILE
	sleep 2
		echo "PACOTES PRÉ-INSTALAÇÃO ASTERISK 16" | tee -a $LOGFILE
		yum -y groupinstall "Development Tools"
		yum -y install libedit-devel sqlite-devel psmisc gmime-devel ncurses-devel libtermcap-devel sox newt-devel libxml2-devel libtiff-devel audiofile-devel gtk2-devel uuid-devel libtool libuuid-devel subversion kernel-devel kernel-devel-$(uname -r) git subversion kernel-devel crontabs cronie cronie-anacron wget vim

		echo "INSTALANDO JANSSON"  | tee -a $LOGFILE
		cd /usr/src/
		git clone https://github.com/akheron/jansson.git
		cd jansson
		autoreconf  -i
		./configure --prefix=/usr/
		make && make install
		sleep 2

		#echo "INSTALANDO PJSIP-PROJECT"  | tee -a $LOGFILE
		#cd /usr/src/ 
		#export VER="2.8"
		#wget http://www.pjsip.org/release/${VER}/pjproject-${VER}.tar.bz2
		#tar -jxvf pjproject-${VER}.tar.bz2
		#cd pjproject-${VER}
		#./configure CFLAGS="-DNDEBUG -DPJ_HAS_IPV6=1" --prefix=/usr --libdir=/usr/lib64 --enable-shared --disable-video --disable-sound --disable-opencore-amr
		#make dep
		#make
		#make install
		#ldconfig
		#sleep 2
		
		echo "INSTALANDO ASTERISK 16"
		cd /usr/src/
		wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz
		tar xvfz asterisk-16-current.tar.gz
		rm -f asterisk-16-current.tar.gz
		cd asterisk-*
		./contrib/scripts/install_prereq install
		./configure --libdir=/usr/lib64 --with-postgres=/usr/pgsql-10 --with-jansson-bundled
		make menuselect
		contrib/scripts/get_mp3_source.sh
		make
		make install
		make samples
		make config
		ldconfig
		sleep 2

		#add-ons :
		#chan_ooh323
		#format_mp3
		#codec translators
		#external > todos
		#core:
		#core-soundes-en-gsm
		echo "CRIADO AS PERMISSÕES DE EXECUÇÃO ASTERISK 16"
		groupadd asterisk
		useradd -r -d /var/lib/asterisk -g asterisk asterisk
		usermod -aG audio,dialout asterisk
		chown -R asterisk.asterisk /etc/asterisk
		chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
		chown -R asterisk.asterisk /usr/lib64/asterisk
		sed -i s/\#AST_USER=\"asterisk\"/AST_USER=\"asterisk\"/g /etc/selinux/config /etc/sysconfig/asterisk
		sed -i s/\#AST_GROUP=\"asterisk\"/AST_GROUP=\"asterisk\"/g /etc/selinux/config /etc/sysconfig/asterisk
		echo "runuser = asterisk" >> /etc/asterisk/asterisk.conf
		echo "rungroup = asterisk" >> /etc/asterisk/asterisk.conf
		systemctl restart asterisk
		systemctl enable asterisk

			echo "" | tee -a $LOGFILE
			echo "+------------------------------------------+" | tee -a $LOGFILE
			echo "| Instalando o codec g729 para Asterisk 16 |" | tee -a $LOGFILE
			echo "+------------------------------------------+" | tee -a $LOGFILE
			echo "" | tee -a $LOGFILE
			sleep 3
			if [ -e "/usr/lib64/asterisk/modules/codec_g729.so" ]; then
				echo "Codec g729 ja existe!" | tee -a $LOGFILE
           	else
           		cd /usr/lib64/asterisk/modules/
				wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/centos7/codec-g729/codec_g729.so | tee -a $LOGFILE
				chmod u+x codec_g729.so
			    chown root:suporte codec_g729.so
				service asterisk restart
			fi;
				echo "" | tee -a $LOGFILE
				echo "Instalacao do Codec G729 finalizada!" | tee -a $LOGFILE
		sleep 2		

	if [ -d "/etc/asterisk" ]; then 
	
		echo "" | tee -a $LOGFILE
		echo "Copiando os arquivos da G4Flex ---------------------------------------------------------------" | tee -a $LOGFILE
	
		echo "" | tee -a $LOGFILE
		echo "+-----------------------------------------------------------------+" | tee -a $LOGFILE
		echo "| Copiando os arquivos de configuracao da G4 Flex para o Asterisk |" | tee -a $LOGFILE
		echo "+-----------------------------------------------------------------+" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE
		sleep 3
		if [ -d "/etc/asterisk/contextos" ]; then
			echo "Arquivos de configuracao padrao G4 ja existe!" | tee -a $LOGFILE
		else
			service asterisk stop
			cd /etc/asterisk
			wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/centos7/etc-asterisk/etc-asterisk.tar.gz | tee -a $LOGFILE
			yes | tar xfvz etc-asterisk.tar.gz
			rm -rf etc-asterisk.tar.gz
			echo "" | tee -a $LOGFILE
			echo "Copia dos arquivos finalizada!" | tee -a $LOGFILE
			sleep 2
			
		fi;
	else
		clear
        	echo "" | tee -a $LOGFILE
        	echo "+----------------------------------------------------+" | tee -a $LOGFILE
        	echo "| A pasta /etc/asterisk nao existe,                  |" | tee -a $LOGFILE
        	echo "| Asterisk nao foi compilado corretamente            |" | tee -a $LOGFILE
        	echo "| verificar o problema e executar o script novamente |" | tee -a $LOGFILE
		echo "| (arquivos nao serao enviados)!    	           |" | tee -a $LOGFILE
        	echo "+----------------------------------------------------+" | tee -a $LOGFILE
        	echo "" | tee -a $LOGFILE
        	sleep 6
        	exit
        fi;			
echo "" | tee -a $LOGFILE
	echo "SNMP ---------------------------------------------------------------------------------------------" | tee -a $LOGFILE
		
	if [ -e "/etc/snmp/snmpd.conf.old" ]; then

		echo "Arquivo snmpd.conf ja instalado!" | tee -a $LOGFILE
	else
		echo "" | tee -a $LOGFILE
		echo "+-------------------+" | tee -a $LOGFILE
		echo "| Configurando SNMP |" | tee -a $LOGFILE
		echo "+-------------------+" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE
		sleep 2
		#yes | mv /home/instalacao/Arquivos_de_Configuracao/snmpd.conf /etc/snmp/
		cd /etc/snmp/
		mv snmpd.conf snmpd.conf.old
		wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/arquivos_de_configuracao/snmpd.conf | tee -a $LOGFILE
		chown root:root /etc/snmp/ -R
		echo "" | tee -a $LOGFILE
		echo "Instalacao do SNMP finalizada!" | tee -a $LOGFILE
		sleep 2        
	fi;

    echo "" | tee -a $LOGFILE
	echo "Sounds (Asterisk) ----------------------------------------------------------------------------" | tee -a $LOGFILE
	
	if [ -d "/var/lib/asterisk/sounds" ]; then
 		
 		if [ -e "/var/lib/asterisk/sounds/en/digits/g4flex.txt" ]; then
 			echo "Audios padrao G4 ja existem em /var/lib/asterisk/sounds/en/digits!" | tee -a $LOGFILE
 		else

			echo "" | tee -a $LOGFILE
			echo "+------------------------------------------------------------------------------------+" | tee -a $LOGFILE
			echo "| Copiando os Audios/prompts padrao G4 Flex para /var/lib/asterisk/sounds/en/digits/ |" | tee -a $LOGFILE
			echo "+------------------------------------------------------------------------------------+" | tee -a $LOGFILE
			echo "" | tee -a $LOGFILE
			sleep 3
			
            cd /var/lib/asterisk/sounds/en/digits/
			wget -nc ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/audios/digiportugues.tar.gz | tee -a $LOGFILE
			tar -zxvf digiportugues.tar.gz | tee -a $LOGFILE
			rm -rf digiportugues.tar.gz

			#ADICIONADO ÁUDIOS DE ESPERA DE FILA
			wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/audios/audiosfilabr.tar.gz | tee -a $LOGFILE
			yes | tar -zxvf audiosfilabr.tar.gz | tee -a $LOGFILE
			rm -rf audiosfilabr.tar.gz 

			#ADICIONADO ÀUDIOS DE CALLCENTER
			wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/audios/agentpaused.wav
			wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/audios/notallowed.wav

			touch g4flex.txt
			cd ..
		fi;
	fi;	        

if [ -e "/var/lib/asterisk/sounds/en/g4flex.txt" ]; then
			echo "" | tee -a $LOGFILE
			echo "Audios padrao G4 ja existem: /var/lib/asterisk/sounds/en/!" | tee -a $LOGFILE
		else
		
			echo "" | tee -a $LOGFILE
			echo "+-----------------------------------------------------------------------------+" | tee -a $LOGFILE
			echo "| Copiando os Audios/prompts padrao G4 Flex para /var/lib/asterisk/sounds/en/ |" | tee -a $LOGFILE
			echo "+-----------------------------------------------------------------------------+" | tee -a $LOGFILE
			echo "" | tee -a $LOGFILE
			
            cd /var/lib/asterisk/sounds/en/
			wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/audios/sonsportugues.tar.gz | tee -a $LOGFILE
			tar -zxvf sonsportugues.tar.gz | tee -a $LOGFILE
			rm -rf sonsportugues.tar.gz 
			
            #ADICIONADO ÁUDIOS DE ESPERA DE FILA
			wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/audios/audiosfilabr.tar.gz | tee -a $LOGFILE
			yes | tar -zxvf audiosfilabr.tar.gz | tee -a $LOGFILE
			rm -rf audiosfilabr.tar.gz 

			#ADICIONADO ÀUDIOS DE CALLCENTER
			wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/audios/agentpaused.wav
			wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/audios/notallowed.wav

			touch g4flex.txt
		
			echo "" | tee -a $LOGFILE 
			echo "+-------------------------------------------------------------------------+" | tee -a $LOGFILE
			echo "| Copiando os Audios gsm padrao G4 Flex para /var/lib/asterisk/sounds/en/ |" | tee -a $LOGFILE
			echo "+-------------------------------------------------------------------------+" | tee -a $LOGFILE
 			echo "" | tee -a $LOGFILE
 			
            cd /var/lib/asterisk/sounds/en/
			wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/audios/gsm.tar.gz | tee -a $LOGFILE
			tar zxvf gsm.tar.gz | tee -a $LOGFILE
			rm -rf gsm.tar.gz
			touch g4flex.txt
			chown root:root /var/lib/asterisk/sounds -R
			
			echo "" | tee -a $LOGFILE
			echo "Sons padroes da G4 enviados!" | tee -a $LOGFILE
			sleep 2
			
    fi;	

	if [ -d "/var/lib/asterisk/agi-bin" ]; then
		
		echo "" | tee -a $LOGFILE
		echo "Executaveis proprietarios (G4Flex) -----------------------------------------------------------" | tee -a $LOGFILE
		
		echo "" | tee -a $LOGFILE
		echo "+------------------------------------------------------+" | tee -a $LOGFILE
		echo "| Configurando os executaveis proprietarios .agi e .sh |" | tee -a $LOGFILE
		echo "+------------------------------------------------------+" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE
		sleep 2
		cd /var/lib/asterisk/agi-bin/
		wget -nc ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/executaveis_proprietarios/agigetip.agi | tee -a $LOGFILE
		wget -nc ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/executaveis_proprietarios/agigetsip.agi | tee -a $LOGFILE
		wget -nc ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/executaveis_proprietarios/portabilidade.sh | tee -a $LOGFILE
		chown root:root /var/lib/asterisk/agi-bin/ -R
		chmod +x /var/lib/asterisk/agi-bin/*
		
		echo "" | tee -a $LOGFILE
		echo "Configuracoes dos executaveis proprietarios finalizadas!" | tee -a $LOGFILE
		sleep 2
		
	else
		clear			
			echo "" | tee -a $LOGFILE
        	echo "+-----------------------------------------------------------------------------------------+" | tee -a $LOGFILE
        	echo "| A pasta /var/lib/asterisk/agi-bin nao existe, Asterisk nao foi compilado corretamente   |" | tee -a $LOGFILE
        	echo "| verificar o problema e executar o script novamente (executaveis proprietarios nao serao |" | tee -a $LOGFILE
		echo "| enviados)!                                                                     	        |" | tee -a $LOGFILE
        	echo "+-----------------------------------------------------------------------------------------+" | tee -a $LOGFILE
        	echo "" | tee -a $LOGFILE
        	sleep 6
			
        	exit
    fi;		  
     
	echo "" | tee -a $LOGFILE
	echo "G4Alert.sh(G4Flex) ---------------------------------------------------------------------------" | tee -a $LOGFILE
	echo "" | tee -a $LOGFILE
	
	if [ -e "/sbin/g4alert.sh" ]; then
		echo "Script g4alert.sh ja existe em /sbin"
	else
		#mv g4alert.sh /sbin/
		cd /sbin/
		wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/executaveis_proprietarios/g4alert.sh | tee -a $LOGFILE
		chmod 777 /sbin/g4alert.sh
		chown root:root /sbin/g4alert.sh
		chmod +x /sbin/g4alert.sh

		echo "Configuracao do G4Alert finalizada!" | tee -a $LOGFILE
		sleep 2
		
	fi;    
	echo "" | tee -a $LOGFILE
	echo "G4MakeDir.sh(G4Flex) -------------------------------------------------------------------------" | tee -a $LOGFILE
	echo "" | tee -a $LOGFILE
	

	if [ -e "/bin/checadisco.sh" ]; then
		echo "Script checadisco.sh ja existe em /bin"
	else

		cd /bin/
		wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/executaveis_proprietarios/checadisco.sh | tee -a $LOGFILE
		chown root:root /bin/checadisco.sh
		chmod +x /bin/checadisco.sh
		echo "00 */6 * * * /bin/sh /bin/checadisco.sh /bin/espaco.txt" >> /var/spool/cron/root

		echo "Configuracao do Checadisco finalizada!" | tee -a $LOGFILE
		sleep 2
		
	fi;	

	if [ -e "/etc/systemd/system/report.service" ]; then
		echo "Unit report ja existe em /etc/systemd/system/"
	else

		cd /etc/systemd/system/
		wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/aplicativos/report.service | tee -a $LOGFILE
		chown root:root /etc/systemd/system/report.service
		systemctl daemon-reload
		systemctl enable report

		echo "Configuracao da Unit report finalizada!" | tee -a $LOGFILE
		sleep 2
		
	fi;	

#	if [ -e "/etc/systemd/system/callback.service" ]; then
#		echo "Unit callback ja existe em /etc/systemd/system/"
#	else
#
#		cd /opt/java/jdk1.8.0/
#		mkdir callback
#		cd callback
#		wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/aplicativos/callback-version-3.jar | tee -a $LOGFILE
#		chown root:root /opt/java/jdk1.8.0/callback/callback-version-3.jar
		

#		cd /etc/systemd/system/
#		wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/aplicativos/callback.service | tee -a $LOGFILE
#		chown root:root /etc/systemd/system/callback.service
#		systemctl daemon-reload
#		systemctl enable callback
		

#		echo "Configuracao da Unit callback finalizada!" | tee -a $LOGFILE
#		sleep 2
#		
#	fi;	

	if [ -e "/opt/workspace/dialer" ]; then
		echo "Discados já existe"
	else

		cd /opt/workspace
		mkdir dialer
		cd dialer
		wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/aplicativos/dialer-version-4.tar.gz | tee -a $LOGFILE
		tar -zxvf dialer-version-4.tar.gz
		chown root:root dialer-*
		chmod +x dialer-*
		rm -rf dialer-version-4.tar.gz

		echo "Configuracao dos arquivos discador finalizada!" | tee -a $LOGFILE
		sleep 2
		
	fi;	

	echo "" | tee -a $LOGFILE
	echo "fail2ban_e_iptables.sh(G4Flex) ---------------------------------------------------------------" | tee -a $LOGFILE
	echo "" | tee -a $LOGFILE

	cd /etc/asterisk/
	rm -rf /etc/asterisk/extensions.ael
	rm -rf /etc/asterisk/extensions.lua
	rm -rf /etc/asterisk/extensions_minivm.conf	    
	echo "ODBC -----------------------------------------------------------------------------------------" | tee -a $LOGFILE
	
	echo "" | tee -a $LOGFILE
	echo "+------------------------------------------+" | tee -a $LOGFILE
	echo "| Configurando os arquivos POSTGRES e ODBC |" | tee -a $LOGFILE
	echo "+------------------------------------------+" | tee -a $LOGFILE
	sleep 2 

	if [ -e "/etc/odbc.ini.old" ]; then
		echo "Arquivo odbc.ini ja foi configurado para as conexoes da G4Flex!" | tee -a $LOGFILE
	else
		service postgresql-10 stop
		service postgresql-10 start
		
		echo "" | tee -a $LOGFILE
		echo "+----------------------------------+" | tee -a $LOGFILE
		echo "| Copiando o arquivo /etc/odbc.ini |" | tee -a $LOGFILE
		echo "+----------------------------------+" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE
		sleep 2
		cd /etc/
		mv odbc.ini odbc.ini.old
		wget --no-check-certificate ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/arquivos_de_configuracao/odbc.ini | tee -a $LOGFILE
		chown root:root /etc/odbc.ini
		
		echo "" | tee -a $LOGFILE
		echo "Configuracao do obdc.ini finalizada!" | tee -a $LOGFILE
		sleep 2
		
	fi;	
	echo "" | tee -a $LOGFILE
	echo "ODBCINST -------------------------------------------------------------------------------------" | tee -a $LOGFILE
	
	if [ -e "/etc/odbcinst.ini.old" ]; then
		echo "" | tee -a $LOGFILE
		echo "Arquivo odbcinst.ini ja foi configurado para as conexoes da G4Flex!" | tee -a $LOGFILE
	else
		echo "" | tee -a $LOGFILE
		echo "+--------------------------------------+" | tee -a $LOGFILE
		echo "| Editando o arquivo /etc/odbcinst.ini |" | tee -a $LOGFILE
		echo "+--------------------------------------+" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE
		sleep 2
		cd /usr/lib64/
		wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/centos7/postgresql-10/psqlodbcw.so
		chmod +x psqlodbcw.so
		echo "" | tee -a $LOGFILE
		echo "Configuracao do obdcinst finalizada!" | tee -a $LOGFILE
		sleep 2
	fi;
	
	echo "" | tee -a $LOGFILE
	echo "PSQLODBC ----------------------------------------------------------------------------------------------" | tee -a $LOGFILE
	echo "" | tee -a $LOGFILE

    service asterisk stop
	service asterisk start		
echo "" | tee -a $LOGFILE	
	echo "Edicao control-alt-delete -----------------------------------------------------------------------------" | tee -a $LOGFILE
	echo "" | tee -a $LOGFILE
	

	echo "" | tee -a $LOGFILE
	echo "+--------------------------------------------+" | tee -a $LOGFILE
	echo "| Mascarando o control-alt-delete no systemd |" | tee -a $LOGFILE
	echo "+--------------------------------------------+" | tee -a $LOGFILE
	echo "" | tee -a $LOGFILE
	sleep 2 
	systemctl mask ctrl-alt-del.target
	echo "Configuracao das tecladas control-alt-delete finalizada!" | tee -a $LOGFILE
	sleep 2
	
	echo "" | tee -a $LOGFILE
	echo "Edicao do Mutt ----------------------------------------------------------------------------------------" | tee -a $LOGFILE
	
	if [ "`cat /etc/Muttrc | grep -o hostname=g4flex.com.br`" = "hostname=g4flex.com.br" ]; then
		echo "" | tee -a $LOGFILE
		echo "Arquivo Muttrc ja esta configurado no padrao G4Flex" | tee -a $LOGFILE
	else
		# Editando o Mutt
		echo "" | tee -a $LOGFILE
		echo "+------------------------------------------------+" | tee -a $LOGFILE
		echo "| CONFIGURACAO DO MUTT PARA ENVIO DE EMAIL       |" | tee -a $LOGFILE
		echo "| Editando o arquivo /etc/Muttrc abaixo da linha |" | tee -a $LOGFILE
		echo "| set hostname=cs.hmc.edu                        |" | tee -a $LOGFILE
		echo "| e adicionando os seguintes parametros abaixo:  |" | tee -a $LOGFILE
		echo "| set from=suporte@g4flex.com.br                 |" | tee -a $LOGFILE
		echo "| set hostname=g4flex.com.br                     |" | tee -a $LOGFILE
		echo "| set realname=G4Flex                            |" | tee -a $LOGFILE
		echo "+------------------------------------------------+" | tee -a $LOGFILE
		echo "" | tee -a $LOGFILE
		sed -i s/"# set hostname=cs.hmc.edu"/"set from=\"suporte@g4flex.com.br\"\nset hostname=g4flex.com.br\nset realname=\"G4Flex\""/g /etc/Muttrc
			
		echo "Configuracao do Mutt finalizada!" | tee -a $LOGFILE
		sleep 2
	fi;		

	echo "Permissao aos grupos ----------------------------------------------------------------------------------" | tee -a $LOGFILE
	
	echo "" | tee -a $LOGFILE
	echo "+-------------------------------------------------------+" | tee -a $LOGFILE
	echo "| Adicionando permissoes ao grupos suporte/simplegroup  |" | tee -a $LOGFILE
	echo "+-------------------------------------------------------+" | tee -a $LOGFILE
	echo "" | tee -a $LOGFILE
	sleep 2
	
	chown -R root:suporte /etc/asterisk/
	chmod g+w -R /etc/asterisk
	chown -R root:suporte /var/lib/asterisk
	chmod g+w -R /var/lib/asterisk
	chown -R root:suporte /var/spool/asterisk
	chmod g+w -R /var/spool/asterisk
	chown -R root:suporte /var/run/asterisk
	chmod g+w -R /var/run/asterisk
	chown -R root:suporte /usr/lib64/asterisk
	chmod g+w -R /usr/lib64/asterisk	
	if [ -d "/etc/asterisk/contextos" ]; then
		
		echo "" | tee -a $LOGFILE
		echo "Configuracao de seguranca (control-alt-f9) -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------" | tee -a $LOGFILE
		
                echo "" | tee -a $LOGFILE
                echo "+---------------------------------------------------------+" | tee -a $LOGFILE
                echo "| Alterando o arquivo /usr/bin/safe_asterisk para impedir |" | tee -a $LOGFILE
                echo "| que acessem a CLI do Linux através do Ctrl + Alt + F9   |" | tee -a $LOGFILE
                echo "+---------------------------------------------------------+" | tee -a $LOGFILE
                echo "" | tee -a $LOGFILE
                sleep 3
                sed -i s#"TTY=9"#"TTY="#g /usr/sbin/safe_asterisk
                sed -i s#"CONSOLE=yes"#"CONSOLE=no"#g /usr/sbin/safe_asterisk
       else
                echo "Nao ha diretorio Asterisk criado!" | tee -a $LOGFILE
        fi

			echo "CONFIGURANDO CORES NO NANO PARA SHELL SCRIPTS" | tee -a
			sed -i s#"\# include \"/usr/share/nano/sh.nanorc\""#"include \"/usr/share/nano/sh.nanorc\""#g /etc/nanorc
			echo "NANO PARA SHELL CONFIGURADO"

			
			echo "" | tee -a $LOGFILE
                        echo "Configuracao de senha ao editar GRUB ------------------------------------------------------------------" | tee -a $LOGFILE

                        echo "" | tee -a $LOGFILE
                        echo "+----------------------------------------+" | tee -a $LOGFILE
                        echo "| Configuracao de senha ao editar o GRUB |" | tee -a $LOGFILE
                        echo "+----------------------------------------+" | tee -a $LOGFILE
                        echo "" | tee -a $LOGFILE
                        sleep 2

                        cd /usr/src/
                        wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/centos7/grub-conf/pw_grb1 | tee -a $LOGFILE
                        chmod u+x pw_grb1
			sh pw_grb1 | tee -a $LOGFILE

                        echo "Configuracao para impedir que a edição do GRUB (sem saber a senha) seja feita!" | tee -a $LOGFILE
                        echo "" | tee -a $LOGFILE			

echo "" | tee -a $LOGFILE
        echo "" | tee -a $LOGFILE
	echo "" | tee -a $LOGFILE
	echo "Instalacao do Fail2ban --------------------------------------------------------------------------------" | tee -a $LOGFILE
    
	echo "" | tee -a $LOGFILE
	echo "+---------------------+" | tee -a $LOGFILE
	echo "| Instalando Fail2ban |" | tee -a $LOGFILE
	echo "+---------------------+" | tee -a $LOGFILE
	echo "" | tee -a $LOGFILE
	sleep 2
	

	#yum -y install epel-release
    #yum -y install fail2ban fail2ban-systemd
    #systemctl enable fail2ban
    #systemctl start fail2ban

	mkdir -p /usr/src/fail2ban_install/
	cd /usr/src/fail2ban_install/
	wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/arquivos_de_configuracao/fail2ban-0.8.4.zip | tee -a $LOGFILE
	unzip fail2ban-0.8.4.zip
	cd fail2ban-0.8.4/
	python setup.py install
	cd ..
	mkdir fail2ban_conf
	cd fail2ban_conf/
	wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/centos7/iptables/fail2ban/fail2ban_conf.tar.gz | tee -a $LOGFILE
	tar xfvz fail2ban_conf.tar.gz
	yes | cp -r *.conf /etc/fail2ban/
	yes | cp -r action.d/* /etc/fail2ban/action.d/
	yes | cp -r filter.d/* /etc/fail2ban/filter.d/
	cd /usr/src/fail2ban_install/fail2ban-0.8.4/files/
	yes | cp -r redhat-initd /etc/init.d/fail2ban
	cd /etc/init.d/
	chmod +x fail2ban
	systemctl enable fail2ban
	systemctl start fail2ban
	sleep 2
		
	echo "Configuracao do Fail2ban finalizada!" | tee -a $LOGFILE
	echo "" | tee -a $LOGFILE
        
        echo "Configuracao do Iptables ------------------------------------------------------------------------------" | tee -a $LOGFILE

        echo "" | tee -a $LOGFILE
        echo "+-----------------------+" | tee -a $LOGFILE
        echo "| Configurando Iptables |" | tee -a $LOGFILE
        echo "+-----------------------+" | tee -a $LOGFILE
        echo "" | tee -a $LOGFILE
        sleep 2

        cd /usr/src/
        wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/centos7/iptables/iptables | tee -a $LOGFILE
        cat iptables  > /etc/sysconfig/iptables 
        iptables-restore < /etc/sysconfig/iptables
        /sbin/service iptables save
  echo "Configuracao do Iptables finalizada!" | tee -a $LOGFILE

  echo "" | tee -a $LOGFILE
  echo "Configuracao do ntsysv --------------------------------------------------------------------------------" | tee -a $LOGFILE
  
  echo "" | tee -a $LOGFILE
  echo "+------------------------------------------------+" | tee -a $LOGFILE
  echo "| Configurando a inicializacao do sistema com o  |" | tee -a $LOGFILE
  echo "| chkconfig <name> <on|off> o mesmo que o ntsysv |" | tee -a $LOGFILE
  echo "+------------------------------------------------+" | tee -a $LOGFILE
  echo "" | tee -a $LOGFILE
  systemctl enable auditd 
  systemctl disable blk-availability 
  systemctl enable crond
  systemctl disable fail2ban
  systemctl enable iptables
  systemctl disable ip6tables
  systemctl disable iscsi
  systemctl disable iscsid
  systemctl enable kdump
  systemctl disable lvm2-monitor
  systemctl disable mdmonitor
  systemctl disable messagebus
  systemctl disable netfs
  systemctl enable network
  systemctl enable nfs
  systemctl enable nfslock
  systemctl enable ntpd
  systemctl enable portreserve
  systemctl enable postfix
  systemctl enable postgresql-10
  systemctl disable rdma
  systemctl enable rpcbind
  systemctl disable rpcgssd
  systemctl enable rsyslog
  systemctl enable snmpd
  systemctl enable sshd
  systemctl disable udev-post
  
  echo "" | tee -a $LOGFILE
  echo "Configuracao do Ntsysv finalizada!" | tee -a $LOGFILE
  echo "" | tee -a $LOGFILE
  sleep 2        	

  rm -f /etc/localtime
  ln -s /usr/share/zoneinfo/America/Fortaleza /etc/localtime
  echo ""
  echo "Configuracao do fuso horário do servidor finalizada!" | tee -a $LOGFILE
  echo "" | tee -a $LOGFILE

yes | cp /usr/pgsql-10/bin/* /bin/

echo "-------------------------------INSTALAÇÃO DO ASTERISK FINALIZADA------------------------------" | tee -a $LOGFILE
echo "" | tee -a $LOGFILE
