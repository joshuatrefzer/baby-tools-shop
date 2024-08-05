import os
import django
from django.contrib.auth import get_user_model

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'babyshop.settings')
django.setup()

def create_superuser():
    User = get_user_model()
    if not User.objects.filter(is_superuser=True).exists():
        print("No superuser found. Creating a new superuser...")
        username = os.environ.get('DJANGO_SUPERUSER_USERNAME')
        email = os.environ.get('DJANGO_SUPERUSER_EMAIL')
        password = os.environ.get('DJANGO_SUPERUSER_PASSWORD')

        if not username or not email or not password:
            print("Superuser credentials not provided in environment variables. Skipping superuser creation.")
            return

        User.objects.create_superuser(username=username, email=email, password=password)
    else:
        print("Superuser already exists. Skipping superuser creation.")

if __name__ == '__main__':
    create_superuser()
