# Baby Tool Shop Containerization

This repository demonstrates the containerization of a Baby Tool Shop application using Docker. The goal is to run the DJANGO application inside a Docker container and make it accessible on the internet via an Nginx web server on port 8025. In case of a container failure, the container will automatically restart. Using a Docker Volume ensures data persistence, so that any new or restarted container operates with the same data, preventing data loss when a container is shut down.
This is a step by step guide for the containerization. Make sure you have set up Docker (Docker Deamon is running on your machine).

## Table of Contents

1. [Fork repository from GitHub](#1-fork-respository-from-github)
2. [Create Dockerfile](#2-create-dockerfile)

## 1. Fork respository from GitHub

We don't develop the whole application, we forked it, so we can focus on the work with Docker.
Fork the repository from [here](https://github.com/Developer-Akademie-GmbH/baby-tools-shop).
Now we are ready to start! 


## 2. Create Dockerfile

Make shure you go to this directiory (this is where manage.py is located): 
```sh 
cd /baby-tools-shop/babyshop_app/ 
```
...then create your Dockerfile into this directory with:
```sh
touch Dockerfile
```
...then edit your Dockerfile:
```sh

# Set up your base image
FROM python:3.10-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy all files from the current directory to the container
COPY . .

# Define build arguments - this arguments you can later give to the container within the build command. You should use environment variables for this. More to this in section (???????)
ARG PORT=8025
ARG DEFAULT_ROOT_PASSWORD
ARG DEFAULT_ROOT_USERNAME
ARG DEFAULT_ROOT_EMAIL

# Set environment variables
ENV DJANGO_PORT=$PORT
ENV DJANGO_SUPERUSER_USERNAME=$DEFAULT_ROOT_USERNAME
ENV DJANGO_SUPERUSER_EMAIL=$DEFAULT_ROOT_EMAIL
ENV DJANGO_SUPERUSER_PASSWORD=$DEFAULT_ROOT_PASSWORD

# Copy the entrypoint script to the container and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh 

# Install the required Python packages
RUN python -m pip install --no-cache-dir -r requirements.txt

# Expose the application port
EXPOSE 8025

# Set the entrypoint script to run when the container starts
ENTRYPOINT ["/entrypoint.sh"]
``` 

## 3. Generate requirements.txt - file

At first you should create the file (into the same directory as Dockerfile, manage.py):
```sh
 touch requirements.txt
```
...then type in these dependencies:

```sh
asgiref==3.8.1
Django==5.0.7
pillow==10.4.0
sqlparse==0.5.1
gunicorn
```
Write out and exit

## 4. Create entrypoint-commands 

Into the same directory, we create two more files:

#### entrypoint.sh
This script is called by the dockerfile, when you execute the "docker run" command

```sh
touch entrypoint.sh 

# type in these commands:

python manage.py migrate --noinput
python manage.py collectstatic --noinput
python create_superuser.py
exec gunicorn babyshop.wsgi:application --bind 0.0.0.0:${DJANGO_PORT}

#write out and exit
```
#### create_superuser.py
This script is called by the entrypoint.sh - script. It controls the behavior, if a superuser should be created or not (when container restards).

```sh
touch create_superuser.py 

# type in this code

import os
import django
from django.contrib.auth import get_user_model

#init django- settings
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

# write out and exit
```











