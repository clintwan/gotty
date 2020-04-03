mkdir -p /etc/docimp
cp -R deploy /etc/docimp
go build -o /etc/docimp/docimp .
ln -sf /etc/docimp/deploy/service /etc/systemd/system/docimp.service
systemctl restart docimp
