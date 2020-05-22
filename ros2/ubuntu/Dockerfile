## Provide Orocos Toolchain (RTT/OCL) on top of the official ROS 2 docker images.
ARG OROCOS_TOOLCHAIN_BRANCH=ros2
ARG ROS_DISTRO
ARG UBUNTU_DISTRO

## Stage deps: install additional Orocos Toolchain (with CORBA) dependencies
FROM ros:${ROS_DISTRO}-ros-base-${UBUNTU_DISTRO} AS deps
RUN apt-get update && apt-get install -y \
    libboost-all-dev \
    liblua5.1-0-dev \
    libncurses5-dev \
    libnetcdf-dev \
    libreadline-dev \
    libxml-xpath-perl \
    omniorb omniidl omniorb-idl omniorb-nameserver libomniorb4-dev \
    ruby ruby-facets bundler \
    && rm -rf /var/lib/apt/lists/*

## Stage build: clone and build orocos_toolchain with colcon
FROM deps AS build
ARG OROCOS_TOOLCHAIN_BRANCH
RUN git clone --recursive https://github.com/orocos-toolchain/orocos_toolchain.git -b ${OROCOS_TOOLCHAIN_BRANCH} /build/orocos_toolchain
RUN cd /build/orocos_toolchain \
    && . /opt/ros/${ROS_DISTRO}/setup.sh \
    && colcon build \
        --event-handlers console_direct+ \
        --install-base "/opt/orocos/${ROS_DISTRO}" \
        --merge-install \
        --cmake-args \
            \ -DCMAKE_BUILD_TYPE=Release \
            \ -DENABLE_CORBA=ON \
            \ -DCORBA_IMPLEMENTATION=OMNIORB

## Stage deploy: copy the install-space to /opt/orocos/${ROS_DISTRO} as a
## new image layer based on deps
FROM deps AS deploy
COPY --from=build /opt/orocos/${ROS_DISTRO} /opt/orocos/${ROS_DISTRO}

# default config file for colcon
COPY .colcon/defaults.yaml /root/.colcon/defaults.yaml

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
