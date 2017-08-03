FROM alpine:3.6

ENV NGX_VER 1.13.3
ENV NGX_UP_VER 0.9.1
ENV NGX_NXS_VER 0.54
ENV NGINX_DOCUMENT_ROOT /var/www/html/
ENV NGINX_FASTCGI_BUFFERS "16 32k"
ENV NGINX_FASTCGI_BUFFER_SIZE "32k"
ENV NGINX_FASTCGI_READ_TIMEOUT "900"

# Create user and groups
# Based on http://git.alpinelinux.org/cgit/aports/tree/main/nginx-initscripts/nginx-initscripts.pre-install
RUN set -ex && \
    addgroup -S -g 82 www-data && \
    addgroup -S nginx && \
    adduser -S -D -H -h /var/www/localhost/htdocs -s /sbin/nologin -G nginx -g nginx nginx && \
    addgroup nginx www-data

# Install packages
RUN apk add --update \

        # Base packages
        bash \
        openssl \
        ca-certificates \
        pcre \
        zlib \
        luajit \
        geoip \
        tar \
        libcrypto1.0 \
        libssl1.0 \

        # Temp packages
        tar \
        build-base \
        autoconf \
        libtool \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        luajit-dev \
        geoip-dev && \

    # Download nginx and its modules source code
    wget -qO- http://nginx.org/download/nginx-${NGX_VER}.tar.gz | tar xz -C /tmp/ && \
    wget -qO- https://github.com/masterzen/nginx-upload-progress-module/archive/v${NGX_UP_VER}.tar.gz | tar xz -C /tmp/ && \
    wget -qO- https://github.com/nbs-system/naxsi/archive/${NGX_NXS_VER}.tar.gz | tar xz -C /tmp/ && \

    # Make and install nginx with modules
    cd /tmp/nginx-${NGX_VER} && \
    ./configure \
        --prefix=/usr/share/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx/nginx.pid \
        --lock-path=/var/run/nginx/nginx.lock \
        --http-client-body-temp-path=/var/lib/nginx/tmp/client_body \
        --http-proxy-temp-path=/var/lib/nginx/tmp/proxy \
        --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi \
        --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi \
        --http-scgi-temp-path=/var/lib/nginx/tmp/scgi \
        --user=nginx \
        --group=nginx \
        --with-pcre-jit \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-http_v2_module \
        --with-ipv6 \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-http_geoip_module \
        --with-ld-opt="-Wl,-rpath,/usr/lib/" \
        --add-module=/tmp/nginx-upload-progress-module-${NGX_UP_VER}/ \
        --add-module=/tmp/naxsi-${NGX_NXS_VER}/naxsi_src/ && \
    make -j2 && \
    make install && \

    # Cleanup
    apk del --purge *-dev build-base autoconf libtool && \
    rm -rf /var/cache/apk/* /tmp/*

# Create dirs
RUN mkdir /etc/nginx/conf.d && \
    mkdir -p /var/lib/nginx/tmp && \
    chmod 755 /var/lib/nginx && \
    chmod -R 755 /var/lib/nginx/tmp && \
    mkdir -p /etc/nginx/pki && \
    chmod 400 /etc/nginx/pki

# Copy configs
COPY nginx.conf /etc/nginx/nginx.conf
COPY fastcgi_params /etc/nginx/fastcgi_params
COPY drupal* /etc/nginx/conf.d/

RUN if [ -z $NGINX_FASTCGI_BUFFERS ] ; then export NGINX_FASTCGI_BUFFERS="16 32k"; fi
RUN if [ -z $NGINX_FASTCGI_BUFFER_SIZE ] ; then export NGINX_FASTCGI_BUFFER_SIZE="32k"; fi
RUN if [ -z $NGINX_FASTCGI_READ_TIMEOUT ] ; then export NGINX_FASTCGI_READ_TIMEOUT="900"; fi
RUN if [ -z $NGINX_DOCUMENT_ROOT ] ; then export NGINX_DOCUMENT_ROOT="/var/www/html/"; fi

RUN sed -i "s!{{ NGINX_DOCUMENT_ROOT }}!${NGINX_DOCUMENT_ROOT}!g" /etc/nginx/conf.d/drupal8.conf
RUN sed -i "s/{{ NGINX_FASTCGI_BUFFERS }}/${NGINX_FASTCGI_BUFFERS}/" /etc/nginx/nginx.conf
RUN sed -i "s/{{ NGINX_FASTCGI_BUFFER_SIZE }}/${NGINX_FASTCGI_BUFFER_SIZE}/" /etc/nginx/nginx.conf
RUN sed -i "s/{{ NGINX_FASTCGI_READ_TIMEOUT }}/${NGINX_FASTCGI_READ_TIMEOUT}/" /etc/nginx/nginx.conf


WORKDIR ${NGINX_DOCUMENT_ROOT}
VOLUME ${NGINX_DOCUMENT_ROOT}

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
