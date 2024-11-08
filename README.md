# Baby Tool Shop Containerization

This repository demonstrates the containerization of the Baby Tool Shop application using Docker. The goal is to run the Django application within a Docker container, making it accessible on the internet via port `8025`. The container is set to restart automatically in case of failure, ensuring high availability. A Docker Volume is used for data persistence, so that even newly started or restarted containers maintain the same data, preventing data loss on shutdown.

## Prerequisites

- Ensure Docker is installed and the Docker daemon is running.
- Python is installed on your machine.

## Table of Contents

- [Baby Tool Shop Containerization](#baby-tool-shop-containerization)
  - [Prerequisites](#prerequisites)
- [Quickstart](#quickstart)
  - [Table of Contents](#table-of-contents)
- [Quickstart](#quickstart)
  - [Clone Repository](#clone-repository)
  - [Install Dependencies](#install-dependencies)
  - [Manage Credentials](#manage-credentials)
  - [Build Container](#build-container)
  - [Run Container](#run-container)
  - [Create Superuser](#create-superuser)
  - [Test Application](#test-application)
- [Details](#details)
  - [Dockerfile](#dockerfile)
  - [create\_superuser.py](#create_superuserpy)
  - [Docker Flag- Explanation](#docker-flag--explanation)

# Quickstart

This is a instruction to use this repository on your machine. 

## Clone Repository

Clone this repository and make sure Docker is installed an is running on your machine.
```sh
    git clone git@github.com:joshuatrefzer/baby-tools-shop.git
```

## Install Dependencies

Navigate into the project directory and use the following command to install dependencies: 
```sh
pip install -r requirements.txt
```

## Manage Credentials 
Create a .docker-env file in the root directory (where the Dockerfile is located) to store environment variables required for creating a Django superuser:

```sh
DEFAULT_ROOT_PASSWORD="yourpassword"
DEFAULT_ROOT_EMAIL="your-email@example.com"
DEFAULT_ROOT_USERNAME="your-username"
```

> [!WARNING]  
> Ensure .docker-env or any file with sensitive data is listed in .gitignore to prevent accidentally pushing it to GitHub.le in the .gitignore - file, to prevent pushing sinsitive data to GitHub!


## Build Container 
Make shure you are in the respository's root directory, where the Dockerfile is located.
Use the following command to build a new container.

```sh
docker build -t babyshop -f Dockerfile .
```

## Run Container
Now we can run this container with this command:
```sh
docker run -it --restart on-failure  \
    --mount source=db_volume,target=/app \
    --env-file .docker-env \
    -p 8025:8025 \
    babyshop
```

## Create Superuser
To create a Django superuser, first get the container ID:

```sh
    docker ps 
```
Then, use the container ID to access the container and create the superuser:

```sh
    docker exec -it <container_id> sh 
    python create_superuser.py 
```

## Test Application

You should be able now to get the expected result on this URL in your Browser:
"http://<*your-ip-adress or localhost*>:8025" 

![Success](/readme-img/success.png)

Now your application is running inside your Docker Container and is reachable in the internet.


# Details

This is a section....

## Dockerfile

```sh
# Use the official Python 3.10 image with Alpine Linux, which is lightweight and efficient for deployments.
FROM python:3.10-alpine

# Set the working directory inside the container to /app.
# All subsequent commands will run relative to this directory.
WORKDIR /app

# Copy all files from the local directory (where Dockerfile is located) to the /app directory in the container.
COPY . $WORKDIR

# Install the Python dependencies listed in the requirements.txt file.
# The `--no-cache-dir` option reduces image size by not caching package files.
RUN python -m pip install --no-cache-dir -r requirements.txt

# Set the working directory to /app/babyshop_app for subsequent commands, where Django app commands will be executed.
WORKDIR /app/babyshop_app

# Run Django database migrations to apply any database schema changes,
# and collect static files (such as CSS, JavaScript) into a single location for production use.
RUN python manage.py migrate --noinput && \
    python manage.py collectstatic --noinput 

# Expose port 8025 to allow external access to this port in the container.
EXPOSE 8025

# Define the entry point for the container as Gunicorn, a Python WSGI HTTP server for serving the Django app.
# Bind Gunicorn to port 8025 on all network interfaces, making the app accessible externally.
ENTRYPOINT ["gunicorn", "babyshop.wsgi:application", "--bind", "0.0.0.0:8025"]

```

## create_superuser.py
- The script initializes Django settings, connects to the user model, and checks if a superuser exists.

- If no superuser exists, it tries to retrieve superuser credentials from environment variables.

- If credentials are available, a new superuser is created; otherwise, it prints a message and exits.

```sh
import os
import django
from django.contrib.auth import get_user_model

# Initialize Django settings by specifying the settings module for Django to use.
# This connects the script to the Django project’s configuration, making the models and settings available.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'babyshop.settings')
django.setup()

def create_superuser():
    # Get the User model defined in the Django project, which may be a custom user model.
    User = get_user_model()

    # Check if there is already a superuser in the database.
    # If not, proceed with creating a new one.
    if not User.objects.filter(is_superuser=True).exists():
        print("No superuser found. Creating a new superuser...")

        # Retrieve superuser credentials from environment variables.
        # These are expected to be set in the environment where this script runs.
        username = os.environ.get('DJANGO_SUPERUSER_USERNAME')
        email = os.environ.get('DJANGO_SUPERUSER_EMAIL')
        password = os.environ.get('DJANGO_SUPERUSER_PASSWORD')

        # If any of the credentials are missing, print a message and skip creating the superuser.
        if not username or not email or not password:
            print("Superuser credentials not provided in environment variables. Skipping superuser creation.")
            return

        # Create the superuser using the provided credentials.
        User.objects.create_superuser(username=username, email=email, password=password)
    else:
        # If a superuser already exists, print a message and do not create a new one.
        print("Superuser already exists. Skipping superuser creation.")

# Run the create_superuser function when the script is executed directly.
if __name__ == '__main__':
    create_superuser()
```

## Docker Flag- Explanation

| Flag                            | Explanation                                                                                                                                                                                                                  |
|---------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `--restart on-failure`          | Sets the container's restart policy to restart only if it exits with a non-zero (error) status. Useful for automatically recovering from failures.                                                                         |
| `-it`                           | Combines two flags (`-i` and `-t`) to keep standard input open and allocate a pseudo-TTY. Enables interactive communication with the container (similar to SSH).                                                           |
| `-i` or `--interactive`         | Keeps the container’s standard input (stdin) open, even if not attached.                                                                                                                                                    |
| `-t` or `--tty`                 | Allocates a pseudo-TTY, allowing for interactive communication with the container.                                                                                                                                           |
| `source=db_volume`              | Specifies the source as a Docker volume. Creates the volume if it doesn’t exist. Data persists even if the container stops, enabling data retention for future containers with the same volume.                            |
| `--env-file .docker-env`        | Loads environment variables from the `.docker-env` file, making them available inside the container.                                                                                                                        |
| `target=/app`                   | Specifies the target directory in the container where the volume will mount, ensuring data persistence across container restarts and recreations.                                                                           |
| `--mount source=db_volume,target=/app` | Mounts the specified volume (`db_volume`) to the target directory (`/app`) inside the container, enabling persistent data storage.                                                                                |
| `-p 8025:8025`                  | Maps port 8025 on the host to port 8025 in the container, allowing access to the application from `http://<your-ip-address>:8025`.                                                                                          |
| `babyshop`                      | The name assigned to the running container, in this case, `babyshop`.                                                                                                                                                       |






















