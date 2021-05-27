#!/bin/sh

if [ -z "$SERVER_NAME" ];
then
    echo
    echo "Export the server name using the following command and run the script again."
    echo "export SERVER_NAME={Domain Name}"
    echo
    exit
else
    echo
    echo "Creating Apache config file."
    export SERVER_ALIAS_NAME="www.$SERVER_NAME"
    cat template.conf | envsubst > server.conf
    echo
    echo
fi

if [ ! -x /var/lib/apache2 ]; 
    then
        echo "-------------------------"
        echo "|  INSTALLING APACHE2   |"
        echo "-------------------------"
        echo 

        echo "************  Update existing list of packages  ************"
        apt-get update -y
        echo 

        echo "************  Installing Apache2 packages  ************"
        apt install -y apache2
        echo 
        echo 
        echo 
        echo "-------------------------------------"
        echo "|  APACHE2 INSTALLED SUCCESSFULLY   |"
        echo "-------------------------------------"
        echo 
        echo 
        echo "-----------------------------"
        echo "|  ADJUSTING THE FIREWALL   |"
        echo "-----------------------------"
        echo 

        if [ ! -e /var/lib/dpkg/info/ufw.list ]; 
            then
                echo 
                echo "************  Installing UFW  ************"
                apt install -y ufw
                echo 
                echo 
        fi

        if [ ! -e /var/lib/dpkg/info/openssh-server.list ];
            then
                echo 
                echo "************  Installing openssh-server  ************"
                apt-get update
                apt install -y openssh-server
                echo 
                echo 
        fi

        echo "************  Setting up basic firewall  ************"
        ufw allow OpenSSH
        echo 

        echo "************  Enable basic firewall  ************"
        echo "y" | ufw enable
        echo 

        echo "************  Show available application profiles  ************"
        ufw app list
        echo 
        echo 
        echo "Apache: This profile opens only port 80 (normal, unencrypted web traffic)"
        echo "Apache Full: This profile opens both port 80 (normal, unencrypted web traffic) and port 443 (TLS/SSL encrypted traffic)"
        echo "Apache Secure: This profile opens only port 443 (TLS/SSL encrypted traffic)"
        echo 
        echo 

        echo "************  Allow Traffic on port 80  ************"
        ufw allow 'Apache'
        echo 

        echo "************  Check Firewall status  ************"
        ufw status
        echo 

        echo "************  Enabling Necessary Apache Proxy Modules  ************"
        a2enmod proxy
        a2enmod proxy_http
        a2enmod proxy_balancer
        a2enmod lbmethod_byrequests
        systemctl restart apache2
        echo 

        echo 
        echo "-------------------------------"
        echo "|  Setting Up Virtual Hosts   |"
        echo "-------------------------------"
        echo 
        echo 

        echo "************  Copying Domain Configuration File  ************"
        cp server.conf /etc/apache2/sites-available/
        echo 

        echo "************  Enable the file with the a2ensite tool  ************"
        a2ensite server.conf
        systemctl reload apache2
        echo 

        echo "************  Disable the default site defined in 000-default.conf  ************"
        a2dissite 000-default.conf
        systemctl reload apache2
        echo 

        echo "************   Test for configuration errors(Should get: Syntax OK)  ************"
        apache2ctl configtest
        echo 

        echo "************  Restart Apache  ************"
        systemctl restart apache2
        echo 

else
    echo
            echo "APACHE2 ALREADY INSTALLED"
    echo
fi