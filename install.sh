# Installer script for sysconf "actual"  -*- shell-script -*-

. /usr/lib/sysconf.base/common.sh

sysconf_profile_path=$(pwd)

mysql_run() {
    echo "MySQL query: $1" >&2
    echo "$1" >&2
    echo "$1" | mysql
    local _status=${PIPESTATUS[1]}
    if [ $_status -ne 0 ]; then
        nef_fatal "MySQL query failed with status $_status"
    fi
}

# Install required Debian packages
_packages=
_packages="$_packages mysql-server"

# Install NodeJS and fix bin/node -> nodejs
_packages="$_packages nodejs"
_packages="$_packages abiword"

sysconf_require_packages $_packages

[ -x /usr/bin/node ] || ln -s nodejs /usr/bin/node

# Install NPM
if [ ! -x /usr/bin/npm ]; then
    nef_log "Installing NPM..."
    sh npmjs.install.sh \
        || nef_fatal "could not install npm"
fi

# Create MySQL database and user for etherpad
mysql_run "CREATE DATABASE IF NOT EXISTS etherpad"
_count=$(mysql_run "SELECT User FROM mysql.user WHERE User = 'etherpad'" | grep ^etherpad | wc -l)
if [ $_count -eq 0 ]; then
    mysql_run "CREATE USER 'etherpad'@'%' IDENTIFIED BY 'etherpad'"
    mysql_run "SET PASSWORD FOR 'etherpad'@'%' = PASSWORD('SsDead034pVBs1NxQo4a')"
    mysql_run "GRANT ALL PRIVILEGES ON etherpad.* TO 'etherpad' "
    mysql_run "FLUSH PRIVILEGES"
fi
_count=$(echo "SHOW TABLES" | mysql etherpad | tail -n +2 | wc -l)
if [ $_count -eq 0 ]; then
    echo "Populating MySQL database: etherpad"
    # cat /var/lib/etherpad-legacy/database.structure.sql | mysql etherpad
fi

# "etherpad-lite" UNIX account
grep -q ^etherpad-lite: /etc/passwd || {
    useradd -d /var/lib/etherpad-lite etherpad-lite
}

# Install etherpad lite
if [ ! -d /var/lib/etherpad-lite ]; then
    cd /var/lib
    git clone https://github.com/ether/etherpad-lite.git -b 1.4.1 --depth 1
    cd etherpad-lite
    # Patch
    cp $sysconf_profile_path/nodejs_installDeps.sh bin/installDeps.sh
    chown -R etherpad-lite:etherpad-lite .
    sudo -u etherpad-lite -g etherpad-lite bin/installDeps.sh
    rm -f settings.json
    ln -s /etc/etherpad-lite.json settings.json
fi

# Ethpad plugins as listed in sysconf profile's etherpad-lite.plugins.list
if [ -r $sysconf_profile_path/etherpad-lite.plugins.list ]; then
    cd /var/lib/etherpad-lite
    cat $sysconf_profile_path/etherpad-lite.plugins.list | (
        while read line; do
            if echo "$line" | grep -q '^ *[^ #]'; then
                plugin=$(echo "$line" | xargs)

                echo "Installing EtherpadLite plugin: $plugin"
                sudo -u etherpad-lite -g etherpad-lite npm install $plugin
            fi
        done
    )
fi

# Finally...
if ps aux | grep etherpad | grep -qv grep; then
    service etherpad-lite restart
else
    service etherpad-lite start
fi

# END
