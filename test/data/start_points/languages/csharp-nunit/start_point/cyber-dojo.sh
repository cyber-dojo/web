NUNIT_PATH=/nunit/lib/net45
export MONO_PATH=${NUNIT_PATH}

mcs -t:library \
  -r:${NUNIT_PATH}/nunit.framework.dll \
  -out:RunTests.dll *.cs

if [ $? -eq 0 ]; then
  NUNIT_RUNNERS_PATH=/nunit/tools
  mono ${NUNIT_RUNNERS_PATH}/nunit3-console.exe --noheader ./RunTests.dll
fi
