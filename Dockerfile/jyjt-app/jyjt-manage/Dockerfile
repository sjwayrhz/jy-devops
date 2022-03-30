FROM nginx:1.21.6
MAINTAINER i@sjhz.cf

COPY dist /usr/share/nginx/html
COPY manage.conf /etc/nginx/conf.d/
#RUN chmod -R 755 /usr/share/nginx/html
EXPOSE 8083

CMD [ "nginx", "-g", "daemon off;"]