set -e

mkdir -p $HOME/.local/bin
cp ./dock $HOME/.local/bin
echo 'export PATH=$PATH:$HOME/.local/bin' >> $HOME/.bashrc

mkdir -p $HOME/.docker
cp ./dockpath $HOME/.docker
