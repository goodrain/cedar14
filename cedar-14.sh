#!/bin/bash

exec 2>&1
set -e
set -x

# 使用阿里云镜像
sed -i -e 's/ports.ubuntu.com/mirrors.aliyun.com/g' \
    -e 's/archive.ubuntu.com/mirrors.aliyun.com/g' \
    -e 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && apt-get update

if [ $(arch) == "x86_64" ];then
apt-get install -y --force-yes \
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
    python-imaging \
    ruby \
    ruby-dev \
    syslinux \
    tar \
    zip vim curl \
    zlib1g-dev \
    libsqlite3-dev \
    libfreetype6-dev \
    libpng12-dev \
    libXpm-dev \
    freetds-dev \
    libsasl2-dev \
    language-pack-zh-hans \
    language-pack-zh-hant \
    language-pack-en
elif [ $(arch) == "aarch64" ];then
apt-get install -y --force-yes \
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
    openssh-client \
    openssh-server \
    python-imaging \
    syslinux-common \
    ruby \
    ruby-dev \
    tar \
    zip vim curl \
    zlib1g-dev \
    libsqlite3-dev \
    libfreetype6-dev \
    libpng12-dev \
    libXpm-dev \
    freetds-dev \
    libsasl2-dev \
    language-pack-zh-hans \
    language-pack-zh-hant \
    language-pack-en
fi

# 解决python的PIL包无法找到lib问题
ln -s /lib/x86_64-linux-gnu/libz.so.1 /lib/
ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so.6 /usr/lib/
ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so.62 /usr/lib/



# 解决php-5.3编译依赖问题
ln -s /usr/lib/x86_64-linux-gnu/libXpm.a /usr/lib/libXpm.a
ln -s /usr/lib/x86_64-linux-gnu/libXpm.so /usr/lib/libXpm.so
ln -s /usr/include/freetype2 /usr/include/freetype2/freetype

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

# remove non-root ownership of files
chown root:root /var/lib/libuuid

# display build summary
set +x
echo -e "\nRemaining suspicious security bits:"
(
  pruned_find ! -user root
  pruned_find -perm /u+s
  pruned_find -perm /g+s
  pruned_find -perm /+t
) | sed -u "s/^/  /"

echo -e "\nInstalled versions:"
(
  git --version
  ruby -v
  gem -v
  python -V
) | sed -u "s/^/  /"

echo -e "\nSuccess!"

exit 0
