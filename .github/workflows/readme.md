
# main.yml 
Reports to https://app.kosli.com
The workflow to look in if you want to learn about Kosli.

# main_staging.yml 
Reports to https://staging.app.kosli.com
A workflow for Kosli internal development purposes.
When showing CI workflows in Kosli demos, there is a tension created
by the fact that cyber-dojo Flows are unusual in that they need to 
repeat every Kosli step twice; once to report to https://app.kosli.com
and once again to report to https://staging.app.kosli.com
A normal Kosli customer CI workflow yml file would only report to the former.
To resolve this, a git push triggers the two workflows.

This is basically the same as main.yml but it does NOT...
- rebuild the docker image (since the build is not binary reproducible)
- deploy the image to aws-beta/aws-prod (since main.yml already does that)
It _does_ however re-run the test evidence so it is possible (eg if the unit-tests are flaky) 
to get the run from main.yml to report a compliant Artifact and do deployments to aws-beta and 
aws-prod but the run from main_staging.yml to report the same Artifact as non-compliant.
In this situation, the Environment report for staging will see the Artifact deployment
from 1)main.yml and so, in staging, the Artifact will appear as non-compliant in its snapshot.

