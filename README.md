[![Build Status](https://travis-ci.org/cyber-dojo/web.svg?branch=master)](https://travis-ci.org/cyber-dojo/web)

<img src="https://raw.githubusercontent.com/cyber-dojo/web/master/public/images/home_page_logo.png" alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

Main repo for a [cyber-dojo](http://cyber-dojo.org) web server.

Work in progress. Forking from a custom-start-point is not yet implemented.

First make sure docker is installed

```
curl -O https://raw.githubusercontent.com/cyber-dojo/web/master/cli/install-docker.sh
chmod +x install-docker.sh
sudo ./install-docker.sh
```

Then download the cyber-dojo shell script

```
curl -O https://raw.githubusercontent.com/cyber-dojo/web/master/cli/cyber-dojo
chmod +x cyber-dojo
```

Then use the script to control your server

```
sudo ./cyber-dojo up
sudo ./cyber-dojo --help
sudo ./cyber-dojo volume --help
sudo ./cyber-dojo volume ls
sudo ./cyber-dojo volume inspect languages
```
