# prepare zsh
sudo apt update
sudo apt install -y zsh curl wget git
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# add plugins=(zsh-autosuggestions) in .zshrc
# copy conda init from .bashrc to .zshrc

# prepare conda
wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
sh Miniconda3-latest-Linux-x86_64.sh

# prepare python
conda create -n nnidev python=3.7
sudo apt install -y libsm6 libxext6 libxrender-dev graphviz tmux htop
conda activate nnidev
conda install tensorboard graphviz tqdm pyyaml h5py scikit-learn scipy pyzmq autopep8 pylint jupyter seaborn
conda install -c pytorch pytorch torchvision cudatoolkit=10.1 cudnn
wget -q -O azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy.tar.gz && \
    sudo cp azcopy_*/azcopy /usr/bin && rm -r azcopy.tar.gz azcopy_*
pip install --no-cache-dir tensorflow nni
pip install -U --no-cache-dir grpcio
pip install -U "git+https://github.com/Microsoft/pai@master#egg=openpaisdk&subdirectory=contrib/python-sdk"

# vscode
# extensions: python gitlens
# settings
# {
#     "terminal.integrated.shell.linux": "/usr/bin/zsh",
#     "python.formatting.autopep8Args": [
#         "--max-line-length",
#         "140"
#     ]
# }

# ssh keygen
ssh-keygen
cat ~/.ssh/id_rsa.pub

# git
git config --global user.name "Yuge Zhang"
git config --global user.email "scottyugochang@gmail.com"
