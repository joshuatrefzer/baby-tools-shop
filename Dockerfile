FROM python:3.10-alpine

WORKDIR /app

COPY . .

ENV DJANGO_PORT=8025
ENV DJANGO_SUPERUSER_USERNAME=${DEFAULT_ROOT_USERNAME}
ENV DJANGO_SUPERUSER_EMAIL=${DEFAULT_ROOT_EMAIL}
ENV DJANGO_SUPERUSER_PASSWORD=${DEFAULT_ROOT_PASSWORD}

RUN python -m pip install --no-cache-dir -r requirements.txt 

WORKDIR /app/babyshop_app

EXPOSE 8025

ENTRYPOINT ["sh", "-c", "python manage.py migrate --noinput && \
    python manage.py collectstatic --noinput && \
    python create_superuser.py && \
    gunicorn babyshop.wsgi:application --bind 0.0.0.0:${DJANGO_PORT}"]
