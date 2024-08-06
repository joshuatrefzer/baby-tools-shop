# Baby Tool Shop Containerization

This repository demonstrates the containerization of a Baby Tool Shop application using Docker. The goal is to run the DJANGO application inside a Docker container and make it accessible on the internet via an Nginx web server on port 8025. In case of a container failure, the container will automatically restart. Using a Docker Volume ensures data persistence, so that any new or restarted container operates with the same data, preventing data loss when a container is shut down.
This is a step by step guide for the containerization. Make sure you have set up Docker (Docker Deamon is running on your machine).

## Table of Contents

1. [Fork repository from GitHub](#1-fork-respository-from-github)
2. [Create Dockerfile](#2-create-dockerfile)
3. [Generate requirements.txt - file](#3-generate-requirementstxt---file)
4. [Create entrypoint-commands](#4-create-entrypoint-commands)
5. [Clone repository to V-Server](#5-log-in-on-your-v-server--pull-repository)
6. [Build container](#6-build-container)
7. [RuncContainer](#7-run-container)
8. [Test URL](#8-test-your-url)

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

## 5. Clone repository on V-Server
Now you have to get the code on your V-Server. Set up nginx and clone the repository from GitHub.
If you don't know these steps, you can read this in this respository about [V-Server Setup](https://github.com/joshuatrefzer/V-Server-setup).
In addition, make sure your V-Server is "docker-ready".

## 6. Build Container 
Navigate to the respository, to the directory, where your Dockerfile is located. 
Now you can run this command to build your container

> [!Warning]
> This is only to show the way it works, please read the following step, to use environment variables! 

```sh
docker build --no-cache -t babyshop --build-arg DEFAULT_ROOT_PASSWORD='yourpassword' --build-arg DEFAULT_ROOT_EMAIL='your-email@example.com' --build-arg DEFAULT_ROOT_USERNAME='your-username' -f Dockerfile .

```
> [!Important]
> To avoid hardcoding sensitive information like passwords and emails in your build command, you can use environment variables. Follow these steps:

#### 1. Create .env file
Create a .env file in the same directory as your Dockerfile and add your environment variables (This data is for the django - superuser):
```sh
DEFAULT_ROOT_PASSWORD=yourpassword
DEFAULT_ROOT_EMAIL=your-email@example.com
DEFAULT_ROOT_USERNAME=your-username
```
#### 2. Export variables
```sh 
export $(cat .env | xargs)
```

#### 3. Change your Docker - build command
```sh 
docker build --no-cache -t babyshop --build-arg DEFAULT_ROOT_PASSWORD=${DEFAULT_ROOT_PASSWORD} --build-arg DEFAULT_ROOT_EMAIL=${DEFAULT_ROOT_EMAIL} --build-arg DEFAULT_ROOT_USERNAME=${DEFAULT_ROOT_USERNAME} -f Dockerfile .
```
Now you can run this command to build your container.

Make sure it looks like that. If so, everything worked out:
![Docker-build](/readme-img/docker-build.png)


## 7. Run Container
Now we can run this container with this command:
```sh
docker run -it --restart on-failure --mount source=db_volume,target=/app  -p 8025:8025 babyshop
```
Explain the flags:

```sh
--restart on-failure #This option sets the container's restart policy. The container will only restart if it exits with a non-zero (error) status. This is useful for automatically recovering from failures.

-it #This option combines two flags:
-i # --interactive: Keeps the container's standard input (stdin) open even if not attached.
-t # or --tty: Allocates a pseudo-TTY. This allows for interactive communication with the container (similar to an SSH session).

source=db_volume #Uses the docker volume. In this case it will create one. After you stop the container and restart another with this flag, the data will be persistent.

target=/app #Specifies the directory inside the container where the volume will be mounted. This ensures data persistence between container restarts and recreations.

#combined:

--mount source=db_volume,target=/app #This option mounts a volume into the container.

-p 8025:8025 #This maps port 8025 on the host to port 8025 in the container. This allows access to the application in the container http://<your-ip-adress>:8025

babyshop #The name of the container who's running now
```

If everything worked out properly, you should see this in your console:

![Docker-run](/readme-img/docker-run.png)

## 8. Test URL
You should be able now to get the expected result on this URL in your Browser:
"http://<*your-ip-adress or localhost*>:8025" 

![Success](/readme-img/success.png)

Now your application is running inside your Docker Container and is reachable in the internet (if you did it on the V-Server with nginx). 



























