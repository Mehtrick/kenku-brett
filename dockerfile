FROM nginx:alpine
COPY default.conf.template /etc/nginx/templates/
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80