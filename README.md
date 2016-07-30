[![Build Status](https://travis-ci.org/cyber-dojo/web.svg?branch=master)](https://travis-ci.org/cyber-dojo/web)

<img src="https://raw.githubusercontent.com/cyber-dojo/web/master/public/images/home_page_logo.png" alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

Main repo for a [cyber-dojo](http://cyber-dojo.org) web server.<br/>

(1) make sure docker, docker-engine, and docker-compose are installed

```
$ curl -O https://raw.githubusercontent.com/cyber-dojo/web/master/cli/install-docker.sh
$ chmod +x install-docker.sh
$ sudo ./install-docker.sh
```

(2) download the cyber-dojo shell script

```
$ curl -O https://raw.githubusercontent.com/cyber-dojo/web/master/cli/cyber-dojo
$ chmod +x cyber-dojo
```

(3) use the script to bring up your server

```
$ sudo ./cyber-dojo up
```
