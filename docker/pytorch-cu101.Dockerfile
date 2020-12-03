FROM nvidia/cuda:10.1-devel-ubuntu18.04

# Install some basic utilities
RUN apt-get update && apt-get install -y curl ca-certificates sudo git bzip2 libx11-6 \
    libsm6 libxext6 libxrender-dev graphviz tmux htop build-essential wget cmake libgl1-mesa-glx && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda and Python 3.8
ENV CONDA_AUTO_UPDATE_CONDA=false
ENV PATH=/miniconda/bin:$PATH
RUN cd / && curl -sLo /miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py38_4.8.3-Linux-x86_64.sh \
    && chmod +x /miniconda.sh \
    && /miniconda.sh -b -p /miniconda \
    && rm /miniconda.sh \
    && conda install -y python==3.8.2 \
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
    cudatoolkit=10.1 \
    pytorch=1.7 torchvision \
    && conda install -y tensorflow-gpu tensorflow tensorboard \
    && conda install -y scikit-learn numpy requests scipy seaborn h5py ipython \
    && conda clean -ya

RUN apt update && apt install libgl1-mesa-glx -y
RUN pip install --no-cache-dir --extra-index-url https://developer.download.nvidia.com/compute/redist nvidia-dali-cuda100
RUN git clone https://github.com/NVIDIA/apex && cd apex && export TORCH_CUDA_ARCH_LIST="3.5;3.7;5.2;6.0;6.1;6.2;7.0;7.5" && \
    pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./ && cd ..
RUN pip install --no-cache-dir mmcv-full==latest+torch1.7.0+cu101 -f https://download.openmmlab.com/mmcv/dist/index.html
RUN git clone https://github.com/open-mmlab/mmdetection.git && \
    cd mmdetection && pip install -r requirements/build.txt && \
    pip install -v . && cd ..
RUN pip install --no-cache-dir graphviz opencv-python tqdm pyyaml horovod \
    pyzmq azure-storage-blob dateparser pymoo thop addict yapf azureml azureml-sdk dgl-cu101 \
    dropblock efficientnet_pytorch mmpycocotools
RUN wget -q -O azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux && \
    tar -xf azcopy.tar.gz && \
    cp azcopy_*/azcopy /usr/local/bin && \
    rm -r azcopy.tar.gz azcopy_* && \
    chmod +x /usr/local/bin/azcopy
# Dependencies of NNI
RUN pip install --no-cache-dir schema ruamel.yaml psutil astor hyperopt==0.1.2 json_tricks netifaces \
    coverage colorama pkginfo websockets
RUN pip install --no-cache-dir --no-deps nni==1.9

WORKDIR /workspace
RUN chmod -R a+w /workspace
