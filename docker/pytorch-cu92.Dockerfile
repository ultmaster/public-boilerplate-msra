
FROM nvidia/cuda:9.2-devel-ubuntu18.04

# Install some basic utilities
RUN apt-get update && apt-get install -y curl ca-certificates sudo git bzip2 libx11-6 \
    libsm6 libxext6 libxrender-dev graphviz tmux htop build-essential wget && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda and Python 3.7
ENV CONDA_AUTO_UPDATE_CONDA=false
ENV PATH=/root/miniconda/bin:$PATH
RUN curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py37_4.8.2-Linux-x86_64.sh \
    && chmod +x ~/miniconda.sh \
    && ~/miniconda.sh -b -p ~/miniconda \
    && rm ~/miniconda.sh \
    && conda install -y python==3.7.3 \
    && conda clean -ya

# CUDA 9.2-specific steps
RUN conda install -y -c pytorch \
    cudatoolkit=9.2 \
    "pytorch=1.5.1=py3.7_cuda9.2.148_cudnn7.6.3_0" \
    "torchvision=0.6.1=py37_cu92" \
    && conda clean -ya

RUN pip install --no-cache-dir --extra-index-url https://developer.download.nvidia.com/compute/redist/cuda/9.0 nvidia-dali
RUN pip install --no-cache-dir tensorboard graphviz opencv-python tqdm pyyaml h5py tensorboardx scikit-learn scipy \
    pyzmq seaborn azure-storage-blob dateparser pymoo thop addict ipython yapf
RUN wget -q -O azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux && \
    tar -xf azcopy.tar.gz && \
    cp azcopy_*/azcopy /usr/local/bin && \
    rm -r azcopy.tar.gz azcopy_* && \
    chmod +x /usr/local/bin/azcopy
# Dependencies of NNI
RUN pip install --no-cache-dir schema ruamel.yaml psutil requests astor hyperopt==0.1.2 json_tricks netifaces numpy \
    coverage colorama scikit-learn pkginfo websockets
RUN pip install --no-cache-dir --no-deps nni==1.6

WORKDIR /workspace
RUN chmod -R a+w /workspace
