# Learning Morphology and Control for a Microrobot
This repository contains files neccessary to replicate the Docker image used to
run experiments for the paper "Learning Morphology and Control for a
Microrobot". More information can be found on our website
[here](https://sites.google.com/view/learning-robot-morphology/). 

## Building the docker image
Before building the docker image, ensure that docker is
[installed](https://docs.docker.com/install/). 
The following steps are neccessary to build the docker image. 
```
docker build --no-cache -t learning-robot-morph .
```
This dockerfile has been tested on Ubuntu 18.04. 

## Running the docker image
Run 
```
docker run -it --rm learning-robot-morph
```

If you modify `main.sh`, you can rebuild from just the runtime stage
```
docker build --target runtime -t learning-robot-morph .
```

## Citation

Should you find this code useful, please support us by citing our paper:
```
T. Liao, G. Wang, B. Yang, R. Lee, S. Levine, K. Pister, R. Calandra. 
Data-efficient Learning of Morphology and Controller for a Microrobot.
In IEEE Int. Conf on Robotics and Automatation, ICRA '19, Montreal, Canada, May
2019. 
```
