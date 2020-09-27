FROM ubuntu:18.04

ENV TZ=Asia/Shanghai
COPY ./cedar-14.sh /tmp/build.sh
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive /tmp/build.sh
ENV RELEASE_DESC=__RELEASE_DESC__