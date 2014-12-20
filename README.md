## A Sysconf profile

This is a [SYSCONF](https://github.com/geonef/sysconf.base)
profile. SYSCONF is a method and tool to manage custom system files
for easy install, backup and sync.


## MySQL service

Once applied, a MySQL should be running on the system.
```
# netstat -tlpn
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
```


## Gitted import/export

This profile provides:
* [master.mysql.import](tree/etc/gitted/sync/master.mysql.import)
* [master.mysql.export](tree/etc/gitted/sync/master.mysql.export)

They are called for import/export from/to the ```master``` branch by
Gitted's
[master.import](https://github.com/geonef/sysconf.gitted/blob/master/tree/etc/gitted/sync/master.impport)
and
[master.export](https://github.com/geonef/sysconf.gitted/blob/master/tree/etc/gitted/sync/master.export).

By default, they act on database ```mysql``` and repository
directory ```mysql```. You can change that by providing
```/etc/gitted/sync/defs``` with:
```
GITTED_MYSQL_DATA_PATH=mysql_data
GITTED_MYSQL_DATABASE=mydatabase
```


## Gitted integration

* To create a new Gitted repository, follow the instructions at
  [How to setup Gitted for an application](https://github.com/geonef/sysconf.gitted/blob/master/doc/howto-create-new.md)
  
* Then add this Sysconf profile:
```
git subtree add -P sysconf/sysconf.gitted.mysql git@github.com:geonef/sysconf.gitted.mysql.git master
```

* Integrate it in the dependency chain, for example:
```
echo sysconf.gitted.mysql >sysconf/actual/deps
```

* Then push it to the container:
```
sysconf/gitted-client register
git push <name> master
```


## Authors

Written by Jean-Francois Gigand <jf@geonef.fr>. Feel free to contact me!
