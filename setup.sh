#!/bin/bash

prog=`basename "$0" .sh`
progDir=`dirname "$0"`
echo_exec="echo +"
username=`whoami`

remote_url="https://raw.github.com/gondree/course-scripts/master"
# aka: http://goo.gl/Q2gBte


##############################################################################
#
# Parse inputs
#
VERBOSE=false

do_update=false
install_latex=false
install_programming=false
install_gnomeutils=false
install_httpd=false
install_python27=false
install_python32=false
install_utils=false
install_wine=false
install_ssh=true
install_vmwaretools=false
config_vi=false
config_gdb=false

while true; do
case "$1" in
    -v | --verbose )
        VERBOSE=true;
        shift
        ;;
    --all )
        echo "# Installing some commonly useful default stuff.";
        do_update=true
        install_programming=true
        install_python27=true
        install_utils=true
        install_ssh=true
        config_vi=true
        shift
        ;;
    --latex | --LaTeX )
        install_latex=true
        config_vi=true
        shift
        ;;
    --wine )
        install_wine=true
        shift
        ;;
    --cs3040 | --cs2140 )
        echo "# Hey -- Welcome to Low-Level Programming!";
        install_utils=true;
        install_programming=true;
        install_gnomeutils=true;
        config_vi=true;
        config_gdb=true;
        shift
        ;;
    --cs3600 )
        echo "# Hey -- Welcome to Intro to Computer Security!";
        install_utils=true;
        install_python27=true;
        install_gnomeutils=true;
        install_httpd=true;
        config_vi=true;
        shift
        ;;
    --vmware-tools )
        echo "# Gotcha -- I'll try to do vmware tools.";
        install_vmwaretools=true;
        shift
        ;;
    * ) break 
        ;;
    esac
done

# temp folder in ~/
dir="$HOME/tmp"
rm -rf "$dir"
mkdir "$dir"
if ! cd "$dir" ; then
    echo "-> Error: could not cd to \"$dir\"" >&2
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
    echo "# Updating apt-get & Upgrading all packages..."
    sudo apt-get -y --force-yes update
    sudo apt-get -y --force-yes upgrade
fi


if $install_latex ; then
    echo "# Using scottkosty's latex install scripts..."
    wget https://raw.github.com/scottkosty/install-tl-ubuntu/master/debian-control-texlive-in.txt
    wget https://raw.github.com/scottkosty/install-tl-ubuntu/master/install-tl-ubuntu
    sudo bash install-tl-ubuntu

    echo "# Installing stuff thats helpful with latex..."
    sudo apt-get -y --force-yes install \
    imagemagick \
    psutils \
    dvipng \
    gv \
    dvipost
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


if $install_programming ; then
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

if $install_httpd ; then
    echo "# Installing some httpd tools..."
    sudo apt-get -y --force-yes install \
    apache2-utils
fi

if $install_python27 ; then
    echo "# Installing various python27 packages..."
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


if $install_python32 ; then
    echo "# Installing various python32 packages..."

    ubuntu1204=$(uname -v | grep "precise")
    if [ "x"$ubuntu1204 != "x" ] ; then
        echo "# Using Ubuntu 12.04"
        echo "# Need to add depots to /etc/apt/sources.list"
        sudo tee -a /etc/apt/sources.list >/dev/null <<EOF

# python3 matplotlib 
deb http://ppa.launchpad.net/takluyver/matplotlib-daily/ubuntu  precise main 
deb-src http://ppa.launchpad.net/takluyver/matplotlib-daily/ubuntu precise main 
deb http://ppa.launchpad.net/takluyver/python3/ubuntu precise main 
deb-src http://ppa.launchpad.net/takluyver/python3/ubuntu precise main
EOF
        sudo apt-get update
    fi

    sudo apt-get -y --force-yes install \
    python3 \
    python3-dev \
    ipython3 \
    python3-numpy \
    python3-scipy \
    python3-sympy \
    python3-matplotlib

    echo "# Installing optional python packages..."
    sudo apt-get -y --force-yes install \
    ipython3-qtconsole python3-zmq python3-doc python3-tk \
    python3-setuptools python3.2-doc binfmt-support \
    python-numpy-doc python3-numpy-dbg python3-nose python3-dev \
    python-matplotlib-doc python3-cairo python3-gi python3-gobject \
    python3-pyqt4 python3-scipy python3-sip tix python3-tk-dbg
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
    sudo apt-get -y --force-yes install \
    vim

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
set tabstop=4
set nowrap                      "Don't wrap lines
set scrolloff=3                 "Start scrolling when we're near margins
syntax on

EOF
        chown "$username.$username" "$HOME/.vimrc"
    fi
fi


if $config_gdb; then
    if [ -f $HOME/.gdbinit ]; then
        echo "# Ok, partner. Leaving your .gdbinit file alone."
    else
        echo "# Setting up sensible defaults for gdb."
        cat > $HOME/.gdbinit << "EOF"
set disassembly-flavor intel

EOF
    fi
fi


##############################################################################
#
# VMWare Tools Patches
#

if $install_vmwaretools ; then
    echo "# Ok. Trying to install VMware tools..."

    if [ ! -f /tmp/VMwareTools-*.tar.gz ] && \
       [ ! -f /media/*/VMware*/VMwareTools-*.tar.gz ] && \
       [ ! -f /media/VMware*/VMwareTools-*.tar.gz ] ; then
        echo "# Select 'Install VMware Tools' from the Host GUI menu."
        echo "# Return to this screen after you have done this."
        read -p "#  Did a cdrom mount successfully? [y/N] " yn
        case $yn in
            [Yy]* ) break;;
            * ) echo "#  No? Giving up."; exit;;
        esac
    fi
    if [ -f /media/*/VMware*/VMwareTools-*.tar.gz ] ; then
        vmtools_src_tar=$(ls /media/*/VMware*/VMwareTools-*.tar.gz)
        cp "$vmtools_src_tar" /tmp
    elif [ -f /media/VMware*/VMwareTools-*.tar.gz ] ; then
        vmtools_src_tar=$(ls /media/VMware*/VMwareTools-*.tar.gz)
        cp "$vmtools_src_tar" /tmp
    else
        echo "Still can't find tools directory. Giving Up."
        exit 1
    fi
    vmtools_tar=/tmp/VMwareTools-*.tar.gz
    if [ ! -f $vmtools_tar ]; then echo "-> Error (cp)" && exit 1; fi
    #
    # Unpack tar
    cd "$dir"
    tar xzf $vmtools_tar
    if [ $? -ne 0 ]; then echo "-> Error (tar)" && exit 1; fi

    vmtools_dir=vmware-tools-distrib
    if [ ! -d $vmtools_dir ]; then
        echo "Can't find directory " $vmtools_dir
        exit 1
    fi
    #
    # Make sure kernel headers exist (may not be required, but is harmless)
    sudo apt-get -y --force-yes install \
    build-essential \
    linux-headers-$(uname -r)

    new_ver_h=/usr/src/linux-headers-$(uname -r)/include/generated/uapi/linux/version.h
    old_ver_h=/usr/src/linux-headers-$(uname -r)/include/linux/version.h
    if [ -f $old_ver_h ] ; then
         echo "#" $old_ver_h "exists already"
    elif [ -f $new_ver_h ] ; then
        sudo ln -s $new_ver_h $old_ver_h
        if [ $? -ne 0 ] ; then echo "-> Error (ln)" && exit 1; fi
    else
        echo "#" $new_ver_h "does not exist"
        echo "# so we can't link" $old_ver_h "to it"
    fi

    #--------------------------------------------------------------------------
    # Linux-3.8.x patch
    #
    linux38kernel=$(uname -r | grep "3.8.*")
    vmtools88vers=$(echo $vmtools_tar | grep "\-8.8")
    if [ "x"$linux38kernel != "x" ] && \
       [ "x"$vmtools88vers != "x" ] ; then
        echo "# Using kernel" $(uname -r) "and" $vmtools88vers
        echo "# Need to patch VMwareTools-8.8.x for 3.8.x kernel"

        # See:  https://communities.vmware.com/thread/449128?start=0&tstart=0
        #       http://ubuntuforums.org/showthread.php?t=2136277&page=2
        #       http://ubuntuforums.org/showthread.php?t=2158769&p=12746043
        # https://communities.vmware.com/servlet/JiveServlet/download/2170394-101525/vmware_884-885-90_linux-3.6.x_patcher.sh

        source_tarball=$vmtools_dir/lib/modules/source
        vmblock_patch=vmblock-only.patch
        vmhgfs_patch=vmhgfs-only.patch
        vmci_patch=vmci-only.patch
        vmsync_patch=vmsync-only.patch
        remote_patches="$remote_url"/vmware_tools/linux-3.8.x

        if [ ! -f $vmblock_patch ] ; then
            wget $remote_patches/$vmblock_patch
            if [ $? -ne 0 ]; then echo "-> Error (wget)" && exit 1; fi
        fi
        if [ ! -f $vmhgfs_patch ] ; then
            wget $remote_patches/$vmhgfs_patch
            if [ $? -ne 0 ]; then echo "-> Error (wget)" && exit 1; fi
        fi
        if [ ! -f $vmci_patch ] ; then
            wget $remote_patches/$vmci_patch
            if [ $? -ne 0 ]; then echo "-> Error (wget)" && exit 1; fi
        fi
        if [ ! -f $vmsync_patch ] ; then
            wget $remote_patches/$vmsync_patch
            if [ $? -ne 0 ]; then echo "-> Error (wget)" && exit 1; fi
        fi

        tar xf $source_tarball/vmblock.tar
        patch -p0 < $vmblock_patch
        if [ $? -ne 0 ]; then echo "-> Error (patch)" && exit 1; fi
        tar cf $source_tarball/vmblock.tar vmblock-only
        if [ $? -ne 0 ]; then echo "-> Error (tar)" && exit 1; fi

        tar xf $source_tarball/vmhgfs.tar
        patch -p0 < $vmhgfs_patch
        if [ $? -ne 0 ]; then echo "-> Error (patch)" && exit 1; fi
        tar cf $source_tarball/vmhgfs.tar vmhgfs-only
        if [ $? -ne 0 ]; then echo "-> Error (tar)" && exit 1; fi

        tar xf $source_tarball/vmci.tar
        patch -p0 < $vmci_patch
        if [ $? -ne 0 ]; then echo "-> Error (patch)" && exit 1; fi
        tar cf $source_tarball/vmci.tar vmci-only
        if [ $? -ne 0 ]; then echo "-> Error (tar)" && exit 1; fi

        tar xf $source_tarball/vmsync.tar
        patch -p0 < $vmsync_patch
        if [ $? -ne 0 ]; then echo "-> Error (patch)" && exit 1; fi
        tar cf $source_tarball/vmsync.tar vmsync-only
        if [ $? -ne 0 ]; then echo "-> Error (tar)" && exit 1; fi
    fi
    #
    # End of special cases
    #--------------------------------------------------------------------------

    echo "# Running the VMware Tools install script"
    sudo $vmtools_dir/vmware-install.pl -d
    if [ $? -ne 0 ]; then echo "-> Error (vmware-install.pl)" && exit 1; fi
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

$echo_exec rm -rf "$dir"
rm -rf "$dir"

##############################################################################
#
# Finished
#
echo "# "
echo "# All done. Restart me!"
echo "# "
