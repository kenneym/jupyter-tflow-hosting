# Jupyter + Tensorflow Containers with SSL and multi-platform support

This repo contains a simplified framework to deploy Jupyter notebooks to the web using SSL and Official CA Signed Certificates. It supports multiple compute modalities - CPU and NVIDIA GPU-based.


## NGINX + Letsencrypt:
In the `proxy` directory of this repository, we have a docker compose file that builds the web interface for the Jupyter application. 

- The `NGINX` container (the `proxy` service in `./proxy/docker-compose.yml`) acts as a reverse proxy for your machine. If you choose to have mutiple services running on your server, the NGINX container can accomodate this setup by routing traffic to the correct application container. For instance, if you wanted to deploy both a Jupyter application and an additional application, you could create two subdomains: `jupyter.your.domain` for users looking to use the jupyter service and `app.your.domain` for the additional service. The `NGINX` Docker container provides functionality to route user traffic to the correct service based on the subdomain or full domain they enter into their web browser. 

- The `letsencrypt-companion` container serves to generate CA-signed certificates and facitates SSL encryption on any services under the control of the `NGINX` reverse proxy container. This container does not require any user-intervention, and generated certificates are stored in a Docker volume (`certs` - see docker-compose file) so that they need not be regenerated on each deployment. Certificates do expire after about a month, so you'll need to knock down the proxy service and redeploy at least once a month to maintain the validity of your CA-certificates.

- `proxy-tier` is the network on which the `NGINX` and `letsencrypt-companion` live. This is a virtual container network. In order to use these containers, we attach any service containers we want to deploy (such as Jupyter) to the `proxy-tier` network. This allows the proxy and encryption contianers to interface with the service container.


## Jupyter:
Within the `jupyter` directory are Dockerfile's specifying the build for the Jupyter + Tensorflow service- one for machines with modern NVIDIA GPUs, and one for standard CPU-based servers. There are two different docker-compose files: `docker-compose-gpu.yml` and `docker-compose-cpu.yml` and two different containers (one in the `gpu` directory and another in the `cpu` directory) for you to choose from, depending on your hardware resources.


### Network Configuration:

Within each docker-compose file, under the `environment` clause, note the following lines:
```YAML
VIRTUAL_HOST: subdomain.domain.com
LETSENCRYPT_HOST: subdomain.domain.com
LETSENCRYPT_EMAIL: your@email.com
```
These lines specify which domain you'd like to attach your Jupyter instance to, and the email that letsencrypt should use to register your domain with the CA. All three lines are mandatory, so make sure you set these lines. Note that `VIRTUAL_HOST` and `LETSENCRYPT_HOST` should be identical. If you are only hosting one service, or if you are hosting multiple services on different domain names, you do not need to specify a subdomain.

Note also that we've attached the Jupyter service to the virtual container network on which the `NGINX` and `letsencrypt-companion` live using the following 4 lines:

```YAML
# Connect to reverse proxy:
networks:
  default:
    external:
      name: proxy_proxy-tier 
```
The name of the network is now `proxy_proxy-tier` because it was generated in a directory called `proxy`. Docker compose prefixes the name of any network or container with the name of the directory in which it was created. Thus, we have an additional `proxy_` added to the name, but rest assured this is the same network as the one we've created in the `proxy` directory.

**Note that, once you have a single NGINX and letsencrypt companion container running, you can attach nearly any webservice to this proxy and letsencrypt will autogenerate certificates for that service. All you need to do is create a docker compose file listing the app you want to run, the environmental variables that tell `NGINX` which domain to point your service to, and the `networks` section you see above.**


### Saving Your Work:
In order to save the notebooks locally on your machine, we bind mount the notebooks created in the Docker container to a host directory:

```YAML
volumes:
  - "/your/local/directory:/tf/notebooks" # For GPU
```
make sure to set this local directory before running the service.


## Running the Service:
In order to get the Tensorflow + Jupyter container up-and-running, follow this simple step-by-step:

**NOTE**: You'll need to have `nvidia-docker` up and running in order to use the GPU container.

1. Get the NGINX proxy service and the `letsencrypt` listener running by simply navigating to the `./proxy` directory and simply running `docker-compose up`. Once it's clear that the service is finished setting up, feel free to detach the service with `CTRL Z`.
2. Next, navigate to the `./jupyter` directory, and run `docker-compose -f docker-compose-gpu.yml up` or `docker-compose -f docker-compose-cpu.yml up`, depending on your hardware resources. The first time you bring up the service, `letsencrypt` will generate valid CA certificates for the domain hosting your jupyter lab service. This process takes time, so you may need to wait a few minutes before accessing the service.
3. Once `letsencrypt` has finished, navigate to the domain hosting your Jupyter service with any web browser. When letsencrypt is finished, the docker compose output should leave you with a jupyter webpage that you can access with a token at the end of the URL, such as 'token=124898329084adsfa12l'. Ignore the rest of the URL, but copy just the token number from your terminal
4. Now, in your web browser, set the password for your Jupyter Lab instance by pasting in the token at the bottom of the page and setting a new password. 
5. Now, you can feel free to use your jupyter service whenever you like, and can knock the service down or up without worry. The password you set, any configuration you make to the jupyter container while its running, and any python packages will be saved via docker volumes attached to the instance. If you, do, for any reason, want to rebuild the container from scratch and destroy any configuration or passwords stored in the docker volumes, simply `docker compose build -f docker-compose-gpu.yml` or the equivalent for the CPU version. After rebuilding, everything will be set back to default.


### Installing Packages:
To install additional python packages, simply open up either jupyter Dockerfile, and add additional python packages to the pip install at the end.

### Setting CUDA Version (GPU version):
In the GPU docker container, we pull the CUDA 10 version of Tensorflow - Tensorflow 2.0.1. If you happen to be running CUDA 10.1, change the `FROM` image in the GPU Jupyter Dockerfile to ``tensorflow/tensorflow:latest-gpu-py3-jupyter`. 
