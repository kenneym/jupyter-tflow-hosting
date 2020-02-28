# Choose the 'latest' image instead if you are running CUDA 10.1

FROM tensorflow/tensorflow:2.0.1-gpu-py3-jupyter
# FROM tensorflow/tensorflow:latest-gpu-py3-jupyter

# any other python packages packages here
RUN pip --no-cache-dir install --quiet \
	biopython \
    jupyterlab \
    pandas \
	numpy \
	sklearn \
	flask \ 
    matplotlib \
    seaborn \
    clustalo 

    

# Override default notebook command and use lab:
CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter lab --notebook-dir=/tf --ip 0.0.0.0 --no-browser --allow-root"]
