#!/bin/bash

exec 2>&1
set -e
set -x

# 使用阿里镜像源
cat > /etc/apt/sources.list <<EOF
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
EOF

# 安装软件
apt-get update
apt-get install -y --no-install-recommends --no-install-suggests --force-yes \
    autoconf \
    bind9-host \
    bison \
    build-essential \
    coreutils \
    daemontools \
    dnsutils \
    ed \
    git \
    imagemagick \
    iputils-tracepath \
    language-pack-en \
    libbz2-dev \
    libcurl4-openssl-dev \
    libevent-dev \
    libglib2.0-dev \
    libjpeg-dev \
    libmysqlclient-dev \
    libncurses5-dev \
    libpq-dev \
    libpq5 \
    libreadline6-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    libffi6 \
    libffi-dev \
    netcat-openbsd \
    openssh-client \
    openssh-server \
    postgresql \
    python \
    python-dev \
    ruby \
    ruby-dev \
    socat \
    iperf \
    syslinux \
    tar \
    inetutils-ping \
    telnet \
    zip \
    vim \
    wget \
    zlib1g-dev \
    libsqlite3-dev \
    libfreetype6-dev \
    freetds-dev \
    libsasl2-dev \
    language-pack-zh-hans \
    language-pack-zh-hant \
    language-pack-en \
    tzdata \
    cron


# 解决python的PIL包无法找到lib问题
ln -s /lib/x86_64-linux-gnu/libz.so.1 /lib/
ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so.6 /usr/lib/
ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so.62 /usr/lib/


# 解决php-5.3编译依赖问题
ln -s /usr/lib/x86_64-linux-gnu/libXpm.a /usr/lib/libXpm.a
ln -s /usr/lib/x86_64-linux-gnu/libXpm.so /usr/lib/libXpm.so
ln -s /usr/include/freetype2 /usr/include/freetype2/freetype
# 解决php找不到libreadline库问题
ln -s /lib/x86_64-linux-gnu/libreadline.so.7.0  /lib/x86_64-linux-gnu/libreadline.so.6
# 解决php编译 'CURL_OPENSSL_3' not found 问题
apt-get install --no-install-recommends --no-install-suggests  -y software-properties-common
add-apt-repository ppa:xapienz/curl34
apt-get install  --no-install-recommends --no-install-suggests  -y  curl libcurl4

# 清理
cd /
rm -rf /var/cache/apt/archives/*.deb
rm -rf /root/*
rm -rf /tmp/*

apt-get autoremove -y && \
apt-get clean -y && \
rm -rf \
        /usr/share/doc \
        /usr/share/man \
        /usr/share/info \
        /usr/share/locale \
        /var/lib/apt/lists/* \
        /var/lib/dpkg/info/* \
        /var/log/* \
        /var/cache/debconf/* \
        /var/cache/apt/archives/*.deb \
        /etc/systemd \
        /lib/lsb \
        /lib/udev \
        /usr/lib/x86_64-linux-gnu/gconv/IBM* \
        /usr/lib/x86_64-linux-gnu/gconv/EBC* && \
bash -c "mkdir -p /usr/share/man/man{1..8}"


# remove SUID and SGID flags from all binaries
function pruned_find() {
  find / -type d \( -name dev -o -name proc \) -prune -o $@ -print
}

pruned_find -perm /u+s | xargs -r chmod u-s
pruned_find -perm /g+s | xargs -r chmod g-s


# display build summary
set +x

echo -e "\nInstalled versions:"
(
  git --version
  ruby -v
  gem -v
  python -V
) | sed -u "s/^/  /"

echo -e "\nSuccess!"

exit 0