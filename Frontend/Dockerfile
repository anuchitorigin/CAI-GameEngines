FROM nginx:alpine
# COPY /cert.pem /etc/nginx/certs/
# COPY /key.pem /etc/nginx/certs/
RUN rm -rf /usr/share/nginx/html/*
COPY /nginx.conf /etc/nginx/conf.d/default.conf
COPY /build/web/ /usr/share/nginx/html/
EXPOSE 57000