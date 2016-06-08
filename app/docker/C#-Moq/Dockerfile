FROM frolvlad/alpine-mono

RUN apk add --update openssl
RUN mozroots --import --sync
RUN wget http://nuget.org/nuget.exe
COPY packages.config .
RUN mono --runtime=v4.0 nuget.exe restore -PackagesDirectory .
RUN gacutil /i Moq.4.0.10827/lib/NET40/Moq.dll
RUN gacutil -l | grep Moq

RUN cp Moq.4.0.10827/lib/NET40/Moq.dll .
COPY demo.cs .
RUN dmcs -t:exe -r:Moq.dll demo.cs
RUN mono ./demo.exe

