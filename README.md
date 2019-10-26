# Jupyter + Tensorflow Containers with SSL and multi-platform support

This repo contains a simplified framework to deploy Jupyter notebooks to the web using SSL and Official CA Signed Certificates. It supports multiple compute modalities - CPU and NVIDIA GPU-based.


## NGINX + Letsencrypt:
In the `proxy` directory of this repository, we have a docker compose file that builds the web interface for the Jupyter application. 
- The `NGINX` container (the `proxy` service in `./proxy/docker-compose.yml`) acts as a reverse proxy for your machine. If you choose to have mutiple services running on your server, the NGINX container can accomodate this setup by routing traffic to the correct application container. For instance, if you wanted to deploy both a Jupyter application and an additional application, you could create two subdomains: `jupyter.your.domain` for users looking to use the jupyter service and `app.your.domain` for the additional service. The `NGINX` Docker container provides functionality to route user traffic to the correct service based on the subdomain they enter into their web browser. 
- The `letsencrypt-companion` container serves to generate CA-signed certificates and facitates SSL encryption on any services under the control of the `NGINX` reverse proxy container. This container does not require any user-intervention, and generated certificates are stored in a Docker volume (`certs` - see docker-compose file) so that they need not be regenerated on each deployment. Certificates do expire after about a month, so you'll need to knock down the proxy service and redeploy at least once a month to maintain the validity of your CA-certificates.
- `proxy-tier` is the network on which the `NGINX` and `letsencrypt-companion` live. This is a virtual container network. In order to use these containers, we attach any service containers we want to deploy (such as Jupyter) to the `proxy-tier` network. This allows the proxy and encryption contianers to interface with the service container.


## Jupyter:
Within the `jupyter` directory are dockerfile's specifying the build for the Jupyter + Tensorflow service- one for machines with modern NVIDIA GPUs, and one for standard CPU-based servers. There are two different docker-compose files: `docker-compose-gpu.yml` and `docker-compose-cpu.yml` and two different containers (one in the `gpu` directory and another in the `cpu` directory) for you to choose from, depending on your hardware resources.

Within each docker-compose file, under the `environment` clause, note the following lines:
```YAML
VIRTUAL_HOST: subdomain.domain.com
LETSENCRYPT_HOST: subdomain.domain.com
LETSENCRYPT_EMAIL: your@email.com
```
These lines specify which domain you'd like to attach your Jupyter instance to, and the email that letsencrypt should use to register your domain with the CA. All three lines are mandatory, so make sure you set these lines. Note that `VIRTUAL_HOST` and `LETSENCRYPT_HOST` should be identical. 

Note also that we've attached the Jupyter service to the virtual container network on which the `NGINX` and `letsencrypt-companion` live using the following 4 lines:

```YAML
# Connect to reverse proxy:
networks:
  default:
    external:
      name: proxy_proxy-tier 
```
The name of the network is now `proxy_proxy-tier` because it was generated in a directory called `proxy`. Docker compose prefixes the name of any network or container with the name of the directory in which it was created. Thus, we have an additional `proxy_` added to the name, but rest assured this is the same network as the one we've created in the `proxy` directory.
