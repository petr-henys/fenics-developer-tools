#!/bin/bash
set -e

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install -y \
     git gitk mercurial subversion meld \
     nano \
     emacs emacs-intl-fonts emacs-goodies-el \
     vim vim-gnome

sudo apt-get install -y \
     curl wget \
     build-essential \
     autoconf cmake cmake-curses-gui pkg-config \
     bison flex zlib1g-dev \
     clang gfortran \
     swig \
     ccache valgrind oprofile hwloc \
     kcachegrind alleyoop valkyrie exuberant-ctags cscope

sudo apt-get install -y \
     libboost-dev libboost-filesystem-dev \
     libboost-program-options-dev libboost-math-dev \
     libboost-system-dev libboost-iostreams-dev \
     libboost-thread-dev libboost-timer-dev

sudo apt-get install -y \
     libxml2-dev libgccxml-dev libgdbm-dev \
     libgmp-dev libcln-dev libmpfr-dev \
     liblapack-dev libpcre3-dev libopenblas-dev libeigen3-dev \
     mpich libmpich-dev libhdf5-mpich-dev

sudo apt-get install -y \
     mesa-utils \
     libxmu-dev libxi-dev freeglut3-dev libglew-dev libglm-dev \
     libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libsdl2-net-dev \
     libsdl2-mixer-dev libfreetype6-dev libtiff5-dev libpng12-dev

sudo apt-get install -y \
     python-dev python-pip python-setuptools \
     python3-dev python3-pip python3-setuptools \
     python-virtualenv python3-virtualenv virtualenv \
     python-flake8 python-ply python-six python-urllib3 \
     python-flufl.lock python-sphinx python3-flake8 python3-ply \
     python3-six python3-urllib3 python3-flufl.lock  python3-sphinx \
     python-matplotlib python-numpy  python-scipy \
     python3-matplotlib python3-numpy python3-scipy \
     cython cython3 \
     python-mode python-ropemacs \
     pylint pychecker \
     python-profiler python-wxgtk3.0

sudo apt-get install -y texlive-full pandoc biber

sudo apt-get install -y  synaptic gksu gimp vlc chromium-browser gthumb

curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt-get install git-lfs
git lfs install
