# ti-ccs-docker
Docker image for running Texas Insturments CCS in a docker container with X11 forwarding

# Building
`docker-compose build`

# Running
`docker-compose up`

# Adding component support
Edit docker-compose.yml and add them to the COMPONENT_LIST argument.

# Adding the CL2000 compiler
Edit docker-compose.yml and set the CL2000 argument to true.
