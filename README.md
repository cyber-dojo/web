[![Build Status](https://travis-ci.org/cyber-dojo/web.svg?branch=master)](https://travis-ci.org/cyber-dojo/web)

<img src="https://raw.githubusercontent.com/cyber-dojo/web/master/public/images/home_page_logo.png" alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

Work in progress. Aiming for a command api such as this...

$ ./cyber-dojo volume create --name=jon --git=https://github.com/cyber-dojo/default-languages.git

$ ./cyber-dojo up --languages=jon

from a cyber-dojo server which will git clone the repo into a docker volume
named jon which will then used as the source of languages in the setup page.

