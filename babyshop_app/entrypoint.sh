#!/bin/sh

python manage.py migrate --noinput
python manage.py collectstatic --noinput
python create_superuser.py
exec gunicorn babyshop.wsgi:application --bind 0.0.0.0:${DJANGO_PORT}


