FROM frolvlad/alpine-mono

RUN apk add --update openssl
RUN mozroots --import --sync
RUN wget http://nuget.org/nuget.exe
COPY packages.config .
RUN mono --runtime=v4.0 nuget.exe restore -PackagesDirectory .
RUN cp Moq.4.0.10827/lib/NET40/Moq.dll .
RUN cp NUnit.2.6.2/lib/nunit.framework.dll .

COPY *.cs ./

RUN dmcs -t:library -r:Moq.dll -r:nunit.framework.dll -out:RunTests.dll *.cs

RUN nunit-console -nologo RunTests.dll
