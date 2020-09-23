set -e

echo "Copying dock to $HOME/.local/bin"
mkdir -p $HOME/.local/bin
cp ./dock $HOME/.local/bin
echo 'export PATH=$PATH:$HOME/.local/bin' >> $HOME/.bashrc

echo "Copying config file to $HOME/.docker"
mkdir -p $HOME/.docker
cp ./dockpath $HOME/.docker
echo "Done"
