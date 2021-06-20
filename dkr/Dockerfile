
FROM ubuntu:bionic

# cd ~/dkr && docker build -t steem .
# docker run -p 0.0.0.0:2001:2001 -v $PWD/data:/steem -d -t steem


RUN apt-get update && \
    apt-get install -y gcc g++ cmake make libbz2-dev libdb++-dev libdb-dev && \
    apt-get install -y libssl-dev openssl libreadline-dev autoconf libtool git gdb liblz4-tool wget jq virtualenv libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev && \
    apt-get install -y autotools-dev build-essential libbz2-dev libicu-dev python-dev wget doxygen python3 python3-dev python3-pip libboost-all-dev curl && \
    apt-get clean -qy

RUN pip3 install jinja2

###
# Overridable build arguments
# Can override during docker build using '--build-arg' like so:
#
#   docker build --build-arg "ENABLE_MIRA=OFF" --build-arg="STEEM_STATIC_BUILD=OFF" -t steem
#
###

ARG steemd_version=master
ENV steemd_version ${steemd_version}

ARG STEEM_SOURCE="https://gitlab.syncad.com/hive/hive.git"
ENV STEEM_SOURCE ${STEEM_SOURCE}

ARG HIVE_STATIC_BUILD=ON
ENV HIVE_STATIC_BUILD ${HIVE_STATIC_BUILD}

#ARG ENABLE_MIRA=ON
#ENV ENABLE_MIRA ${ENABLE_MIRA}

ARG LOW_MEMORY_MODE=ON
ENV LOW_MEMORY_MODE ${LOW_MEMORY_MODE}

ARG CLEAR_VOTES=ON
ENV CLEAR_VOTES ${CLEAR_VOTES}

ARG BUILD_HIVE_TESTNET=OFF
ENV BUILD_HIVE_TESTNET ${BUILD_HIVE_TESTNET}

ARG ENABLE_STD_ALLOCATOR_SUPPORT=ON
ENV ENABLE_STD_ALLOCATOR_SUPPORT ${ENABLE_STD_ALLOCATOR_SUPPORT}

ARG SKIP_BY_TX_ID=ON
ENV SKIP_BY_TX_ID ${SKIP_BY_TX_ID}

ARG CMAKE_BUILD_TYPE=Release
ENV CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE}


RUN cd ~ && \
    echo " >>> Cloning tag/branch ${steemd_version} from repo: ${STEEM_SOURCE}" && \
	git clone ${STEEM_SOURCE} steem -b ${steemd_version} && \
	cd steem && \
	git submodule update --init --recursive && \
        cd ~/steem && \
	cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} . \
            -DLOW_MEMORY_NODE=${LOW_MEMORY_MODE} \
            -DCLEAR_VOTES=${CLEAR_VOTES} \
            -DHIVE_STATIC_BUILD=${HIVE_STATIC_BUILD} \
            -DSKIP_BY_TX_ID=${SKIP_BY_TX_ID} \
            -DBUILD_HIVE_TESTNET=${BUILD_HIVE_TESTNET} \
            # -DENABLE_MIRA=${ENABLE_MIRA} \
            -DENABLE_STD_ALLOCATOR_SUPPORT=${ENABLE_STD_ALLOCATOR_SUPPORT} && \
	make -j$(nproc) && make install && rm -rf ~/steem

VOLUME /steem
WORKDIR /steem

# P2P (seed) port
EXPOSE 2001
# RPC ports
EXPOSE 5000
EXPOSE 8090
EXPOSE 8091

ARG STEEMD_BIN="hived"
ENV STEEMD_BIN ${STEEMD_BIN}

RUN echo "This container has been built with the following options:" >> /steem_build.txt && \
    echo "----" >> /steem_build.txt && \
    echo "Git Repository:              ${STEEM_SOURCE}" >> /steem_build.txt && \
    echo "Git version/commit:          ${steemd_version}\n----" >> /steem_build.txt && \
    echo "Default steemd executable:   ${STEEMD_BIN}\n---" >> /steem_build.txt && \
    echo "--- CMake Config Options ---" >> /steem_build.txt && \
    echo "LOW_MEMORY_MODE=${LOW_MEMORY_MODE}\nHIVE_STATIC_BUILD=${HIVE_STATIC_BUILD}" >> /steem_build.txt && \
    echo "SKIP_BY_TX_ID=${SKIP_BY_TX_ID}\nENABLE_MIRA=${ENABLE_MIRA}\nCLEAR_VOTES=${CLEAR_VOTES}" >> /steem_build.txt && \
    echo "BUILD_HIVE_TESTNET=${BUILD_HIVE_TESTNET}\nENABLE_STD_ALLOCATOR_SUPPORT=${ENABLE_STD_ALLOCATOR_SUPPORT}" && \
    echo "----\nBuilt at: $(date)\n----" >> /steem_build.txt

RUN echo "Please configure me! You need to mount a data directory onto /steem of this container to it to function correctly. (if you're using Steem-in-a-box most of this is handled automatically)"
CMD ["sh", "-c", "${STEEMD_BIN}"]


