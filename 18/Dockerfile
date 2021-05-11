FROM alpine:3.13

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="skilld-nginx" \
  org.label-schema.description="Skilld nginx 1.18 for Drupal" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/skilld-docker-nginx" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

RUN set -ex &&\
  apk add --no-cache --upgrade nginx nginx-mod-http-upload-progress nginx-mod-http-brotli

RUN apk add --no-cache openssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=example.com"

COPY fastcgi_params nginx.conf upstream /etc/nginx/
COPY default.conf /etc/nginx/conf.d/

WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
