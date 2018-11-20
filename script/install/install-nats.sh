#/bin/bash

apt-get install -y zip
mkdir /tmp/nats
cd /tmp/nats

wget https://github.com/nats-io/gnatsd/releases/download/v$1/gnatsd-v$1-linux-amd64.zip
unzip gnatsd-v$1-linux-amd64.zip
mkdir -p /usr/local/nats/bin
cp gnatsd-v$1-linux-amd64/* /usr/local/nats/bin/
rm -Rf /tmp/nats


cat > /usr/local/nats/gnatsd.config <<END
port: 4222
http_port: 8222

cluster {
    port: 6222
}
END

adduser --system --group --no-create-home --shell /bin/false nats
chown -R nats:nats /usr/local/nats

cat > /etc/systemd/system/nats.service <<end
[Unit]
Description=NATS messaging server

[Service]
ExecStart=/usr/local/nats/bin/gnatsd -c /usr/local/nats/gnatsd.config
User=nats
Restart=on-failure

[Install]
WantedBy=multi-user.target
end

systemctl enable nats
systemctl start nats
