FROM python:3.10-alpine

WORKDIR /app

COPY . $WORKDIR
RUN python -m pip install --no-cache-dir -r requirements.txt

WORKDIR /app/babyshop_app

RUN python manage.py migrate --noinput && \
    python manage.py collectstatic --noinput 

EXPOSE 8025

ENTRYPOINT ["gunicorn", "babyshop.wsgi:application", "--bind", "0.0.0.0:8025"]
