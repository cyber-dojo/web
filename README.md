
[![CircleCI](https://circleci.com/gh/cyber-dojo/web.svg?style=svg)](https://circleci.com/gh/cyber-dojo/web)

- The source for the [cyberdojo/web](https://hub.docker.com/r/cyberdojo/web/tags) Docker image.
- A docker-containerized stateless micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- Runs a rails web server.

Uses these microservices:
- [![CircleCI](https://circleci.com/gh/cyber-dojo/avatars.svg?style=svg)](https://circleci.com/gh/cyber-dojo/avatars) [avatars](https://github.com/cyber-dojo/avatars) - serves the avatar names and images
- [![CircleCI](https://circleci.com/gh/cyber-dojo/custom.svg?style=svg)](https://circleci.com/gh/cyber-dojo/custom) [custom](https://github.com/cyber-dojo/custom) - serves the custom start-points
- [![CircleCI](https://circleci.com/gh/cyber-dojo/differ.svg?style=svg)](https://circleci.com/gh/cyber-dojo/differ) [differ](https://github.com/cyber-dojo/differ) - diffs two sets of files
- [![CircleCI](https://circleci.com/gh/cyber-dojo/exercises.svg?style=svg)](https://circleci.com/gh/cyber-dojo/exercises) [exercises](https://github.com/cyber-dojo/exercises) - serves the exercises start-points
- [![CircleCI](https://circleci.com/gh/cyber-dojo/languages.svg?style=svg)](https://circleci.com/gh/cyber-dojo/languages) [languages](https://github.com/cyber-dojo/languages) - serves the languages start-points
- [![CircleCI](https://circleci.com/gh/cyber-dojo/ragger.svg?style=svg)](https://circleci.com/gh/cyber-dojo/ragger) [ragger](https://github.com/cyber-dojo/ragger) -  determines the traffic-light colour of runner's [stdout,stderr,status] as **r**ed-**a**mber-**g**reen
- [![CircleCI](https://circleci.com/gh/cyber-dojo/runner.svg?style=svg)](https://circleci.com/gh/cyber-dojo/runner) [runner](https://github.com/cyber-dojo/runner) - runs the tests and returns [stdout,stderr,status,timed_out]  
- [![CircleCI](https://circleci.com/gh/cyber-dojo/saver.svg?style=svg)](https://circleci.com/gh/cyber-dojo/saver) [saver](https://github.com/cyber-dojo/saver) - saves groups/katas and code/test files in a host dir volume-mounted to /cyber-dojo  
- [![CircleCI](https://circleci.com/gh/cyber-dojo/zipper.svg?style=svg)](https://circleci.com/gh/cyber-dojo/zipper) [zipper](https://github.com/cyber-dojo/zipper) - creates tgz files for download


![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
