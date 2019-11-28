FROM alpine:3.10.3

# Version ENVs
ENV NGINX_VER="1.16.1"
ENV RTMP_VER="1.2.1"

RUN addgroup nginx && \
    adduser -H -D -G nginx nginx && \
    echo "nginx:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

RUN apk add --virtual deps \
      gcc g++ libressl-dev make zlib-dev && \
    cd ~ && \
    wget http://nginx.org/download/nginx-$NGINX_VER.tar.gz && \
    wget https://github.com/arut/nginx-rtmp-module/archive/v$RTMP_VER.tar.gz && \
    tar xf nginx-$NGINX_VER.tar.gz && \
    tar xf v$RTMP_VER.tar.gz && \
    cd nginx-$NGINX_VER && \
    ./configure --prefix=/opt/nginx \
      --add-module=../nginx-rtmp-module-$RTMP_VER \
      --without-http_rewrite_module && \
    make -j$(nproc) && \
    make install && \
    apk del --purge deps && \
    rm -rf ~/*

COPY nginx.conf /opt/nginx/conf/nginx.conf

CMD /opt/nginx/sbin/nginx -g 'daemon off; user nginx;'
