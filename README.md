# Baby Tool Shop Containerization

This repository demonstrates the containerization of a Baby Tool Shop application using Docker. The goal is to run the DJANGO application inside a Docker container and make it accessible on the internet via an Nginx web server on port 8025. In case of a container failure, the container will automatically restart. Using a Docker Volume ensures data persistence, so that any new or restarted container operates with the same data, preventing data loss when a container is shut down.
This is a step by step guide for the containerization, the Django Project is forked:

## Table of Contents

1. [Fork repository from GitHub](#1-fork-respository-from-github)
2. [Log in on Server](#2-log-in-on-server)
3. [Copy public key to server](#3-copy-public-key-to-server)
4. [Disable password login](#4-disable-password-login)
5. [Configure your server & add webserver](#5-configure-your-server--add-webserver)


## 1. Fork respository from GitHub

We don't develop the whole application, we forke it, so we can focus on the work with Docker.
Fork the repository from [here](https://github.com/Developer-Akademie-GmbH/baby-tools-shop).
Now we are ready to start! 

## 2. Open terminal an create dockerfile


