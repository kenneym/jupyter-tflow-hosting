FROM tensorflow/tensorflow:latest-gpu-py3-jupyter 

LABEL maintainer="Matthew Kenney"

# any other python packages packages here (all python 3)
RUN pip --no-cache-dir install --quiet \
    biopython \
    jupyterlab \
    pandas \
    numpy \
    sklearn \
    matplotlib \
    seaborn \
    clustalo 

    

# Override default notebook command and use lab:
CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter lab --notebook-dir=/tf --ip 0.0.0.0 --no-browser --allow-root"]
