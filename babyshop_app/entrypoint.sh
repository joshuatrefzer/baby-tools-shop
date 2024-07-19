#!/bin/sh

python manage.py migrate --noinput

echo "
from django.contrib.auth import get_user_model;
import os;
from dotenv import load_dotenv

# Lade Umgebungsvariablen aus der .env-Datei
load_dotenv()

# Überprüfe, ob die Umgebungsvariablen geladen wurden
username = os.getenv('DJANGO_SUPERUSER_USERNAME')
email = os.getenv('DJANGO_SUPERUSER_EMAIL')
password = os.getenv('DJANGO_SUPERUSER_PASSWORD')

print(f'Username: {username}')
print(f'Email: {email}')
print(f'Password: {password}')

User = get_user_model();

if not User.objects.filter(username=username).exists():
    User.objects.create_superuser(username, email, password)
" | python manage.py shell

exec "$@"
