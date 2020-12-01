#!/bin/bash
yum -y update 
yum -y install  httpd
myip = `curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
cat <<EOF > /var/www/html/index.html
<html>
<h1>Lesson-8</h1>
<h2> Build by Power of Terraform <font color="red">v0.13.5</font></h2><br>
Owner ${f_name} ${l_name} <br>
%{for x in names ~}
Hello to ${x} from ${f_name}<br>
%{endfor ~}
</html>
EOF
echo "<h2>IP: $myip</h2>" >> /var/www/html/index.html
sudo systemctl start httpd
systemctl enable httpd