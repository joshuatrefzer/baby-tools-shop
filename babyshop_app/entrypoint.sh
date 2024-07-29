#!/bin/sh

python manage.py migrate --noinput
python manage.py collectstatic --noinput
python manage.py createsuperuser --noinput --username ${DJANGO_SUPERUSER_USERNAME} --email ${DJANGO_SUPERUSER_EMAIL} || true
exec gunicorn babyshop.wsgi:application --bind 0.0.0.0:${DJANGO_PORT}


