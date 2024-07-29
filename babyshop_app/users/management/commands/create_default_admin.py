from django.contrib.auth import get_user_model
import os
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = "Set default URL for profiles without URL"

    def handle(self, *args, **kwargs):
        username = os.getenv("${DJANGO_SUPERUSER_USERNAME}")


        email = os.getenv("${DJANGO_SUPERUSER_EMAIL}")
        password = os.getenv("${DJANGO_SUPERUSER_PASSWORD}")

        if username is None or email is None or password is None:
            username = "examplename"
            email = "examplemail@mail.com"
            password = "password123"

        print(f"Username: {username}")
        print(f"Email: {email}")
        print(f"Password: {password}")

        User = get_user_model()

        if not User.objects.filter(username=username).exists():
            User.objects.create_superuser(username, email, password)
