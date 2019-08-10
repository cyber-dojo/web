
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
- [![CircleCI](https://circleci.com/gh/cyber-dojo/mapper.svg?style=svg)](https://circleci.com/gh/cyber-dojo/mapper) [mapper](https://github.com/cyber-dojo/mapper) - maps session ids [ported](https://github.com/cyber-dojo/porter) from old architecture (storer) to new architecture (saver)
- [![CircleCI](https://circleci.com/gh/cyber-dojo/nginx.svg?style=svg)](https://circleci.com/gh/cyber-dojo/nginx) [nginx](https://github.com/cyber-dojo/nginx) - web-proxy, security, and images (png) cache
- [![CircleCI](https://circleci.com/gh/cyber-dojo/ragger.svg?style=svg)](https://circleci.com/gh/cyber-dojo/ragger) [ragger](https://github.com/cyber-dojo/ragger) -  determines the traffic-light colour of runner's [stdout,stderr,status] as **r**ed-**a**mber-**g**reen
- [![CircleCI](https://circleci.com/gh/cyber-dojo/runner.svg?style=svg)](https://circleci.com/gh/cyber-dojo/runner) [runner](https://github.com/cyber-dojo/runner) - runs the tests and returns [stdout,stderr,status,timed_out]  
- [![CircleCI](https://circleci.com/gh/cyber-dojo/saver.svg?style=svg)](https://circleci.com/gh/cyber-dojo/saver) [saver](https://github.com/cyber-dojo/saver) - saves groups/katas and code/test files in a host dir volume-mounted to /cyber-dojo  
- [![CircleCI](https://circleci.com/gh/cyber-dojo/zipper.svg?style=svg)](https://circleci.com/gh/cyber-dojo/zipper) [zipper](https://github.com/cyber-dojo/zipper) - creates tgz files for download

- - - -

# build the image and run the tests

```text
$ ./pipe_build_up_test.sh
...
Building web
Step 1/10 : FROM cyberdojo/web-base
 ---> 67c57a7b5ff2
Step 2/10 : LABEL maintainer=jon@jaggersoft.com
 ---> Using cache
 ---> 6d134c67a52e
Step 3/10 : WORKDIR /cyber-dojo
 ---> Using cache
 ---> 70fccfc9b293
Step 4/10 : COPY . .
 ---> Using cache
 ---> 0d51abad35d1
Step 5/10 : RUN chown -R nobody:nogroup .
 ---> Using cache
 ---> 3f5f5c0ac715
Step 6/10 : ARG SHA
 ---> Using cache
 ---> 7616bb566271
Step 7/10 : ENV SHA=${SHA}
 ---> Running in 10edf2b1447a
Removing intermediate container 10edf2b1447a
 ---> 2961d952f484
Step 8/10 : EXPOSE  3000
 ---> Running in 6cf9d0c08904
Removing intermediate container 6cf9d0c08904
 ---> 5d8f4c58172f
Step 9/10 : USER nobody
 ---> Running in 7bf87ab3a4e6
Removing intermediate container 7bf87ab3a4e6
 ---> df9f7c5bbb71
Step 10/10 : CMD [ "./up.sh" ]
 ---> Running in 161582b5ab4e
Removing intermediate container 161582b5ab4e
 ---> 4d7e74d38a25
Successfully built 4d7e74d38a25
Successfully tagged cyberdojo/web:latest

Creating network "web_default" with the default driver
Creating test-web-exercises ... done
Creating test-web-custom    ... done
Creating test-web-mapper    ... done
Creating test-web-runner    ... done
Creating test-web-differ    ... done
Creating test-web-languages ... done
Creating test-web-saver     ... done
Creating test-web-ragger    ... done
Creating test-web-zipper    ... done
Creating test-web           ... done
Waiting until custom is ready...........OK
Waiting until exercises is ready.OK
Waiting until languages is ready.OK
Waiting until runner is ready.OK
Waiting until differ is ready.OK
Waiting until saver is ready.OK
Waiting until mapper is ready.OK
Waiting until ragger is ready.OK


======lib======
Run options: --seed 24983

# Running:

............

Finished in 0.021134s, 567.8066 runs/s, 5867.3353 assertions/s.
12 runs, 124 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to /tmp/cyber-dojo/coverage/lib. 522 / 1002 LOC (52.1%) covered.
Slowest 5 tests are...
0.0010 - 3d9982:/cyber-dojo/test/lib/cleaner_test.rb:12:cleaned_string cleans away invalid-encodings
0.0001 - 3d9985:/cyber-dojo/test/lib/cleaner_test.rb:49:cleaned_files() cleans away invalid-encodings and then converts Windows line-endings since it is safer and easier to clean away invalid-encodings first and only then perform operations on the cleaned strings
0.0001 - 1813D5:/cyber-dojo/test/lib/phonetic_alphabet_test.rb:73:lowercase      
0.0001 - 1813D4:/cyber-dojo/test/lib/phonetic_alphabet_test.rb:38:uppercase      
0.0001 - 1813D3:/cyber-dojo/test/lib/phonetic_alphabet_test.rb:19:digits         
0.0001 - 3d9984:/cyber-dojo/test/lib/cleaner_test.rb:33:cleaned_files cleans away invalid-encodings
Coverage of lib = 100.0%

======app_helpers======
Run options: --seed 64180

# Running:

.................

Finished in 0.203200s, 83.6613 runs/s, 201.7714 assertions/s.
17 runs, 41 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to /tmp/cyber-dojo/coverage/app_helpers. 784 / 1078 LOC (72.73%) covered.
Slowest 5 tests are...
0.0980 - Qd4D53:/cyber-dojo/test/app_helpers/traffic_light_tip_test.rb:58:traffic light tip for kata in a group does have an avatar-image
0.0922 - Qd4D52:/cyber-dojo/test/app_helpers/traffic_light_tip_test.rb:11:traffic light tip for individual kata does not have avatar-image
0.0006 - 8r6602:/cyber-dojo/test/app_helpers/time_tick_test.rb:34:when days=0,hours!=0 then hours are show with h suffix and minutes are shown with m suffix separated by a colon
0.0001 - 8r6603:/cyber-dojo/test/app_helpers/time_tick_test.rb:48:when days!=0 then days are shown with d suffix and hours are shown with h suffix and minutes are shown with m suffix
0.0001 - E30BAA:/cyber-dojo/test/app_helpers/avatar_image_test.rb:11:avatar_image html
0.0001 - 1PE060:/cyber-dojo/test/app_helpers/pie_chart_test.rb:17:pie-chart from lights
Coverage of app/helpers = 100.0%

======app_lib======
Run options: --seed 57483

# Running:

............................

Finished in 0.021156s, 1323.5185 runs/s, 3308.7962 assertions/s.
28 runs, 70 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to /tmp/cyber-dojo/coverage/app_lib. 667 / 1045 LOC (63.83%) covered.
Slowest 5 tests are...
0.0014 - 74872E:/cyber-dojo/test/app_lib/diff_html_test.rb:101:each diff-chunk is preceeded by section info to allow auto-scrolling in browser
0.0004 - 4499F5:/cyber-dojo/test/app_lib/dashboard_td_gapper_test.rb:311:time-ticks with no collapsing and no td-holes
0.0004 - 4499F4:/cyber-dojo/test/app_lib/dashboard_td_gapper_test.rb:194:fully gapped with collapsing and td-holes
0.0002 - 748980:/cyber-dojo/test/app_lib/diff_html_test.rb:20:non-empty same/added/deleted lines stay as themselves
0.0002 - 4499F6:/cyber-dojo/test/app_lib/dashboard_td_gapper_test.rb:345:time-ticks with collapsing and td-holes
0.0002 - 4499F3:/cyber-dojo/test/app_lib/dashboard_td_gapper_test.rb:167:fully gapped with no collapsing and no td-holes
Coverage of app/lib = 100.0%

======app_models======
Run options: --seed 19281

# Running:

.......................

Finished in 6.515329s, 3.5301 runs/s, 23.7901 assertions/s.
23 runs, 155 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to /tmp/cyber-dojo/coverage/app_models. 860 / 1122 LOC (76.65%) covered.
Slowest 5 tests are...
2.3411 - Nn2152:/cyber-dojo/test/app_models/runner_test.rb:47:timed_out: infinite loop
1.2843 - Nn2150:/cyber-dojo/test/app_models/runner_test.rb:24:amber: file large than max_file_size is truncated
0.9145 - Nn2151:/cyber-dojo/test/app_models/runner_test.rb:35:green: expected=42, actual=6*7
0.6250 - Nn2149:/cyber-dojo/test/app_models/runner_test.rb:15:red: expected=42, actual=6*9
0.5336 - 1P46A6:/cyber-dojo/test/app_models/group_test.rb:81:you can join 64 times and then the group is full
0.5070 - Fb9865:/cyber-dojo/test/app_models/kata_test.rb:132:an event's manifest is ready to create a new kata from
Coverage of app/models = 100.0%

======app_services======
Run options: --seed 51283

# Running:

...................................................

Finished in 2.372320s, 21.4979 runs/s, 214.1364 assertions/s.
51 runs, 508 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to /tmp/cyber-dojo/coverage/app_services. 978 / 1273 LOC (76.83%) covered.
Slowest 5 tests are...
0.8687 - 2BD812:/cyber-dojo/test/app_services/runner_service_test.rb:23:run() tests expecting 42 actual 6*9
0.7842 - 2BD9DC:/cyber-dojo/test/app_services/runner_service_test.rb:38:deleting a file
0.4689 - B96F85:/cyber-dojo/test/app_services/ragger_service_test.rb:21:smoke test ragger.colour() == red
0.0602 - 7023AC:/cyber-dojo/test/app_services/differ_service_test.rb:25:smoke test differ.diff(..., was_tag=0, now_tag=1)
0.0370 - D2w444:/cyber-dojo/test/app_services/saver_service_test.rb:26:smoke test saver methods
0.0226 - 6C33AF:/cyber-dojo/test/app_services/languages_service_test.rb:32:smoke test manifests
Coverage of app/services = 100.0%

======app_controllers======
Run options: --seed 52567

# Running:

.....................................................................

Finished in 25.950459s, 2.6589 runs/s, 49.1706 assertions/s.
69 runs, 1276 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to /tmp/cyber-dojo/coverage/app_controllers. 1875 / 1978 LOC (94.79%) covered.
Slowest 5 tests are...
4.2915 - 62A972:/cyber-dojo/test/app_controllers/dashboard_test.rb:23:with and without avatars, and with and without traffic lights
3.3914 - BE8221:/cyber-dojo/test/app_controllers/kata_test.rb:40:timed_out       
3.2555 - 62A971:/cyber-dojo/test/app_controllers/dashboard_test.rb:11:minute_column/auto_refresh true/false
2.6265 - BE8223:/cyber-dojo/test/app_controllers/kata_test.rb:57:red-green-amber
2.2273 - 8A0F11:/cyber-dojo/test/app_controllers/id_join_test.rb:16:join succeeds once for each avatar name, then session is full
0.9686 - BE8B75:/cyber-dojo/test/app_controllers/kata_test.rb:231:show-json which is used in an Atom plugin
Coverage of app/controllers = 100.0%

t == number of tests
a == number of assertions
f == number of failures
e == number of errors
s == number of skips
secs == time in seconds
t/sec == tests per second
a/sec == assertions per second
cov == coverage %

                    t      a  f  e  s   secs  t/sec  a/sec      cov
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
lib                12    124  0  0  0   0.02    567   5867   100.00
app_helpers        17     41  0  0  0   0.20     83    201   100.00
app_lib            28     70  0  0  0   0.02   1323   3308   100.00
app_models         23    155  0  0  0   6.52      3     23   100.00
app_services       51    508  0  0  0   2.37     21    214   100.00
app_controllers    69   1276  0  0  0  25.95      2     49   100.00
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
total             200   2174  0  0  0  35.08      5     61

DONE
Stopping test-web           ... done
Stopping test-web-zipper    ... done
Stopping test-web-ragger    ... done
Stopping test-web-saver     ... done
Stopping test-web-runner    ... done
Stopping test-web-languages ... done
Stopping test-web-differ    ... done
Stopping test-web-mapper    ... done
Stopping test-web-custom    ... done
Stopping test-web-exercises ... done
Removing test-web           ... done
Removing test-web-zipper    ... done
Removing test-web-ragger    ... done
Removing test-web-saver     ... done
Removing test-web-runner    ... done
Removing test-web-languages ... done
Removing test-web-differ    ... done
Removing test-web-mapper    ... done
Removing test-web-custom    ... done
Removing test-web-exercises ... done
```

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
