FROM anibali/pytorch:1.5.0-cuda9.2-ubuntu18.04
USER root

RUN apt update && apt install -y libsm6 libxext6 libxrender-dev graphviz tmux htop build-essential wget
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
