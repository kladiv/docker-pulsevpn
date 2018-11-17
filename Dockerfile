FROM jamgocoop/pulsesecure-vpn
MAINTAINER Claudio Mastrapasqua <claudio.mastrapasqua@gmail.com>
# build and install ocproxy
RUN apk add libevent && \
    apk add --no-cache --virtual=build-dependencies make gcc g++ zlib-dev autoconf automake libevent-dev bsd-compat-headers linux-headers git bash && \
    cd tmp && \
    git clone https://github.com/cernekee/ocproxy.git && \
    cd ocproxy && \
    ./autogen.sh && ./configure && make && make install && \
    apk del --purge build-dependencies && rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

COPY startup.sh /root/startup.sh
EXPOSE 2222
