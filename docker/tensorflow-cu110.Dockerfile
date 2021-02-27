FROM nvidia/cuda:11.0.3-cudnn8-devel-ubuntu18.04

# Install some basic utilities
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:redislabs/redis && apt-get update && \
    apt-get install -y curl ca-certificates sudo git ssh bzip2 libx11-6 gcc iputils-ping \
    libsm6 libxext6 libxrender-dev graphviz tmux htop build-essential wget cmake libgl1-mesa-glx redis && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda and Python 3.8
ENV CONDA_AUTO_UPDATE_CONDA=false
ENV PATH=/miniconda/bin:$PATH
RUN cd / && curl -sLo /miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py38_4.8.3-Linux-x86_64.sh \
    && chmod +x /miniconda.sh \
    && /miniconda.sh -b -p /miniconda \
    && rm /miniconda.sh \
    && conda install -y python==3.8 \
    && conda clean -ya \
    && ln -s /miniconda/bin/python /usr/local/bin/python \
    && ln -s /miniconda/bin/python3 /usr/local/bin/python3

# Open-MPI installation
ENV OPENMPI_VERSION 3.1.2
RUN mkdir /tmp/openmpi && cd /tmp/openmpi && \
    wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-${OPENMPI_VERSION}.tar.gz && \
    tar zxf openmpi-${OPENMPI_VERSION}.tar.gz && cd openmpi-${OPENMPI_VERSION} && \
    ./configure --enable-orterun-prefix-by-default && make -j $(nproc) all && \
    make install && ldconfig && rm -rf /tmp/openmpi

RUN pip install --no-cache-dir tensorflow tensorflow_datasets tensorflow_probability \
    scikit-learn numpy requests scipy seaborn h5py ipython

RUN pip install --no-cache-dir graphviz opencv-python tqdm pyyaml \
    pyzmq azure-storage-blob dateparser pymoo azureml azureml-sdk
RUN HOROVOD_GPU_OPERATIONS=NCCL pip install horovod
RUN wget -q -O azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux && \
    tar -xf azcopy.tar.gz && \
    cp azcopy_*/azcopy /usr/local/bin && \
    rm -r azcopy.tar.gz azcopy_* && \
    chmod +x /usr/local/bin/azcopy
# frequently-updated packages
RUN pip install --no-cache-dir nni

WORKDIR /workspace
RUN chmod -R a+w /workspace
