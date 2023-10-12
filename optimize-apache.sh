#!/bin/bash
echo "######################################################################"
echo "#                                                                    #"
echo "#         cPanel Confiugration, Hardening & Security Script          #"
echo "#                                                                    #"
echo "#              (Created by Rack Genie rackgenie.net)                 #"
echo "#              Email for queries: info@rackgenie.net                 #"
echo "#                                                                    #"
echo "######################################################################"
echo ""
sleep 2
echo ""
echo "=========== Configuring Apache Web Server for PHP-FPM =========="
sleep 2
echo ""
printf '%s\n' '<IfModule event.c>' \
    'ServerLimit 16' \
    'StartServers 3' \
    'MinSpareThreads 12' \
    'MaxSpareThreads 37' \
    'ThreadsPerChild 25' \
    'MaxRequestWorkers 400' \
    'MaxConnectionsPerChild 0' \
    '</IfModule>' >> /etc/apache2/conf.d/includes/pre_main_global.conf ;
echo ""
###
#Making a Backup of EasyApache Profile in case we need it and Adjusting the Settings!
###
sudo cp /etc/cpanel/ea4/ea4.conf /etc/cpanel/ea4/ea4.conf-bak ;
sed -i \
-e 's/\(maxclients[" ]*:\)\s[0-9"]\+/\1 400/' \
-e 's/\(maxrequestsperchild[" ]*:\)\s[0-9"]\+/\1 0/' \
-e 's/\(serverlimit[" ]*:\)\s[0-9"]\+/\1 16/' \
-e 's/\(startservers[" ]*:\)\s[0-9"]\+/\1 3/' \
-e 's/\(symlink_protect[" ]*:\)\s[A-Za-z0-9"]\+/\1 "On"/' \
-e 's/\(threadsperchild[" ]*:\)\s[0-9"]\+/\1 25/' \
/etc/cpanel/ea4/ea4.conf ;
echo ""
sleep 2
clear ;
sleep 2
echo "=========== Configuring EasyApache4, installing PHP versions, PHP extensions & Apache modules! =========="
echo ""
echo "this process will take few minutes, Please wait!"
echo "....."
sleep 1
echo "...."
sleep 1
echo "..."
sleep 1
echo ".."
sleep 2
echo "."
sleep 3
echo ""
sleep 3
###
#This will download and install the custom PHP Profile with all the required PHP versions and PHP Extensions required for websites, CMS scripts and Server.
###
mkdir /etc/cpanel/ea4/profiles/custom/ ; #Create directory if it doesnt already exist!
cp /root/easycpanel/event-php82818074-phpfpm.json /etc/cpanel/ea4/profiles/custom/ ;
yes | /usr/local/bin/ea_install_profile --install /etc/cpanel/ea4/profiles/custom/event-php82818074-phpfpm.json ;
echo ""
echo ""
sleep 2
echo "EasyApache4 is configured with required Apache modules, PHP versions and PHP extensions."
echo "PHP version 7.4, PHP version 8.0, PHP 8.1 & PHP version 8.2 are installed"
echo ""
sleep 3
echo ""
###
#This will setup the Server default PHP version to PHP 8.1 version.
###
echo "Setting up default PHP Version"
whmapi1 php_set_system_default_version version=ea-php81 ;
whmapi1 php_get_installed_versions | awk '/ea-php/ {print $2}' | xargs -i -n1 whmapi1 php_set_handler version='{}' handler='cgi' ;

/usr/local/cpanel/scripts/restartsrv_cpsrvd ;
echo ""
echo "..."
sleep 1
echo ".."
sleep 2
echo "."
sleep 3
echo ""
echo "PHP 8.1 is set as default PHP version for the server"
echo ""
sleep 4
clear ;
echo "========== Updating PHP memory_limit and other values, Please wait! =========="
echo "....."
sleep 1
echo "...."
sleep 1
echo "..."
sleep 1
echo ".."
sleep 2
echo "."
sleep 2
echo ""
sleep 2
###
#This will update the required values for all the PHP versions to run websites smoothly. 
###
whmapi1 php_ini_set_directives directive='memory_limit:256M' version='ea-php74'
whmapi1 php_ini_set_directives directive='post_max_size:512M' version='ea-php74'
whmapi1 php_ini_set_directives directive='upload_max_filesize:512M' version='ea-php74'
whmapi1 php_ini_set_directives directive='max_input_vars:10000' version='ea-php74'

whmapi1 php_ini_set_directives directive='memory_limit:256M' version='ea-php80'
whmapi1 php_ini_set_directives directive='post_max_size:512M' version='ea-php80'
whmapi1 php_ini_set_directives directive='upload_max_filesize:512M' version='ea-php80'
whmapi1 php_ini_set_directives directive='max_input_vars:10000' version='ea-php80'

whmapi1 php_ini_set_directives directive='memory_limit:256M' version='ea-php81'
whmapi1 php_ini_set_directives directive='post_max_size:512M' version='ea-php81'
whmapi1 php_ini_set_directives directive='upload_max_filesize:512M' version='ea-php81'
whmapi1 php_ini_set_directives directive='max_input_vars:10000' version='ea-php81'

whmapi1 php_ini_set_directives directive='memory_limit:256M' version='ea-php82'
whmapi1 php_ini_set_directives directive='post_max_size:512M' version='ea-php82'
whmapi1 php_ini_set_directives directive='upload_max_filesize:512M' version='ea-php82'
whmapi1 php_ini_set_directives directive='max_input_vars:10000' version='ea-php82'

whmapi1 php_set_default_accounts_to_fpm default_accounts_to_fpm='1'
whmapi1 convert_all_domains_to_fpm
/scripts/restartsrv_apache_php_fpm ;
printf "php_value_open_basedir: { name: 'php_value[open_basedir]', value: \"[%% documentroot %%]:[%% homedir %%]:/var/cpanel/php/sessions/[%% ea_php_version %%]:/tmp:/var/tmp\" }\n" >> /var/cpanel/ApachePHPFPM/system_pool_defaults.yaml ;
/scripts/php_fpm_config --rebuild ;
echo ""
sleep 3
echo ""
echo "PHP values for all PHP versions are updated!"
clear 
sleep 2
echo ""
echo "========== Install Memcache & Securing it =========="
sleep 2
###
#This will install, enable and secure Memcached for the cPanel Server.
###
dnf -y install memcached ;
systemctl enable memcached ;
perl -pi -e "s/OPTIONS=""/OPTIONS="-l 127.0.0.1 -U 0"/g" /etc/sysconfig/memcached ;
systemctl restart memcached ;
echo "Memcache is installed and secured, continuing"
echo ""
sleep 3
clear
echo "========== Installing ImageMagick with ImageMagick PHP Extensions ==========="
sleep 3
###
#This will install and configure the ImageMagick for all the PHP versions installed on Server. 
###
echo ""
dnf config-manager --set-enabled epel ;
dnf install ImageMagick ImageMagick-devel -y ;
yes | /opt/cpanel/ea-php74/root/usr/bin/pecl install imagick ;
yes | /opt/cpanel/ea-php80/root/usr/bin/pecl install imagick ;
yes | /opt/cpanel/ea-php81/root/usr/bin/pecl install imagick ;
yes | /opt/cpanel/ea-php82/root/usr/bin/pecl install imagick ;
/scripts/restartsrv_apache_php_fpm ;
echo ""
echo "Done, continuing..."
echo ""
clear
echo "=========== Installing LetsEncrypt SSL plugin for cPanel =========="
echo ""
echo "You can always change SSL Provider from Lets Encrypt to Sectigo from WHM => AutoSSL Option"
echo ""
sleep 3
###
#This will install, configure and set LetsEncrypt SSL Provider as default SSL Installer for cPanel Server. 
#Customer can always change the SSL Provider from AutoSSL from WHM.
###
/usr/local/cpanel/scripts/install_lets_encrypt_autossl_provider ;
echo ""
sleep 3
echo ""
echo "Setting up default SSL Provider to LetsEncrypt for faster SSL issuances for websites"
sleep 3
echo ""
whmapi1 set_autossl_provider provider=LetsEncrypt x_terms_of_service_accepted https://letsencrypt.org/documents/LE-SA-v1.3-September-21-2022.pdf ;
echo ""
sleep 2
echo ""
echo ""
echo "###########################################################################"
echo "#####                                                                 #####"
echo "########## Server Setup & Configuration is completed! Continuing ##########"
echo "#####                                                                 #####"
echo "###########################################################################"
sleep 3
echo ""
echo "### ========== ### Starting Server Security & Hardening process! ### ========== ###"
echo ""
echo "========== Installing Mod_Security OWASP Ruleset =========="
###
#This will install the OWASP ModSecurity Rules for Server Hardening. 
###
yes | yum install ea-modsec2-rules-owasp-crs -y ;
echo ""
echo "Done, continuing..."
echo ""
sleep 3
echo "========== Installing CSF Firewall & Configuring it! =========="
echo ""
###
#This will install and configure the CSF Firewall for better server security, it will also change SSH Port and will update in Server Firewall.
#SSH Port will also be changed in SSHD Configuration of Server and will be provided at end of the installation.
###
sleep 3
cd /usr/src ;
rm -fv csf.tgz ;
wget https://download.configserver.com/csf.tgz ;
tar -xzf csf.tgz ;
cd csf ;
sh install.sh ;
perl -pi -e 's/TESTING = "1"/TESTING = "0"/g' /etc/csf/csf.conf ;
perl -pi -e 's/RESTRICT_SYSLOG = "0"/RESTRICT_SYSLOG = "3"/g' /etc/csf/csf.conf ;
perl -pi -e 's/SAFECHAINUPDATE = "0"/SAFECHAINUPDATE = "1"/g' /etc/csf/csf.conf ;
perl -pi -e 's/LF_SSHD_PERM = "1"/LF_SSHD_PERM = "3600"/g' /etc/csf/csf.conf ;
perl -pi -e 's/LF_FTPD_PERM = "1"/LF_FTPD_PERM = "3600"/g' /etc/csf/csf.conf ;
perl -pi -e 's/LF_CPANEL_PERM ="1"/LF_CPANEL_PERM = "1800"/g' /etc/csf/csf.conf ;
perl -pi -e 's/LF_SMTPAUTH_PERM = "1"/LF_SMTPAUTH_PERM = "1800"/g' /etc/csf/csf.conf ;
perl -pi -e 's/LF_POP3D_PERM = "1"/LF_POP3D_PERM = "1800"/g' /etc/csf/csf.conf ;
perl -pi -e 's/LF_IMAPD_PERM = "1"/LF_IMAPD_PERM = "1800"/g' /etc/csf/csf.conf ;
perl -pi -e 's/LF_HTACCESS_PERM = "1"/LF_HTACCESS_PERM = "1800"/g' /etc/csf/csf.conf ;
perl -pi -e 's/LF_MODSEC_PERM = "1"/LF_MODSEC_PERM = "1800"/g' /etc/csf/csf.conf ;
CURRENTPORTNUM=22
NEWPORTNUM=$(( $RANDOM % 500  + 1500 ))
## Use this instead for fixed port number 8435 (Talk to L3 tech for information) ##
#NEWPORTNUM=8435
TCPIN=$(cat /etc/csf/csf.conf | grep ^TCP_IN)
TCPINNEW=$(cat /etc/csf/csf.conf | grep ^TCP_IN | sed -e "s/,${CURRENTPORTNUM},/,${NEWPORTNUM},/")
sed -i "s/$TCPIN/$TCPINNEW/g" /etc/csf/csf.conf
csf -r ;
perl -pi -e "s/#Port 22/Port $NEWPORTNUM/g" /etc/ssh/sshd_config ;
systemctl restart sshd ;
echo "CSF Firewall is installed and configured"
echo ""
sleep 3
clear ;
sleep 2
echo "========== Installing ImunifyAV Free version and configuring it! =========="
sleep 2
echo ""
cd /root/; wget https://repo.imunify360.cloudlinux.com/defence360/imav-deploy.sh ;
bash imav-deploy.sh ;
echo "Please wait!"
echo ""
sed -i -e "s|cpu: .*|cpu: 1|" -e "s|io: .*|io: 1|" /etc/sysconfig/imunify360/imunify360.config #Set CPU/IO for malware scans ;
systemctl restart imunify-antivirus ;
/usr/share/av-userside-plugin.sh ;
echo ""
clear ;
sleep 2
echo "========== Running further security configurations, please wait! =========="
###
#This will disable the compilers and will perform further Security hardening of the Server. 
###
echo ""
sleep 3
/scripts/compilers off ;
/scripts/smtpmailgidonly off ;
perl -I/usr/local/cpanel -MCpanel::LoginProfile -le 'print [Cpanel::LoginProfile::install_profile('limits')]->[1];' ;
systemctl stop rpcbind ;
systemctl disable rpcbind ;
echo "========== Disabling cpHulk to avoid False-Positives=========="
whmapi1 configureservice service=cphulkd enabled=0 monitored=0 ;
/usr/local/cpanel/etc/init/stopcphulkd ;
/usr/local/cpanel/bin/cphulk_pam_ctl --disable ;
echo ""
whmapi1 configurebackgroundprocesskiller processes_to_kill='BitchX' processes_to_kill-1='bnc' processes_to_kill-2='eggdrop' processes_to_kill-3='generic-sniffers' processes_to_kill-4='guardservices' processes_to_kill-5='ircd' processes_to_kill-6='psyBNC' processes_to_kill-7='ptlink' processes_to_kill-8='services' ;
systemctl restart cpanel ;
echo ""
echo "Done, continuing..."
echo ""
echo "========== Enabling Monitoring for all Services =========="
whmapi1 enable_monitor_all_enabled_services ;
sleep 3
clear ;
echo ""
echo "##### ========== Configuring Tweak Settings, please wait! ========== #####"
###
#This will configure and optimize the Tweak Settings of the Server. 
###
echo ""
sleep 3
echo ""
echo "....."
sleep 1
echo "...."
sleep 1
echo "..."
sleep 1
echo ".."
sleep 2
echo "."
sleep 3
echo ""
sleep 3
whmapi1 set_tweaksetting key=phploader value=sourceguardian,ioncube ;
whmapi1 set_tweaksetting key=php_upload_max_filesize value=512 ;
whmapi1 set_tweaksetting key=skipboxtrapper value=1 ;
whmapi1 set_tweaksetting key=resetpass value=0 ;
whmapi1 set_tweaksetting key=resetpass_sub value=0 ;
whmapi1 set_tweaksetting key=referrerblanksafety value=1 ;
whmapi1 set_tweaksetting key=referrersafety value=1 ;
whmapi1 set_tweaksetting key=cgihidepass value=1 ;
whmapi1 set_tweaksetting key=maxemailsperhour value=200 ;
echo ""
echo "Tweak Settings are configured for Proper Server Security!"
echo ""
sleep 3
echo ""
echo "========== Installing and configuring Redis for cPanel =========="
dnf -y install elinks ;
dnf -y install redis ;
systemctl enable redis ;
systemctl start redis ;
/opt/cpanel/ea-php74/root/usr/bin/pecl install --configureoptions 'enable-redis-igbinary="no" enable-redis-lzf="no" enable-redis-zstd="no"' redis ;
/opt/cpanel/ea-php80/root/usr/bin/pecl install --configureoptions 'enable-redis-igbinary="no" enable-redis-lzf="no" enable-redis-zstd="no"' redis ;
/opt/cpanel/ea-php81/root/usr/bin/pecl install --configureoptions 'enable-redis-igbinary="no" enable-redis-lzf="no" enable-redis-zstd="no"' redis ;
/opt/cpanel/ea-php82/root/usr/bin/pecl install --configureoptions 'enable-redis-igbinary="no" enable-redis-lzf="no" enable-redis-zstd="no"' redis ;
echo ""
echo "-- Done .. .. Continuing..."
echo ""
echo "========== Installing ConfigServer Mail Queue & ConfigServer ModSecurity Control =========="
echo ""
###
#This will install ModSecurity Control panel and ConfigServer Mail Queue Manager for the Server.
###
cd /usr/src ;
rm -fv /usr/src/cmq.tgz ;
wget http://download.configserver.com/cmq.tgz ;
tar -xzf cmq.tgz ;
cd cmq ;
sh install.sh ;
rm -Rfv /usr/src/cmq* ;
echo ""
sleep 2
echo ""
cd /usr/src ;
rm -fv /usr/src/cmc.tgz ;
wget http://download.configserver.com/cmc.tgz ;
tar -xzf cmc.tgz ;
cd cmc ;
sh install.sh ;
rm -Rfv /usr/src/cmc* ;
echo ""
sleep 3
echo "We are Done!"
sleep 3
clear ;
echo "###############################################################################"
echo "#                                                                             #"
echo "#            Server Configuration & Harening is completed! Continuing         #"
echo "#                                                                             #"
echo "###############################################################################"
echo ""
sleep 4
clear ;
echo "##############################################################################################################"
echo "#                                                                                                            #"
echo "#               Your Server IP is: $serverip & SSH Port is the $NEWPORTNUM,                                 #"
echo "#                         WHM URL is: https://$serverip:2087                                               #"
echo "#                                                                                                            #"
echo "#      Please ignore the Selfsigned SSL Error, you can use your Server Root Password for login to WHM        #"
echo "#                                                                                                            #"
echo "#                                                                                                            #"
echo "#      No configuration is required, all the settings are configured and server is secured as well.          #"
echo "#      Thank you for using this Script. If you liked this Script, please do not forget to Donate!            #"
echo "#                                                                                                            #"
echo "#      You can donate via https://www.ahtshamjutt.com , Also make sure to spread the word!                   #"
echo "#                                                                                                            #"
echo "##############################################################################################################"
echo ""
echo ""
sleep 2
echo ""
#####
#####
#This script will provide all the details on new SSH Login about Last Login, Previous Failed Login Attempts, Server Load, Disk Usage and RAM usage etc.
#####
#####
perl -pi -e "s/#PrintMotd yes/PrintMotd no/g" /etc/ssh/sshd_config ;
echo ""
systemctl restart sshd ;
chmod +x /root/easycpanel/login-info.sh ;
cp /root/easycpanel/login-info.sh /etc/profile.d/ ;
echo ""
echo ""
echo "A reboot is required, please note down the above information and type reboot then press enter."
#####
#####
#Thank you for using this script, you can always contribute by any means. 
#####
#####
