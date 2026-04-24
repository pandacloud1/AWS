## INSTALLING APACHE IN UBUNTU 22.04
REF: [https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-ubuntu-22-04]

```sh
sudo apt update
sudo apt install apache2 -y
sudo systemctl status apache2
echo "THIS IS MY FIRST SERVER" > /var/www/html/index.html
```


## INSTALLING APACHE IN AMAZON LINUX 2
REF: [https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Tutorials.WebServerDB.CreateWebServer.html]

```sh
#!/bin/bash
sudo su -
yum update -y
yum install httpd -y
service httpd start
chkconfig httpd on
echo "THIS IS MY FIRST SERVER" > /var/www/html/index.html
```
