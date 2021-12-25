#FROM goodrainapps/ubuntu:14.04.20170613
FROM ubuntu:14.04
COPY ./cedar-14.sh /tmp/build.sh
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive /tmp/build.sh
ENV RELEASE_DESC=__RELEASE_DESC__