FROM nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04

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

RUN conda install -y -c pytorch cudatoolkit=10.2 \
    pytorch=1.8 faiss-gpu torchvision tensorboard scikit-learn pandas numpy numexpr requests scipy seaborn h5py ipython \
    && conda clean -ya

RUN pip install --no-cache-dir tqdm pyyaml azure-storage-blob dateparser addict yapf azureml azureml-sdk \
    redis lightgbm
RUN wget -q -O azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux && \
    tar -xf azcopy.tar.gz && \
    cp azcopy_*/azcopy /usr/local/bin && \
    rm -r azcopy.tar.gz azcopy_* && \
    chmod +x /usr/local/bin/azcopy

RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && apt-get update && apt-get install --assume-yes blobfuse fuse && \
    rm -rf /var/lib/apt/lists/*

ARG VERSION=unknown
RUN pip install --no-cache-dir --upgrade nni tianshou utilsd

WORKDIR /workspace
RUN chmod -R a+w /workspace
