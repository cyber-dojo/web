
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Note 0:

Suppose you have a structure like this:

```yml
    job-1:
      script:
        - do-something
        - report-it-to-kosli

    job-2:
      needs: [ job-1 ]
      script:
        - blah-blah
```

and you're worried about kosli-report command failure altering 
the exit status of the job and needlessly affecting the pipeline.
You might split off kosli-reporting into its own job, like this:

```yml
    job-1:
      script:
        - do-something

    report-job-1:
      needs: [ job-1 ]
      script:
        - report-it-to-kosli

    job-2:
      needs: [ job-1 ]
      script:
        - blah-blah
```

Note that `job-2` is `needs:[job-1]`, not `needs:[report-job-1]`
A problem with this approach is that `job-2` could have a `kosli assert`
as part of an sdlc-control-gate and it might run before the kosli-report 
has happened. 
Another potential issue with this split is `report-job-1` may only run
when `job-1` was successful - so kosli will never see a failure report
(only a missing report).

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Note 1:

There are, deliberately, no CI env-vars (at Org or Repo level) for these three:
- KOSLI_HOST
- KOSLI_ORG
- KOSLI_API_TOKEN

To explain...
Suppose there _is_ a CI env-var called `KOSLI_HOST`, and in a yml workflow you
try to override it (explicitly with a literal, or with a different CI env-var)
like this:

```yml
    job-name:
      stage: stage-name
      variables:
        KOSLI_HOST: ${KOSLI_HOST_STAGING}
      script:
        - echo "KOSLI_HOST=:${KOSLI_HOST}:"
```

You'll find that this does not work. The value of `KOSLI_HOST` will _not_
be overriden and will take the value of the pre-existing CI env-var called 
`KOSLI_HOST`. So in all the yml workflows, these three env-vars are set either 
- with a literal 
- with a CI env-var with a _different_ name.
For example:

```yml
variables:
  KOSLI_ORG: cyber-dojo
  KOSLI_HOST: ${KOSLI_HOST_PROD}           # Org env-var  https://app.kosli.com
  KOSLI_API_TOKEN: ${KOSLI_API_TOKEN_PROD} # Org env-var
```

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Note 2:

I've only run kosli commands on main/master like this:

```yml
    job-name:
      stage: stage-name
      script:
        - if [ "${CI_COMMIT_BRANCH}" == "${CI_DEFAULT_BRANCH}" ] ; then
            kosli ... ;
          fi
```

You can't do it like this:

```yml
      job-name:
        stage: stage-name
        rules:
          - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

      sdlc-control-gate:
        stage: sdlc-control-gate-stage
        needs: [ job-name ]
```

because the job with the `rule:` disappears when the `if:` is false
and so the `sdlc-control-gate: needs:` becomes invalid!
FYI - the `if:` syntax is very picky. 
You cant use ${} syntax:
          - if: ${CI_COMMIT_BRANCH} == $CI_DEFAULT_BRANCH
You cant quote:
          - if: $"CI_COMMIT_BRANCH" == $CI_DEFAULT_BRANCH


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Note 3:

When you run a snyk scan
```shell
$ snyk container test cyberdojo/web:2d3cd13
```

the exit code when there is a vulnerability is 1 (non zero).
This causes the job to exit, and any subsequent kosli
commands are not run. This means you only see a green or missing
(never a red). To see reds too you can do this:

```yml
      security-scan:
        script:
          - set +e
          - snyk container test cyberdojo/web:2d3cd13
          - STATUS=$?
          - set -e
          - kosli attest snyk ...
          - ...
          - exit $STATUS
```
