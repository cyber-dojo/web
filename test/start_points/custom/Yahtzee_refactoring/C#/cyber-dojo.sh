NUNIT_PATH=/nunit/NUnit.2.6.2/lib
export MONO_PATH=${NUNIT_PATH}

mcs -t:library \
  -r:${NUNIT_PATH}/nunit.framework.dll \
  -out:RunTests.dll *.cs

if [ $? -eq 0 ]; then
  NUNIT_RUNNERS_PATH=/nunit/NUnit.Runners.2.6.1/tools
  mono ${NUNIT_RUNNERS_PATH}/nunit-console.exe -nologo ./RunTests.dll
fi
