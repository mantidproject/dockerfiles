#! /bin/bash

#Install latex direct from texlive
mkdir -p /latex
cd /latex
curl https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -O -L
zcat install-tl-unx.tar.gz | tar xf -
cd install-tl-*
perl ./install-tl --scheme=medium --no-interaction