## INSTALLING APACHE IN UBUNTU 22.04
REF: [https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-22-04]

```sh
#!/bin/bash
sleep 30
sudo apt update
sudo apt install git nginx -y
sudo systemctl enable nginx
git clone https://github.com/pandacloud1/webapp1.git && cd webapp1
cp * -R /var/www/html/
```

## INSTALLING APACHE IN AMAZON LINUX 2
REF: [https://stackoverflow.com/questions/57784287/how-to-install-nginx-on-aws-ec2-linux-2]

```sh
#!/bin/bash
sleep 30

sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
sudo yum install git -y
git clone https://github.com/pandacloud1/webapp1.git && cd webapp1
cp * -R /usr/share/nginx/html/
sudo systemctl restart nginx
```
