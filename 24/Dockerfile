FROM alpine:edge

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.schema-version="1.0" \
  org.label-schema.name="skilld-nginx" \
  org.label-schema.description="Skilld nginx 1.24 for Drupal" \
  org.label-schema.vcs-url="https://github.com/skilld-labs/skilld-docker-nginx" \
  maintainer="Andy Postnikov <andypost@ya.ru>"

RUN set -ex &&\
  apk --update upgrade --clean-protected --prune --purge &&\
  apk add --upgrade nginx nginx-mod-http-upload-progress nginx-mod-http-brotli &&\
  rm -fr /var/cache/apk/*

COPY fastcgi_params nginx.conf upstream /etc/nginx/
COPY default.conf /etc/nginx/conf.d/

WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
