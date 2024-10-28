# Baby Tool Shop Containerization

This repository demonstrates the containerization of a Baby Tool Shop application using Docker. The goal is to run the DJANGO application inside a Docker container and make it accessible on the internet via an Nginx web server on port 8025. In case of a container failure, the container will automatically restart. Using a Docker Volume ensures data persistence, so that any new or restarted container operates with the same data, preventing data loss when a container is shut down.
This is a step by step guide for the containerization. Make sure you have set up Docker (Docker Deamon is running on your machine).

## Table of Contents

1. [Fork repository from GitHub](#1-fork-respository-from-github)
2. [Create Dockerfile](#2-create-dockerfile)
3. [Generate requirements.txt - file](#3-generate-requirementstxt---file)
4. [create_superuser.py](#4-create-file-create_superuserpy)
5. [Build container](#6-build-container)
6. [Run container](#7-run-container)
7. [Docker-Exec](#7-docker-exec)
7. [Test URL](#8-test-your-url)

## 1. Fork respository from GitHub

To focus on working with Docker, the entire application is not developed from scratch. Instead, the repository is forked. The repository can be forked from [here](https://github.com/Developer-Akademie-GmbH/baby-tools-shop). Now everything is ready to start!


## 2. Create Dockerfile

Make shure you go to the root directiory: 
```sh 
cd /baby-tools-shop 
```
Create your Dockerfile into this directory with:
```sh
touch Dockerfile
```
Edit your Dockerfile:
```sh

FROM python:3.10-alpine

WORKDIR /app

COPY . .

RUN python -m pip install --no-cache-dir -r requirements.txt

WORKDIR /app/babyshop_app

RUN python manage.py migrate --noinput && \
    python manage.py collectstatic --noinput 

EXPOSE 8025

ENTRYPOINT ["gunicorn", "babyshop.wsgi:application", "--bind", "0.0.0.0:8025"]
``` 

## 3. Generate requirements.txt - file

At first, create the file (into the same directory as Dockerfile):
```sh
 touch requirements.txt
```
Type in these dependencies:

```sh
asgiref==3.8.1
Django==5.0.7
pillow==10.4.0
sqlparse==0.5.1
gunicorn
```
Write out and exit

## 4. Create file "create_superuser.py" 

Now go to one directory deeper.

```sh
cd /babyshop_app
```

#### create_superuser.py
This script is called by the dockerfile. It controls the behavior, if a superuser should be created or not (when container restards).

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

#### Create .docker-env file
Create a .docker-env file in the same directory as your Dockerfile and add your environment variables (This data is for the django - superuser):
```sh
DEFAULT_ROOT_PASSWORD=yourpassword
DEFAULT_ROOT_EMAIL=your-email@example.com
DEFAULT_ROOT_USERNAME=your-username
```

## 5. Build Container 
Navigate to the respository, to the directory, where your Dockerfile is located. 
Now you can run this command to build your container

```sh
docker build -t babyshop -f Dockerfile .
```

## 6. Run Container
Now we can run this container with this command:
```sh
docker run -it --restart on-failure  \
    --mount source=db_volume,target=/app \
    --env-file .docker-env \
    -p 8025:8025 \
    babyshop
```
Explain the flags:

```sh
--restart on-failure #This option sets the container's restart policy. The container will only restart if it exits with a non-zero (error) status. This is useful for automatically recovering from failures.

-it #This option combines two flags:
-i # --interactive: Keeps the container's standard input (stdin) open even if not attached.
-t # or --tty: Allocates a pseudo-TTY. This allows for interactive communication with the container (similar to an SSH session).

source=db_volume #Uses the docker volume. In this case it will create one. After you stop the container and restart another with this flag, the data will be persistent.

--env-file .docker-env #takes the docker-env file's variables as environment variables for inside the container.

target=/app #Specifies the directory inside the container where the volume will be mounted. This ensures data persistence between container restarts and recreations.

#combined:

--mount source=db_volume,target=/app #This option mounts a volume into the container.

-p 8025:8025 #This maps port 8025 on the host to port 8025 in the container. This allows access to the application in the container http://<your-ip-adress>:8025

babyshop #The name of the container who's running now
```

If everything worked out properly, you should see this in your console:

![Docker-run](/readme-img/docker-run.png)

## 7. Docker Exec 
Use the following command in your shell to get the id of your running container:

```sh
    docker ps 
```
Copy the container id and use the following command to get inside the started container and start the script to handle creation of superuser.

```sh
    docker exec -it containerid sh
    python create_superuser.py 
```

## 8. Test URL
You should be able now to get the expected result on this URL in your Browser:
"http://<*your-ip-adress or localhost*>:8025" 

![Success](/readme-img/success.png)

Now your application is running inside your Docker Container and is reachable in the internet (if you did it on the V-Server with nginx). 



























