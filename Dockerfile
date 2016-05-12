################################################################################
## Dockerfile for the base image EyeOS Frontend ################################
################################################################################

FROM docker-registry.eyeosbcn.com/eyeos-fedora21-node-base

MAINTAINER eyeos

#We are writing chrome repo in this ugly way to not invalidate the cache by using COPY or ADD
RUN echo "[google-chrome]" >> /etc/yum.repos.d/google-chrome.repo && \
    echo "name=google-chrome" >> /etc/yum.repos.d/google-chrome.repo && \
    echo "baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64" >> /etc/yum.repos.d/google-chrome.repo && \
    echo "enabled=1" >> /etc/yum.repos.d/google-chrome.repo && \
    echo "gpgcheck=0" >> /etc/yum.repos.d/google-chrome.repo \

    && yum install google-chrome-stable  make autoconf automake gcc bzip2 git nodejs npm gem \
        xorg-x11-server-Xvfb libpng-devel libpng ruby-devel qtwebkit lsof php php-cli -y \
    && yum clean all

RUN npm config set registry "http://artifacts.eyeosbcn.com/nexus/content/groups/npm/" && \
    npm install -g nan && \
    sed -i -e 's/v8::String::REPLACE_INVALID_UTF8/0/g' /lib/node_modules/nan/nan.h && \
    head -n 321 /lib/node_modules/nan/nan.h | tail -n 13 && \
    npm -g install node-gyp && \
    npm -g install iconv \
    && npm install -g coffee-script i18next-conv \
    && npm -g cache clean \
    && npm cache clean

RUN gem update --no-document --system \
    && gem install --no-document json_pure compass \
    && gem cleanup \
    && gem sources -c

RUN git config --global user.email "jenkins@eyeos.com" \
    && git config --global user.name "Jenkins"

COPY netrc /root/.netrc
