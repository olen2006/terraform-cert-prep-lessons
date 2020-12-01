#!/bin/bash
yum -y update 
yum -y install  httpd
myip = $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)  #Doesn't work ???
echo "<h2>Webserver with IP: $myip</h2><br>Build by Terraform" > /var/www/html/index.html
EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
echo "<h2>$(hostname -f) in AZ $EC2_AVAIL_ZONE </h2>" >> /var/www/html/index.html
systemctl start httpd
systemctl enable httpd