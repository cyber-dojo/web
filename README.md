[![CircleCI](https://circleci.com/gh/cyber-dojo/web.svg?style=svg)](https://circleci.com/gh/cyber-dojo/web)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/avatars/cyber-dojo.png"
     alt="cyber-dojo yin/yang logo"
     width="50px"
     height="50px"/>

The main web-server for [cyber-dojo.org](http://cyber-dojo.org). Uses:
- [![CircleCI](https://circleci.com/gh/cyber-dojo/custom.svg?style=svg)](https://circleci.com/gh/cyber-dojo/custom) [custom](https://github.com/cyber-dojo/custom) - serves the custom start-points
- [![CircleCI](https://circleci.com/gh/cyber-dojo/differ.svg?style=svg)](https://circleci.com/gh/cyber-dojo/differ) [differ](https://github.com/cyber-dojo/differ) - diffs two sets of files
- [![CircleCI](https://circleci.com/gh/cyber-dojo/exercises.svg?style=svg)](https://circleci.com/gh/cyber-dojo/exercises) [exercises](https://github.com/cyber-dojo/exercises) - serves the exercises start-points
- [grafana](https://github.com/cyber-dojo/grafana) to display monitoring data.
- [![CircleCI](https://circleci.com/gh/cyber-dojo/languages.svg?style=svg)](https://circleci.com/gh/cyber-dojo/languages) [languages](https://github.com/cyber-dojo/languages) - serves the languages start-points
- [![CircleCI](https://circleci.com/gh/cyber-dojo/mapper.svg?style=svg)](https://circleci.com/gh/cyber-dojo/mapper) [mapper](https://github.com/cyber-dojo/mapper) - maps session ids [ported](https://github.com/cyber-dojo/porter) from old architecture (storer) to new architecture (saver)
- [![CircleCI](https://circleci.com/gh/cyber-dojo/nginx.svg?style=svg)](https://circleci.com/gh/cyber-dojo/nginx) [nginx](https://github.com/cyber-dojo/nginx) - web-proxy, security, and images (png) cache
- [prometheus](https://github.com/cyber-dojo/prometheus) to store monitoring data.
- [![CircleCI](https://circleci.com/gh/cyber-dojo/ragger.svg?style=svg)](https://circleci.com/gh/cyber-dojo/ragger) [ragger](https://github.com/cyber-dojo/ragger) -  determines the traffic-light colour of runner's [stdout,stderr,status] as **r**ed-**a**mber-**g**reen
- [![CircleCI](https://circleci.com/gh/cyber-dojo/runner.svg?style=svg)](https://circleci.com/gh/cyber-dojo/runner) [runner](https://github.com/cyber-dojo/runner) - runs the tests and returns [stdout,stderr,status,timed_out]  
- [![CircleCI](https://circleci.com/gh/cyber-dojo/saver.svg?style=svg)](https://circleci.com/gh/cyber-dojo/saver) [saver](https://github.com/cyber-dojo/saver) - saves groups/katas and code/test files in a host dir volume-mounted to /cyber-dojo  
- [![CircleCI](https://circleci.com/gh/cyber-dojo/zipper.svg?style=svg)](https://circleci.com/gh/cyber-dojo/zipper) [zipper](https://github.com/cyber-dojo/zipper) - creates tgz files for download



- - - -

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
