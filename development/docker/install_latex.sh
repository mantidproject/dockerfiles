#! /bin/bash

#Install latex direct from texlive
mkdir -p /latex
cd /latex
curl https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -O -L
zcat install-tl-unx.tar.gz | tar xf -
cd install-tl-*
perl ./install-tl --scheme=medium --no-interaction 

#Set the paths in the bashrc
echo "export PATH=/usr/local/texlive/2022/bin/x86_64-linux:$PATH" >> /root/.bashrc
echo "export MANPATH=$MANPATH:/usr/local/texlive/2022/texmf-dist/doc/man" >> /root/.bashrc
echo "export INFOPATH=$INFOPATH:/usr/local/texlive/2022/texmf-dist/doc/info" >> /root/.bashrc
