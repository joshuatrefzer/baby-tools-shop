
FROM python:3.10-alpine

WORKDIR /app

COPY . .

ARG PORT=8025
ARG DEFAULT_ROOT_PASSWORD 

ENV DJANGO_PORT=$PORT
ENV DJANGO_SUPERUSER_USERNAME='admin' 
ENV DJANGO_SUPERUSER_EMAIL='admin@gmail.com' 
ENV DJANGO_SUPERUSER_PASSWORD=${DEFAULT_ROOT_PASSWORD}


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh 

RUN python -m pip install --no-cache-dir -r requirements.txt

EXPOSE 8025

ENTRYPOINT ["/entrypoint.sh"]



