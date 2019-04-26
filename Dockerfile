# syntax = docker/dockerfile:experimental
# We need the previous line to use the ssh mount feature

FROM ubuntu:18.04 as base

# Prevent Qt from complaining about display, even in headless mode
# https://github.com/ariya/phantomjs/issues/14376
ENV QT_QPA_PLATFORM=offscreen

# Prevent tzdata from hanging during apt-get
# https://serverfault.com/a/683651
ENV TZ=America/Los_Angeles
RUN \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    # Use bash instead of sh
    # https://stackoverflow.com/a/25423366
    rm /bin/sh && ln -s /bin/bash /bin/sh && \
    # Set certain environmental variables for QT
    echo 'export QT_DEBUG_PLUGINS=1' >> ~/.bashrc && \
    echo 'export PATH=/V-REP_PRO_EDU_V3_5_0_Linux/:$PATH' >> ~/.bashrc

# Install pip properly
# https://askubuntu.com/a/1034113
RUN hash -d pip

COPY files/requirements.txt /requirements.txt
RUN \
    apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get install --no-install-recommends -y \
        ssh \
        x11vnc xvfb \
        tmux vim \
        gfortran python python-pip python-tk \
        mesa-common-dev libglu1-mesa-dev libglib2.0-0 libgl1-mesa-glx xcb \
        libstdc++6 \
        lua5.1 lua5.1-doc lua5.1-lgi lua5.1-lgi-dev lua5.1-policy \
        lua5.1-policy-dev liblua5.1-0 liblua5.1-0-dbg liblua5.1-0-dev \
        libdbus-1-dev libfontconfig1 libxi-dev libxrender-dev libdbus-1-3 \
        libx11-xcb-dev libxi6 \
        build-essential \
        liblua5.1-dev libboost-all-dev "^libxcb.*" && \
    # Install python dependencies
    python -m pip install --upgrade pip && \
    pip install --no-cache-dir setuptools wheel && \
    # Prevent SSL library problems in python 2
    # https://stackoverflow.com/a/29099439
    pip install --no-cache-dir 'requests[security]' && \
    # Install numpy first to prevent dependency issues with GPy and DIRECT pips
    pip install --no-cache-dir numpy && \
    pip install --no-cache-dir --ignore-installed -r requirements.txt && \
    apt-get remove -y python-pip && \
    rm -rf /var/lib/apt/lists/*

# Install vrep files
WORKDIR /vrep_files
RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y curl && \
    curl http://coppeliarobotics.com/files/V-REP_PRO_EDU_V3_5_0_Linux.tar.gz \
        | tar xvz && \
    apt-get remove -y curl && \
    rm -rf /var/lib/apt/lists/*

# Clone V-REP source code
WORKDIR /vrep_files/V-REP_PRO_EDU_V3_5_0_Linux
RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y git && \
    git clone https://github.com/CoppeliaRobotics/v_rep.git && \
    # Update programmming libraries per Coppelia
    rm -rf \
        programming/include \
        programming/common \
        programming/v_repMath && \
    git clone https://github.com/CoppeliaRobotics/include.git \
        programming/include && \
    git clone https://github.com/CoppeliaRobotics/common.git \
        programming/common && \
    git clone https://github.com/CoppeliaRobotics/v_repMath.git \
        programming/v_repMath && \
    apt-get remove -y git && \
    rm -rf /var/lib/apt/lists/*

# Install QT
WORKDIR /
# Script from https://stackoverflow.com/a/34032216
COPY files/qt-installer-noninteractive.qs /
RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y wget && \
    wget \
        http://qt.mirrors.tds.net/qt/archive/online_installers/3.1/qt-unified-linux-x64-3.1.0-online.run && \
    chmod +x qt-unified-linux-x64-3.1.0-online.run && \
    ./qt-unified-linux-x64-3.1.0-online.run --verbose \
        --platform minimal \
        --script qt-installer-noninteractive.qs && \
    rm -f qt-unified-linux-x64-3.1.0-online.run \
          qt-installer-noninteractive.qs && \
    apt-get remove -y wget && \
    rm -rf /var/lib/apt/lists/*

# Install lua libraries
WORKDIR /lua
RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y curl && \
    curl http://files.luaforge.net/releases/luabinaries/bLua5.1.4/Libraries/lua5_1_4_Linux26g4_64_lib.tar.gz \
        | tar xvz && \
    apt-get remove -y curl && \
    rm -rf /var/lib/apt/lists/*

# Patch V-REP files
# http://www.forum.coppeliarobotics.com/viewtopic.php?f=5&t=7427
WORKDIR /
RUN sed -i '1i#include <algorithm>' \
     /vrep_files/V-REP_PRO_EDU_V3_5_0_Linux/v_rep/sourceCode/interfaces/v_rep_internal.cpp
COPY files/config.pri /vrep_files/V-REP_PRO_EDU_V3_5_0_Linux/v_rep
COPY files/makefile /vrep_files/V-REP_PRO_EDU_V3_5_0_Linux/v_rep

# New stage so experimental code is separate from the V-REP base
FROM base as runtime
WORKDIR /

# Pull paper repository
RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y git && \
    git clone \
        https://github.com/tholiao/learning-morph-and-ctrl && \
    cd learning-morph-and-ctrl && \
    apt-get remove -y git && \
    rm -rf /var/lib/apt/lists/*

COPY main.sh .
RUN chmod +77 ./main.sh

CMD ./main.sh

