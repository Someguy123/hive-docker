
FROM phusion/baseimage:jammy-1.0.1

RUN apt-get update && \
    apt-get install -y \
    autoconf \
    automake \
    autotools-dev \
    bsdmainutils \
    build-essential \
    ca-certificates \
    clang \
    clang-tidy \
    cmake \
    curl \
    doxygen \
    g++ \
    gdb \
    git \
    gir1.2-glib-2.0 \
    jq \
    libboost-all-dev \
    libbz2-dev \
    liblz4-dev \
    liblz4-tool \
    libncurses5-dev \
    libreadline-dev \
    libsnappy-dev \
    libssl-dev \
    libtool \
    liburing-dev \
    libxml2 \
    libyajl-dev \
    libzstd-dev \
    make \
    nano \
    ncurses-dev \
    net-tools \
    ninja-build \
    perl \
    pkg-config \
    python3 \
    python3-dev \
    python3-jinja2 \
    python3-pip \
    python3-pkg-resources \
    shared-mime-info \
    tzdata \
    virtualenv \
    wget \
    xdg-user-dirs \
    xxd \
    zlib1g-dev \
    zopfli && \
    apt-get clean -qy

ARG hived_version=master
ENV hived_version ${hived_version}

ARG HIVE_SOURCE="https://github.com/openhive-network/hive.git"
ENV HIVE_SOURCE ${HIVE_SOURCE}

ARG BUILD_HIVE_TESTNET=OFF
ENV BUILD_HIVE_TESTNET ${BUILD_HIVE_TESTNET}

ARG CMAKE_BUILD_TYPE=Release
ENV CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE}

RUN cd ~ && \
    echo " >>> Cloning tag/branch ${hived_version} from repo: ${HIVE_SOURCE}" && \
	git clone ${HIVE_SOURCE} hive && \
	cd hive && \
	git checkout ${hived_version} && \
	git submodule update --init --recursive && \
        cd ~/hive && \
	cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} . \
            -DBUILD_HIVE_TESTNET=${BUILD_HIVE_TESTNET} -G Ninja && \
	ninja && ninja install && rm -rf ~/hive

VOLUME /hive
WORKDIR /hive

# P2P (seed) port
EXPOSE 2001
# RPC ports
EXPOSE 5000
EXPOSE 8090
EXPOSE 8091

ARG HIVED_BIN="hived"
ENV HIVED_BIN ${HIVED_BIN}

RUN echo "This container has been built with the following options:" >> /hive_build.txt && \
    echo "----" >> /hive_build.txt && \
    echo "Git Repository:              ${HIVE_SOURCE}" >> /hive_build.txt && \
    echo "Git version/commit:          ${hived_version}\n----" >> /hive_build.txt && \
    echo "Default hived executable:   ${HIVED_BIN}\n---" >> /hive_build.txt && \
    echo "--- CMake Config Options ---" >> /hive_build.txt && \
    echo "BUILD_HIVE_TESTNET=${BUILD_HIVE_TESTNET}" && \
    echo "----\nBuilt at: $(date)\n----" >> /hive_build.txt

RUN echo "Please configure me! You need to mount a data directory onto /hive of this container to it to function correctly."
CMD ["sh", "-c", "${HIVED_BIN}"]


