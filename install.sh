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

sysconf_require_packages $_packages

# Create MySQL database and user for demo
mysql_run "CREATE DATABASE IF NOT EXISTS demo"
_count=$(mysql_run "SELECT User FROM mysql.user WHERE User = 'demo'" | grep ^demo | wc -l)
if [ $_count -eq 0 ]; then
    mysql_run "CREATE USER 'demo'@'%' IDENTIFIED BY 'demo'"
    mysql_run "SET PASSWORD FOR 'demo'@'%' = PASSWORD('SsDead034pVBs1NxQo4a')"
    mysql_run "GRANT ALL PRIVILEGES ON demo.* TO 'demo' "
    mysql_run "FLUSH PRIVILEGES"
fi
_count=$(echo "SHOW TABLES" | mysql demo | tail -n +2 | wc -l)
if [ $_count -eq 0 ]; then
    echo "Populating MySQL database: demo"
    # cat /var/lib/etherpad-legacy/database.structure.sql | mysql etherpad
fi

# END
