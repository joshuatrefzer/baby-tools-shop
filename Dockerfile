FROM python:3.10-alpine

WORKDIR /app

COPY . .

RUN python -m pip install --no-cache-dir -r requirements.txt

RUN cd /app/babyshop_app && \
    python manage.py migrate --noinput && \
    python manage.py collectstatic --noinput && \
    python create_superuser.py

WORKDIR /app/babyshop_app

EXPOSE 8025

ENTRYPOINT ["gunicorn", "babyshop.wsgi:application", "--bind", "0.0.0.0:8025"]
