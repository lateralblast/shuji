Introduction
------------

SHUJI (Shuttle Unix hosts JSON Import).

Imports hosts (/etc/hosts) file and converts it to a JSON config file for [Shuttle](https://github.com/fitztrev/shuttle).

License
-------

This software is licensed as CC-BA (Creative Commons By Attrbution)

http://creativecommons.org/licenses/by/4.0/legalcode

Features
--------

- Imports a text file (default /etc/hosts) and converts it to a JSON config file
- Puts hosts in sub menus under domain name
- Interprets comment at end of host line as a user
- Ignores 127. and IPv6 addresses

Requirements
------------

Ruby modules:

- getopt/std
- json

Applications:

- [Shuttle](https://github.com/fitztrev/shuttle)

Examples
--------

![alt tag](https://raw.githubusercontent.com/lateralblast/shuji/master/shuttle.png)

Existing hosts entries:

```
$ cat /etc/hosts |grep ^192
192.168.2.100 sol11u02vb01.local  sol11u02vb01  # sysadmin
192.168.2.161 rhel70vm01.local    rhel70vm01    # sysadmin
192.168.1.250 qnap.local          qnap          # admin
192.168.1.99  macserver.local     macserver     # macserver
```

Output JSON to STDOUT:

```
$ shuji.rb -t
{
  "_comment1": "Shuttle SSH JSON config file created by shuji (Shuttle/SSH Hosts Unix JSON Importer) v. 0.0.1 Richard Spindler <richard@lateralblast.com.au>",
  "terminal": "iTerm",
  "launch_at_login": true,
  "hosts": [
    {
      "Local": [
        {
          "name": "sol11u02vb01",
          "cmd": "ssh sysadmin@sol11u02vb01"
        },
        {
          "name": "rhel70vm01",
          "cmd": "ssh sysadmin@rhel70vm01"
        },
        {
          "name": "qnap",
          "cmd": "ssh admin@qnap"
        },
        {
          "name": "macserver",
          "cmd": "ssh macserver@macserver"
        }
      ]
    }
  ]
}
```

Output to <code>~/.shuttle.json</code>:

```
$ shuji.rb -j
```

Usage
-----

Getting help:

```
$ shuji.rb -h

Usage: ./shuji.rb -[hi:jo:T:tV]

-V: Display version information
-h: Display usage information
-i: Import file
-o: Output file
-j: Convert hosts file to a JSON file
-t: Output to standard IO
-T: Set Terminal application (default iTerm.app)
-l: Start Shuttle at login (default true)
```


