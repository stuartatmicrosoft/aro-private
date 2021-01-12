#!/bin/bash

#AZ_USER_NAME=${1}
#AZ_USER_PASSWORD=${2}
#AZ_TENANT_ID=${3}
#AZ_SUBSCRIPTION_ID=${4}
#SP_NAME=${5}
#SP_SECRET=${6}
#SP_OBJECT_ID=${7}
#SP_APP_ID=${8}

echo "`date` --BEGIN-- Provision Stage 1 Script" >>/root/provision-script-output.log
echo "********************************************************************************************"
	echo "`date` -- Setting Time Zone" >>/root/provision-script-output.log
	echo "`date`" >>/root/provision-script-output.log
	timedatectl set-timezone America/Detroit >>/root/provision-script-output.log
	echo "`date`" >>/root/provision-script-output.log
echo "********************************************************************************************"
	echo "`date` -- Setting Student User password to 'Microsoft'" >>/root/provision-script-output.log
	echo "Microsoft" | passwd --stdin aroadmin
echo "********************************************************************************************"
	echo "`date` -- Adding aroadmin to wheel group for sudo access'" >>/root/provision-script-output.log
	usermod -G wheel aroadmin >>/root/provision-script-output.log
echo "********************************************************************************************"
	echo "`date` -- Setting Root Password to 'Microsoft'" >>/root/provision-script-output.log
	echo "Microsoft" | passwd --stdin root
echo "********************************************************************************************"
	echo "`date` -- Adding 'deltarpm' and other required RPMs" >>/root/provision-script-output.log
        sed -i "s/=enforcing/=disabled/g" /etc/selinux/config >>/root/provision-script-output.log
        setenforce 0 >>/root/provision-script-output.log
        echo "plugins=0" >> /etc/dnf/dnf.conf 
        sed -i "s/remove=True/remove=False/g" /etc/dnf/dnf.conf
        echo "DRPM INSTALL" >> /root/dnf-output.log
        dnf -y install drpm >> /root/dnf-output.log
#        echo "PYTHON27 INSTALL" >> /root/dnf-output.log
#        dnf -y install @python27 >> /root/dnf-output.log
#        echo "DEVELOPMENT INSTALL" >> /root/dnf-output.log
#        dnf -y install @development >> /root/dnf-output.log
        echo "REQUIRED RPM INSTALL" >> /root/dnf-output.log
        dnf -y install python2-devel python2-pip libxslt-devel libffi-devel openssl-devel iptables arptables ebtables iptables-services telnet nodejs npm tigervnc-server tigervnc >> /root/dnf-output.log
        echo "SERVER W GUI INSTALL" >> /root/dnf-output.log
        dnf -y groupinstall "Server with GUI" >> /root/dnf-output.log
        echo "REMOVE" >> /root/dnf-output.log
        dnf -y remove rhn-check rhn-client-tools rhn-setup rhnlib rhnsd dnf-rhn-plugin subscription-manager >> /root/dnf-output.log
#        echo "FULL UPDATE" >> /root/dnf-output.log
#        dnf -y update >> /root/dnf-output.log
        echo "aroadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        alternatives --set python /usr/bin/python2
#        cd /usr/bin
#        curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
#        chmod 755 /usr/bin/kubectl
echo "********************************************************************************************"
	echo "`date` -- Securing host and changing default SSH port to 2112" >>/root/provision-script-output.log
	sed -i "s/dport 22/dport 2112/g" /etc/sysconfig/iptables
	semanage port -a -t ssh_port_t -p tcp 2112 >>/root/provision-script-output.log
	sed -i "s/#Port 22/Port 2112/g" /etc/ssh/sshd_config
	systemctl restart sshd >>/root/provision-script-output.log
	systemctl stop firewalld >>/root/provision-script-output.log
	systemctl disable firewalld >>/root/provision-script-output.log
	systemctl mask firewalld >>/root/provision-script-output.log
	systemctl enable iptables >>/root/provision-script-output.log
	systemctl start iptables >>/root/provision-script-output.log
echo "********************************************************************************************"
#        echo "`date` -- Upgrading PIP and installing Ansible" >>/root/provision-script-output.log
#        runuser -l aroadmin -c "pip-2.7 install --upgrade --user python-dateutil"
#        runuser -l aroadmin -c "pip-2.7 install --upgrade --user openshift"
#        runuser -l aroadmin -c "pip-2.7 install --upgrade --user requests"
#        runuser -l aroadmin -c "pip-2.7 install --upgrade --user xmltodict"
#        runuser -l aroadmin -c "pip-2.7 install --upgrade --user pyOpenSSL"
#        runuser -l aroadmin -c "pip-2.7 install --upgrade --user podman"
#        runuser -l aroadmin -c "pip-2.7 install --user ansible==2.9.10"
#        pip-2.7 install --upgrade selinux
#        find /usr/lib/python2.7/site-packages -type f -exec chmod 644 {} +
#        find /usr/lib/python2.7/site-packages -type d -exec chmod 755 {} +
#        echo "[defaults]" > /home/aroadmin/.ansible.cfg
#        echo "no_log = True" >> /home/aroadmin/.ansible.cfg
#        echo "[ssh_connection]" >> /home/aroadmin/.ansible.cfg
#        echo "ssh_args = -o StrictHostKeyChecking=no" >> /home/aroadmin/.ansible.cfg
#        chown aroadmin:aroadmin /home/aroadmin/.ansible.cfg
echo "********************************************************************************************"	
	echo "`date` -- Installing the Azure Linux CLI" >>/root/provision-script-output.log
	rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
	dnf -y install azure-cli >> /root/dnf-output.log
echo "********************************************************************************************"	
	echo "`date` -- Setting default systemd target to graphical.target" >>/root/provision-script-output.log
	systemctl set-default graphical.target >> /root/provision-script-output.log
echo "********************************************************************************************"
	echo "`date` -- Installing noVNC environment" >>/root/provision-script-output.log
        pip-2.7 install numpy websockify >>/root/provision-script-output.log
        chmod -R a+rx /usr/lib64/python2.7/site-packages/numpy*
        chmod -R a+rx /usr/lib/python2.7/site-packages/websockify*
        wget --quiet -P /usr/local https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz
        cd /usr/local
        tar xvfz v1.1.0.tar.gz
        ln -s /usr/local/noVNC-1.1.0/vnc.html /usr/local/noVNC-1.1.0/index.html
        wget --quiet -P /etc/systemd/system https://raw.githubusercontent.com/stuartatmicrosoft/aro-private/master/provision-scripts/websockify.service
	wget --quiet --no-check-certificate -P /etc/systemd/system "https://raw.githubusercontent.com/stuartatmicrosoft/aro-private/master/provision-scripts/vncserver@:4.service"
	openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/pki/tls/certs/novnc.pem -out /etc/pki/tls/certs/novnc.pem -days 365 -subj "/C=US/ST=Michigan/L=Ann Arbor/O=AROPrivate/OU=CloudNativeAzure/CN=microsoft.com"
	su -c "mkdir .vnc" - aroadmin
	wget --quiet --no-check-certificate -P /home/aroadmin/.vnc https://raw.githubusercontent.com/stuartatmicrosoft/aro-private/master/provision-scripts/passwd
	wget --quiet --no-check-certificate -P /home/aroadmin/.vnc https://raw.githubusercontent.com/stuartatmicrosoft/aro-private/master/provision-scripts/xstartup
        chown aroadmin:aroadmin /home/aroadmin/.vnc/passwd
        chown aroadmin:aroadmin /home/aroadmin/.vnc/xstartup
        chmod 600 /home/aroadmin/.vnc/passwd
        chmod 755 /home/aroadmin/.vnc/xstartup
	iptables -I INPUT 1 -m tcp -p tcp --dport 6080 -j ACCEPT
	service iptables save
#        chmod 644 /etc/systemd/system/pm2-root.service
        chmod 644 /etc/systemd/system/vncserver@\:4.service
        chmod 644 /etc/systemd/system/websockify.service
        systemctl daemon-reload
#        systemctl enable vncserver@:4.service
#        systemctl enable websockify.service
#        systemctl start vncserver@:4.service
#	systemctl start websockify.service
echo "********************************************************************************************"
#	echo "`date` -- Editing aroadmin's .bashrc and disabling Red Hat alerts" >> /root/provision-script-output.log
#	echo " " >> /home/aroadmin/.bashrc
#        echo "# Azure Service Principal Credentials" >> /home/aroadmin/.bashrc
#	echo "export AZURE_CLIENT_ID=$SP_APP_ID" >> /home/aroadmin/.bashrc
#	echo "export AZURE_SECRET=$SP_SECRET" >> /home/aroadmin/.bashrc
#	echo "export AZURE_SUBSCRIPTION_ID=$AZ_SUBSCRIPTION_ID" >> /home/aroadmin/.bashrc
#	echo "export AZURE_TENANT=$AZ_TENANT_ID" >> /home/aroadmin/.bashrc
        su -c "gconftool-2 -t bool -s /apps/rhsm-icon/hide_icon true" - aroadmin
	su -c "ssh-keygen -t rsa -q -P '' -f /home/aroadmin/.ssh/id_rsa" - aroadmin
        mkdir -p /home/aroadmin/.local/share/keyrings
	wget --quiet -P /home/aroadmin/.local/share/keyrings https://raw.githubusercontent.com/stuartatmicrosoft/aro-private/master/provision-scripts/Default.keyring
        chown aroadmin:aroadmin /home/aroadmin/.local/share/keyrings/Default.keyring
        chown -R aroadmin:aroadmin /home/aroadmin/.local
        chmod a+rx /home/aroadmin/.local
        restorecon -Rv /home/aroadmin/.local/share/keyrings/Default.keyring
echo "********************************************************************************************"
        cd /usr/local/bin
	wget -P /usr/local/bin http://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz
        tar xvfz oc.tar.gz
        rm -f oc.tar.gz
echo "********************************************************************************************"

echo "`date` --END-- Provisioning" >>/root/provision-script-output.log

echo "`date` Creating Student Desktop Credentials File" >>/root/provision-script-output.log

mkdir /home/aroadmin/Desktop
chown aroadmin:aroadmin /home/aroadmin/Desktop
#echo AZURE_USER_NAME=$AZ_USER_NAME >> /home/aroadmin/Desktop/credentials.txt
#echo AZURE_USER_PASSWORD=$AZ_USER_PASSWORD >> /home/aroadmin/Desktop/credentials.txt
#echo AZURE_CLIENT_ID=$SP_APP_ID >> /home/aroadmin/Desktop/credentials.txt
#echo AZURE_SECRET=$SP_SECRET >> /home/aroadmin/Desktop/credentials.txt
#echo AZURE_SUBSCRIPTION_ID=$AZ_SUBSCRIPTION_ID >> /home/aroadmin/Desktop/credentials.txt
#echo AZURE_TENANT_ID=$AZ_TENANT_ID >> /home/aroadmin/Desktop/credentials.txt
#echo GUIDE_URL=https://github.com/stuartatmicrosoft/aro-private >> /home/aroadmin/Desktop/credentials.txt
#chown aroadmin:aroadmin /home/aroadmin/Desktop/credentials.txt

echo "`date` --END-- Provision Script" >>/root/provision-script-output.log

exit 0

