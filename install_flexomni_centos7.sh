#!/bin/bash

read -p "Qual o usuário do GIT? " USUARIO_GIT
read -s -p "Qual a senha do GIT? " SENHA_GIT
echo " "
read -p "Qual a porta HTTPS? " PORTA_ACESSO_HTTPS
read -p "Qual o DNS para o CHAT? " DNS_CHAT
PORTA_ACESSO_HTTP=80

#INICIO DA INSTALACAO DO FLEXUC OMNICHANNEL

mkdir /opt/workspace;cd /opt/workspace

#CRIANDO ARQUIVO DE LOG FLEXUC
if [ -e /var/log/log_script_flexomni ]
then
	rm -rf /opt/workspace/log_script_flexomni.log
	LOGFILE2=/opt/workspace/log_script_flexomni.log
        touch $LOGFILE2
else 
	LOGFILE=/opt/workspace/log_script_flexomni.log
	touch $LOGFILE2
fi;

#GERANDO UM CABEÇALHO PARA O ARQUIVO DE LOG
echo "Log de instalacao do FlexUC Omnichannel" | tee -a $LOGFILE2
echo "Data de criacao: $TIME" | tee -a $LOGFILE2
echo "Endereco do log: $LOGFILE2" | tee -a $LOGFILE2
echo "Quaisquer dúvidas/sugestões, falar com Rodrigo Mesquita, Hiago Araujo ou Cristiano Sobrinho" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

echo "-------------------------------INSTALAÇÃO DO FLEX OMNI INICIADA-------------------------------" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

echo "" | tee -a $LOGFILE2
echo "+-----------------------------------------------------------------------------+" | tee -a $LOGFILE2
echo "| Configurando o diretório, adicionando repositorio epel e instalando mlocate |" | tee -a $LOGFILE2
echo "+-----------------------------------------------------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

if [ -e "/etc/yum.repos.d/epel.repo" ]; 
then
    echo "Repositorio Epel ja esta adicionado" | tee $LOGFILE2
    echo "" | tee -a $LOGFILE2
else
    echo "" | tee -a $LOGFILE2
    yum install epel-release -y;yum update-y ;yum install mlocate-y;yum updatedb
    echo "Repositorio Epel adicionado" | tee $LOGFILE2
fi;

echo "" | tee -a $LOGFILE2
echo "+--------------------------------+" | tee -a $LOGFILE2
echo "| Instalando o FFMPEG para o PDF |" | tee -a $LOGFILE2
echo "+--------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

yum localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm -y;yum install ffmpeg ffmpeg-devel -y

echo "O FFMPEG foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+-----------------------------------+" | tee -a $LOGFILE2
echo "| Criando o banco fleuc no Postgres |" | tee -a $LOGFILE2
echo "+-----------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

psql postgres postgres -c"CREATE USER flexuc WITH PASSWORD 'postgres'"
psql postgres postgres -c"ALTER USER flexuc WITH SUPERUSER"
psql postgres postgres -c"ALTER USER flexuc CREATEDB"
psql postgres postgres -c"CREATE DATABASE flexuc"
psql postgres postgres -c"GRANT ALL PRIVILEGES ON DATABASE flexuc TO flexuc"
psql postgres postgres -c"GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO flexuc"
psql postgres postgres -c"GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO flexuc"
psql postgres postgres -c"GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO flexuc"
psql postgres postgres -c"GRANT USAGE ON SCHEMA public TO flexuc"
psql postgres postgres -c"GRANT CONNECT ON DATABASE flexuc TO flexuc"

echo "O banco flexuc foi configurado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+-----------------------+" | tee -a $LOGFILE2
echo "| Instalando o RabbitMQ |" | tee -a $LOGFILE2
echo "+-----------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

touch /etc/yum.repos.d/rabbitmq.repo

echo "##
## Zero dependency Erlang
##

[rabbitmq_erlang]
name=rabbitmq_erlang
baseurl=https://packagecloud.io/rabbitmq/erlang/el/7/\$basearch
repo_gpgcheck=1
gpgcheck=1
enabled=1
# PackageCloud's repository key and RabbitMQ package signing key
gpgkey=https://packagecloud.io/rabbitmq/erlang/gpgkey
       https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[rabbitmq_erlang-source]
name=rabbitmq_erlang-source
baseurl=https://packagecloud.io/rabbitmq/erlang/el/7/SRPMS
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/rabbitmq/erlang/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

##
## RabbitMQ server
##

[rabbitmq_server]
name=rabbitmq_server
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/7/\$basearch
repo_gpgcheck=1
gpgcheck=1
enabled=1
# PackageCloud's repository key and RabbitMQ package signing key
gpgkey=https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
       https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[rabbitmq_server-source]
name=rabbitmq_server-source
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/7/SRPMS
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300" > /etc/yum.repos.d/rabbitmq.repo

yum update -y;yum install socat logrotate -y;yum install erlang rabbitmq-server -y;systemctl start rabbitmq-server;systemctl enable rabbitmq-server

echo "O RabbitMQ foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+------------------------------+" | tee -a $LOGFILE2
echo "| Instalando o Nginx e o Redis |" | tee -a $LOGFILE2
echo "+------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

yum install nginx redis -y;systemctl start redis;systemctl start nginx;systemctl enable redis;systemctl enable nginx
cp nginx.conf /etc/nginx/

echo "# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

   # server {
     #   listen       80;
     #   server_name  localhosthttp;

    #    return 301 https://\$host\$request_uri;
   # }

    server {
        listen       8082;
        server_name  localhosthttps;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        #ssl_certificate      certificados-ssl/flexchannel.crt;
        #ssl_certificate_key  certificados-ssl/flexchannel.key;

        location / {
          root html;
          index index.html index.htm;
          try_files \$uri /index.html;
        }

        #error_page  404              /404.html;
        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

    server {
        listen       81 ssl;
        server_name  chat;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        ssl_certificate      certificados-ssl/flexchannel.crt;
        ssl_certificate_key  certificados-ssl/flexchannel.key;

        location / {
          root chat;
          index index.html index.htm;
          try_files \$uri /index.html;
        }

        #error_page  404              /404.html;
        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }




# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2 default_server;
#        listen       [::]:443 ssl http2 default_server;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers HIGH:!aNULL:!MD5;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        location / {
#        }
#
#        error_page 404 /404.html;
#        location = /404.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#        location = /50x.html {
#        }
#    }

}" > /etc/nginx/nginx.conf

mkdir /etc/nginx/certificados-ssl

echo "O Nginx e o Redis foram instalados" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+----------------------+" | tee -a $LOGFILE2
echo "| Instalando o JAVA 11 |" | tee -a $LOGFILE2
echo "+----------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

yum install java-11-openjdk-devel -y

echo "O JAVA 11 foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+----------------------------+" | tee -a $LOGFILE2
echo "| Instalando NVM, NODE e PM2 |" | tee -a $LOGFILE2
echo "+----------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

curl https://raw.githubusercontent.com/creationix/nvm/v0.39.1/install.sh | bash;source ~/.bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
echo ""
nvm install v12.22.10
export NODE_OPTIONS="--max-old-space-size=8000"
npm config set unsafe-perm true
npm install pm2@latest -g -y;pm2 startup

echo "O NVM, NODE e PM2 foram instalados" | tee -a $LOGFILE2
echo ""

echo "------------------------------INICIO DA INSTALACAO DO FLEX-----------------------------------" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

/usr/pgsql-11/bin/pg_dump -C -U postgres -f /opt/workspace/dump_$(date +%d%m%y_%H%M).sql flexuc

echo "" | tee -a $LOGFILE2
echo "+------------------+" | tee -a $LOGFILE2
echo "| Instalando o Git |" | tee -a $LOGFILE2
echo "+------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

yum install git;git config --global user.name "Root";git config --global user.email "root@g4flex.com.br"
git config --global http.sslbackend schannel
git config --global http.sslVerify false

echo "O Git foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+----------------------------------+" | tee -a $LOGFILE2
echo "| Instalando e configurando o Kong |" | tee -a $LOGFILE2
echo "+----------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/kong-flexuc-4.git
cd /opt/workspace/kong-flexuc-4
yum install kong-2.3.3.el7.amd64.rpm --nogpgcheck -y
systemctl start postgresql-11
psql postgres postgres -c"CREATE DATABASE kong"
psql postgres postgres -c"GRANT ALL PRIVILEGES ON DATABASE kong TO flexuc"
psql postgres postgres -c"GRANT CONNECT ON DATABASE kong TO flexuc"
psql -U flexuc kong < kong.sql
yes|cp kong.conf /etc/kong/
sed -i 's/proxy_listen = 0.0.0.0:80 reuseport backlog=16384, 0.0.0.0:9090 ssl reuseport backlog=16384/proxy_listen = 0.0.0.0:'$PORTA_ACESSO_HTTP' reuseport backlog=16384, 0.0.0.0:'$PORTA_ACESSO_HTTPS' ssl reuseport backlog=16384/g' /etc/kong/kong.conf
systemctl start kong;systemctl enable kong
kong migrations bootstrap -c /etc/kong/kong.conf
curl -sL https://github.com/kong/deck/releases/download/v1.8.1/deck_1.8.1_linux_amd64.tar.gz -o deck.tar.gz;tar -xf deck.tar.gz -C /tmp;cp /tmp/deck /usr/local/bin/
deck sync
deck diff
cp -r certificados-ssl/ /etc/nginx/
systemctl restart nginx

echo "Kong instalado e configurado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+----------------------------------+" | tee -a $LOGFILE2
echo "|       Arquivos do discador       |" | tee -a $LOGFILE2
echo "+----------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace
mkdir dialer
cd dialer
wget ftp://$FTP_USER:$FTP_PASS@homologacao.g4flex.com.br/configuracao_servidores_voz/aplicativos/dialer-version-4.tar.gz | tee -a $LOGFILE2
tar -zxvf dialer-version-4.tar.gz
chown root:root dialer-*
chmod +x dialer-*
rm -rf dialer-version-4.tar.gz

echo "Configuracao dos arquivos discador finalizada!" | tee -a $LOGFILE
echo ""

echo "" | tee -a $LOGFILE2
echo "+-----------------------------------+" | tee -a $LOGFILE2
echo "| Instalando flex-portal-migrations |" | tee -a $LOGFILE2
echo "+-----------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flex-portal-migrations.git
cd /opt/workspace/flex-portal-migrations
npm i
npx sequelize-cli db:migrate
npx sequelize-cli db:seed:all

echo "O flex-portal-migrations foi instalado e as seeds foram rodadas" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+-----------------------------+" | tee -a $LOGFILE2
echo "| Instalando api-chat-interno |" | tee -a $LOGFILE2
echo "+-----------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/api-chat-interno.git
cd /opt/workspace/api-chat-interno
npm i
npm run build
pm2 start ecosystem.config.js

echo "A api-chat-interno foi instalada" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+---------------------------+" | tee -a $LOGFILE2
echo "| Instalando flexia-fastapi |" | tee -a $LOGFILE2
echo "+---------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
yum install -y bzip2-devel libffi-devel gcc openssl-devel
cd /usr/src
wget https://www.python.org/ftp/python/3.9.7/Python-3.9.7.tar.xz;tar -xvf Python-3.9.7.tar.xz

cd Python-3.9.7
./configure --prefix=/opt/python3
make altinstall
ln -s /opt/python3/bin/python3.9 /usr/bin/python3.9
python3.9 --version

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flexia-fastapi.git

cd flexia-fastapi/
python3.9 -m venv venv
. venv/bin/activate
pip3 install -r requirements.txt
pm2 start ecosystem.config.js
deactivate

echo "O flexia-fastapi foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+-------------------------+" | tee -a $LOGFILE2
echo "| Instalando chat-stacker |" | tee -a $LOGFILE2 # Serviço de conexão da GupShup com o rabbitmq
echo "+-------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/chat-stacker.git
cd /opt/workspace/chat-stacker
npm i
npm run build
pm2 start ecosystem.config.js

echo "O chat-stacker foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+----------------------------+" | tee -a $LOGFILE2
echo "| Instalando chat-adm-events |" | tee -a $LOGFILE2 # Serviço de segurança do front-end
echo "+----------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/chat-adm-events.git
cd /opt/workspace/chat-adm-events
npm i
npm run build
pm2 start ecosystem.config.js

echo "O chat-adm-events foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+-----------------------------------+" | tee -a $LOGFILE2
echo "| Instalando download-audio-service |" | tee -a $LOGFILE2 # Serviço de Douwnload de audios
echo "+-----------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/download-audio-service.git
cd /opt/workspace/download-audio-service
npm i
npm run build
pm2 start ecosystem.config.js

echo "O download-audio-service foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+----------------------------------+" | tee -a $LOGFILE2
echo "| Instalando asterisk-agent-server |" | tee -a $LOGFILE2
echo "+----------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flex-asterisk-agent-service.git
cd /opt/workspace/flex-asterisk-agent-service
npm i
npm run build
pm2 start ecosystem.config.js

echo "O flex-asterisk-agent-service foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+-------------------------------+" | tee -a $LOGFILE2
echo "| Instalando flex-configuration |" | tee -a $LOGFILE2
echo "+-------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flex-configuration.git
cd /opt/workspace/flex-configuration
npm i
pm2 start ecosystem.config.js

echo "O flex-configuration foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+-------------------------+" | tee -a $LOGFILE2
echo "| Instalando flex-exports |" | tee -a $LOGFILE2
echo "+-------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flex-exports.git
cd /opt/workspace/flex-exports
npm i
npm run build
pm2 start ecosystem.config.js

echo "O flex-exports foi instalado" | tee -a $LOGFILE2

echo ""
echo ""
echo "+---------------------------------+" | tee -a $LOGFILE2
echo "| Instalando flex-portal-backend  |" | tee -a $LOGFILE2 
echo "+---------------------------------+" | tee -a $LOGFILE2
echo ""

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flex-portal-backend.git
cd /opt/workspace/flex-portal-backend
npm i
npm run build
pm2 start ecosystem.config.js

echo "O flex-portal-backend foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+------------------------+" | tee -a $LOGFILE2
echo "| Instalando flex-ami-ts |" | tee -a $LOGFILE2 
echo "+------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flex-ami-ts.git
cd /opt/workspace/flex-ami-ts
mv .env.example .env
npm i
npm run build
pm2 start ecosystem.config.js

echo "O flex-ami-ts foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+------------------------------+" | tee -a $LOGFILE2
echo "| Instalando flex-portal-proxy |" | tee -a $LOGFILE2 
echo "+------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flex-portal-proxy.git
cd /opt/workspace/flex-portal-proxy
npm i
npm run build
pm2 start ecosystem.config.js

echo "O flex-portal-proxy foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+----------------------+" | tee -a $LOGFILE2
echo "| Instalando flex-desk |" | tee -a $LOGFILE2 
echo "+----------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flex-desk.git
cd /opt/workspace/flex-desk
npm i
npm run build
pm2 start ecosystem.config.js

echo "O flex-desk foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+---------------------+" | tee -a $LOGFILE2
echo "| Instalando flex-nps |" | tee -a $LOGFILE2
echo "+---------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flex-nps.git
cd /opt/workspace/flex-nps
npm i
pm2 start ecosystem.config.js

echo "O flex-nps foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+-----------------------------+" | tee -a $LOGFILE2
echo "| Instalando flex-portal-chat |" | tee -a $LOGFILE2
echo "+-----------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flex-portal-chat.git
cd /opt/workspace/flex-portal-chat
sed -i 's/"port_frontend": "443",/"port_frontend": "'$PORTA_ACESSO_HTTPS'",/g' /opt/workspace/flex-portal-chat/config/production.json
sed -i 's/"route_proxy_midia": ":443\/channel\/open",/ "route_proxy_midia": ":'$PORTA_ACESSO_HTTPS'\/channel\/open",/g' /opt/workspace/flex-portal-chat/config/production.json
sed -i 's/"dns": "https:\/\/flexucteste.g4flex.com.br",/"dns": "https:\/\/'$DNS_CHAT'",/g' /opt/workspace/flex-portal-chat/config/production.json
npm i
pm2 start ecosystem.config.js

echo "O flex-portal-chat foi instalado" | tee -a $LOGFILE2
echo 

echo "" | tee -a $LOGFILE2
echo "+--------------------------------+" | tee -a $LOGFILE2
echo "| Instalando controle-de-escalas |" | tee -a $LOGFILE2
echo "+--------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/

git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/controle-de-escalas.git
cd /opt/workspace/controle-de-escalas
npm install --global yarn
yarn install --prod
yarn build
pm2 start ecosystem.config.js
pm2 save

echo "O controle-de-escalas foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+-------------------------------+" | tee -a $LOGFILE2
echo "| Instalando flex-notifications |" | tee -a $LOGFILE2
echo "+-------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/

git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flex-notifications.git
cd /opt/workspace/flex-notifications
npm install --global yarn
yarn install --prod
yarn build
pm2 start ecosystem.config.js

echo "O flex-notifications foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+----------------+" | tee -a $LOGFILE2
echo "| Instalando CRM |" | tee -a $LOGFILE2
echo "+----------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/

git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/crm-service.git
cd /opt/workspace/crm-service
npm install --global yarn
yarn install --prod
yarn build
pm2 start ecosystem.config.js
cd /opt/workspace/flex-desk/
node scrips/migrate-custom-fields-crm.js
node scrips/fix-db-structure-crm.js
cd /opt/workspace/crm-service

echo "O CRM foi instalado" | tee -a $LOGFILE2
echo ""


echo "" | tee -a $LOGFILE2
echo "+--------------------------+" | tee -a $LOGFILE2
echo "| Instalando flex-report-2 |" | tee -a $LOGFILE2
echo "+--------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flex-report-2.git
cd /opt/workspace/flex-report-2/
./mvnw clean && ./mvnw package -DskipTests
systemctl start report

echo "O flex-report-2 foi instalado" | tee -a $LOGFILE2
echo ""

echo "" | tee -a $LOGFILE2
echo "+--------------------------------+" | tee -a $LOGFILE2
echo "| Instalando flex-case-front-end |" | tee -a $LOGFILE2
echo "+--------------------------------+" | tee -a $LOGFILE2
echo "" | tee -a $LOGFILE2

cd /opt/workspace/
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/flex-case-front-end.git
cd /opt/workspace/flex-case-front-end
git clone https://$USUARIO_GIT:$SENHA_GIT@git.g4flex.com.br:8081/desenvolvimento/front-end-build.git
#npm i
#npm run build
rm -rf /usr/share/nginx/html/*
mkdir /usr/share/nginx/html/flexuc
cp -r /opt/workspace/flex-case-front-end/front-end-build/* /usr/share/nginx/html/
cp -r /opt/workspace/flex-case-front-end/front-end-build/* /usr/share/nginx/html/flexuc/

echo "O flex-case-front-end foi instalado" | tee -a $LOGFILE2
echo ""

systemctl restart nginx
systemctl restart kong
cd /opt/workspace/kong-flexuc-4
deck sync

echo "------------------------------INSTALAÇÃO DO FLEX OMNI FINALIZADA------------------------------" | tee -a $LOGFILE2

rm -rf install_flexomni_centos7.sh
