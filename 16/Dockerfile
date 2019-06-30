FROM alpine:3.10

RUN set -ex &&\
  apk add --no-cache --upgrade nginx nginx-mod-http-upload-progress

COPY fastcgi_params nginx.conf upstream /etc/nginx/
COPY default.conf /etc/nginx/conf.d/

WORKDIR /var/www/html
VOLUME /var/www/html

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
