# Using Flask with Docker

## Overview

This is a simple flask application with a docker file.

### Learning Objectives
- Practice deploying containerized applications
- Understand how to map ports from the Docker container to the host machine
- Use Docker Compose to simplify management of containers

### Prior Knowledge:
- Concepts of CI/CD and DevOps
- Basic knowledge of Docker usage and containerization

### Time Estimate: 8-10 minutes


## Prerequisites

You will need to have [Docker](https://docs.docker.com/engine/install/) installed.

## Running the application

### Running the container using docker commands

1. Let's first try building the image `docker build -t flaskdocker .` -- this builds an image called flaskdocker

2. Run `docker images`. You should see the flaskdocker image you just built listed

3. Let's run the container `docker run -d --name flaskdocker-container flaskdocker` This runs the image we created in step 1 in a container called flaskdocker-container. Note that the -d flag runs the container in the background.

4. Run `docker container ls` to see the running image.

5. Go to [http://127.0.0.1:6969](http://127.0.0.1:6969) or []. You will find that the application is still not running. Why is that? The application is running on port 6969 on the *docker container*, not on the host machine. We want to map the port in the docker container to some port on the host machine so let's do the following:


       a. Stop the container `docker stop flaskdocker-container`
   
       b. Remove the container `docker rm flaskdocker-container`
   
       c. re-run the container but while mapping the ports  `docker run -d --name flaskdocker-container -p 6969:6969 flaskdocker`

Now go to [http://127.0.0.1:6969](http://127.0.0.1:6969) and you should see the application!


### Running the container using docker compose

Great, but the following series of commands is a bit tedious. Instead, we can create a single `docker-compose.yml` file that describes all the containers we need to build. Running `docker compose up` will trigger building the necessary images and containers and you can even do the port mapping inside the same file.

Let's first stop and remove the container we already have running: 

    `docker stop flaskdocker-container`
    
    `docker rm flaskdocker-container`

And then we can simply call `docker compose up -d` (the -d runs it in the background)

Go to [http://127.0.0.1:6969](http://127.0.0.1:6969) and verify that the application is running.

You can stop the container by running `docker compose down`


### Running without docker

1. Install Python (this was tested with python 3.10 but in theory, any version 3.10+ should work)
2. Create virtual environment using `python -m venv .venv` (or `python3 -m venv .venv` if you don't have the python command on your machine)
3. Activate virtual environment  using `source .venv/bin/activate` (note that the bin folder may be called scripts on windows)
4. Install the dependencies `pip install -r requirements.txt`
5. Run `flask run` and then go to [http://127.0.0.1:5000](http://127.0.0.1:5000)

Use ctrl-c to stop the process and shut down the website.

Note how when you run locally, the default port is 5000 but when we ran using docker, the application became accessible at port 6969? This is because of this line `gunicorn --bind 0.0.0.0:6969 app:app` in the gunicorn_starter.sh script. 

## Relevant tutorials

1. [https://www.digitalocean.com/community/tutorials/how-to-make-a-web-application-using-flask-in-python-3](https://www.digitalocean.com/community/tutorials/how-to-make-a-web-application-using-flask-in-python-3)
2. [https://betterprogramming.pub/create-a-running-docker-container-with-gunicorn-and-flask-dcd98fddb8e0]( https://betterprogramming.pub/create-a-running-docker-container-with-gunicorn-and-flask-dcd98fddb8e0)
