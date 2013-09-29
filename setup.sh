#!/bin/bash

prog=`basename "$0" .sh`
progDir=`dirname "$0"`
echo="echo $prog:"
echo_exec="echo +"
echo_error="echo $prog: Error:"

##############################################################################
#
# Parse inputs
#
VERBOSE=false

do_update=false
install_ctools=false
install_gnomeutils=false
install_python=false
install_utils=false
install_wine=false
install_ssh=true
config_vi=true

while true; do
case "$1" in
    -v | --verbose )
        VERBOSE=true;
        shift
        ;;
    --cs2140 )
        echo "# Hey -- Welcome to Low-Level Programming!";
        install_utils=true;
        install_ctools=true;
        install_gnomeutils=true;
        shift
        ;;
    --cs3040 )
        echo "# Hey -- Welcome to Low-Level Programming!";
        install_utils=true;
        install_ctools=true;
        install_gnomeutils=true;
        shift
        ;;
    --cs3600 )
        echo "# Hey -- Welcome to Intro to Computer Security!";
        install_utils=true;
        install_python=true;
        install_wine=true;
        shift
        ;;
    * ) break 
        ;;
    esac
done

# temp folder in ~/
dir="$HOME/tmp"
test -d "$dir" || mkdir "$dir"
$echo_exec cd "$dir"
if ! cd "$dir" ; then
    $echo_error "Could not cd to \"$dir\"" >&2
    exit 1
fi

# Run this to go ahead and get sudo access.
echo "# Checking for sudo access... "
sudo ls >/dev/null


##############################################################################
#
# Do each install option...
#

if $do_update ; then
    echo "# Updating your packages..."
    sudo apt-get -y --force-yes update
    sudo apt-get -y --force-yes upgrade
fi


if $install_utils ; then
    echo "# Installing various utility packages..."
    sudo apt-get -y --force-yes install \
    ntfs-3g \
    ntfs-config \
    emacs \
    vim \
    preload \
    gparted \
    rar \
    unrar \
    p7zip-full \
    p7zip-rar \
    zip \
    unzip
fi


if $install_ctools ; then
    echo "# Installing various programming packages..."
    sudo apt-get -y --force-yes install \
    astyle \
    build-essential \
    binutils \
    gdb \
    valgrind \
    nasm \
    yasm \
    automake \
    libtool \
    libglut3-dev \
    libboost-dev \
    libboost-thread-dev \
    libxmu-dev \
    libxi-dev \
    linux-headers-generic \
    exuberant-ctags \
    make \
    checkinstall \
    autotools-dev \
    fakeroot \
    xutils \
    cmake \
    autoconf \
    subversion \
    subversion-tools \
    git \
    git-core \
    eclipse \
    swig
fi


if $install_wine ; then
    echo "# Installing wine..."
    sudo apt-get -y --force-yes install \
    wine
fi


if $install_python ; then
    echo "# Installing various python packages..."
    sudo apt-get -y --force-yes install \
    python2.7 \
    python-tk \
    python-gtk2-dev \
    python-setuptools \
    python-pip \
    python-numpy-dev \
    python-matplotlib \
    python-matplotlib-doc \
    python-scipy \
    libboost-python-dev
fi


if $install_gnomeutils ; then
    echo "# Installing various gnome packages..."
    sudo apt-get -y --force-yes install \
    gthumb \
    gcalctool \
    ghex \
    ddd \
    aptitude
fi


if $install_ssh; then
    echo "# Installing and starting ssh..."
    sudo apt-get -y --force-yes install \
    ssh

    if [ ! -f /var/run/sshd.pid ]; then
        echo "# Hmm, ssh is not running. I'll start it for you."
        sudo stop ssh &> /dev/null
        sudo start ssh
    fi
fi

if $config_vi; then
    sudo apt-get -y --force-yes install vim

    if [ -f $HOME/.vimrc ]; then
        echo "# Ok, partner. Leaving your .vimrc file alone."
    else 
        echo "# Setting up sensible defaults for vi."
        cat > $HOME/.vimrc << "EOF"
set nocompatible                "Must be first, since it changes other options
set number                      "Line numbers are good
set backspace=indent,eol,start  "Allow backspace in insert mode
set history=1000                "Store lots of :cmdline history
set showcmd                     "Show incomplete cmds down the bottom
set showmode                    "Show current mode down the bottom
set visualbell                  "No sounds
set autoindent
set smartindent
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set nowrap                      "Don't wrap lines
set scrolloff=3                 "Start scrolling when we're near margins
syntax on

EOF
    fi
fi


##############################################################################
#
# Cleanup
#

if true ; then
    # Clean up after the installs.
    echo "# Cleaning packages... "
    sudo apt-get -y --force-yes clean
    sudo apt-get -y --force-yes autoclean
    sudo apt-get -y --force-yes autoremove
fi

# temp dir
$echo_exec rm -rf "$dir"

##############################################################################
#
# Finished
#
echo "# "
echo "# All done. Restart me!"
echo "# "
