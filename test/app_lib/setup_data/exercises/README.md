[![Build Status](https://travis-ci.org/cyber-dojo/default-exercises.svg?branch=master)](https://travis-ci.org/cyber-dojo/default-exercises)

<img src="https://raw.githubusercontent.com/cyber-dojo/web/master/public/images/home_page_logo.png" alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

Work in progress. Aiming for a command api such as this...

$ ./cyber-dojo volume create --name=refactoring --git=https://github.com/cyber-dojo/default-exercises.git

$ ./cyber-dojo up --exercises=refactoring

from a cyber-dojo server which will pull the repo and put it into a docker
volume named refactoring which will then used as the source of exercises in the setup page.
