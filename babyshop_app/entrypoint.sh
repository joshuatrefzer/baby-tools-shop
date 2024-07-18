#!/bin/sh

# Führt Datenbankmigrationen durch
python manage.py migrate --noinput

# Erstellt einen Superuser falls dieser noch nicht existiert
echo "from django.contrib.auth import get_user_model; User = get_user_model(); \
if not User.objects.filter(username='admin').exists(): \
    User.objects.create_superuser('admin', 'admin@example.com', 'password')" \
| python manage.py shell

# Starte den Django-Server
exec "$@"
