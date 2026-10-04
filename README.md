Introduction
------------

SHUJI (Shuttle Unix hosts JSON Import).

Imports a Unix hosts file (/etc/hosts) or an SSH config file (~/.ssh/config) and converts it to a JSON config file for [Shuttle](https://github.com/fitztrev/shuttle).

Version
-------

Current version: 0.1.6

See [CHANGELOG.md](CHANGELOG.md) for the history of changes.

Features
--------

- Imports a hosts file (default /etc/hosts) and converts it to a JSON config file
- Imports an SSH config file (`-s`, default ~/.ssh/config)
- Puts hosts in sub menus under their domain name (short names and IP addresses go under Local)
- Hosts file: the first word of a comment at the end of a host line is used as the SSH user
- Hosts file: ignores 127., 255. and IPv6 addresses
- SSH config: each `Host` alias becomes a menu entry running `ssh <alias>`, so the user, port and keys come from your SSH config
- SSH config: wildcard and negated `Host` patterns and `Match` blocks are ignored, and `Include` files are not followed
- Installs missing Ruby modules automatically

Requirements
------------

Ruby modules (installed automatically with `gem install --user-install` if missing, or with `bundle install`):

- getopt
- json

Applications:

- [Shuttle](https://github.com/fitztrev/shuttle)

The original Shuttle repository is unmaintained, but others have forked and updated it, e.g.

https://github.com/holywen/shuttle

Usage
-----

One of `-t`, `-j` or `-o` is required. Running without any of them prints the usage and changes nothing.

Getting help:

```
$ shuji.rb -h

Usage: ./shuji.rb -[hi:jo:sT:tVl:]

-V: Display version information
-h: Display usage information
-i: Import file (default /etc/hosts, or ~/.ssh/config with -s)
-s: Import file is an SSH config file rather than a hosts file
-o: Output file (default ~/.shuttle.json, implies -j)
-j: Convert hosts file to a JSON file
-t: Output to standard IO
-T: Set Terminal application (default iTerm.app)
-l: Start Shuttle at login (default true, use -l no to disable)
```

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
  "_comment1": "Shuttle SSH JSON config file created by shuji (Shuttle/SSH Hosts Unix JSON Importer) v. 0.1.6 Richard Spindler <richard@lateralblast.com.au>",
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

Output to <code>~/.shuttle.json</code> (this overwrites the existing file):

```
$ shuji.rb -j
```

Convert an SSH config file instead of a hosts file:

```
$ cat ~/.ssh/config
Host web1
  HostName web1.example.com
  User deploy
Host nas
  HostName 192.168.1.20

$ shuji.rb -s -t
{
  ...
  "hosts": [
    {
      "Example.com": [
        {
          "name": "web1",
          "cmd": "ssh web1"
        }
      ]
    },
    {
      "Local": [
        {
          "name": "nas",
          "cmd": "ssh nas"
        }
      ]
    }
  ]
}
```

License
-------

This software is licensed as CC BY-NC-SA 4.0 (Creative Commons Attribution-NonCommercial-ShareAlike)

https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

Help Support Development
------------------------

If you find this software useful and would like to support its development, please consider buying me a coffee:

https://ko-fi.com/richardatlateralblast
