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

# Open-MPI installation
ENV OPENMPI_VERSION 3.1.2
RUN mkdir /tmp/openmpi && cd /tmp/openmpi && \
    wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-${OPENMPI_VERSION}.tar.gz && \
    tar zxf openmpi-${OPENMPI_VERSION}.tar.gz && cd openmpi-${OPENMPI_VERSION} && \
    ./configure --enable-orterun-prefix-by-default && make -j $(nproc) all && \
    make install && ldconfig && rm -rf /tmp/openmpi

RUN conda install -y -c pytorch \
    cudatoolkit=10.2 \
    pytorch=1.8.1 faiss-gpu torchvision \
    && conda install -y tensorboard \
    && conda install -y scikit-learn numpy requests scipy seaborn h5py ipython faiss-gpu \
    && conda clean -ya

RUN pip install --no-cache-dir --extra-index-url https://developer.download.nvidia.com/compute/redist nvidia-dali-cuda102
RUN git clone https://github.com/NVIDIA/apex && cd apex && export TORCH_CUDA_ARCH_LIST="3.5;3.7;5.2;6.0;6.1;6.2;7.0;7.5" && \
    pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./ && cd ..
RUN pip install --no-cache-dir mmcv-full -f https://download.openmmlab.com/mmcv/dist/cu102/torch1.8.0/index.html
RUN pip install --no-cache-dir mmdet graphviz opencv-python tqdm pyyaml horovod \
    pyzmq azure-storage-blob dateparser pymoo thop addict yapf azureml azureml-sdk dgl-cu101 \
    dropblock efficientnet_pytorch mmpycocotools redis tianshou lightgbm pytorch-lightning
RUN wget -q -O azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux && \
    tar -xf azcopy.tar.gz && \
    cp azcopy_*/azcopy /usr/local/bin && \
    rm -r azcopy.tar.gz azcopy_* && \
    chmod +x /usr/local/bin/azcopy
# frequently-updated packages
RUN pip install --no-cache-dir onnxruntime onnxruntime-gpu onnx nni utilsd

WORKDIR /workspace
RUN chmod -R a+w /workspace
