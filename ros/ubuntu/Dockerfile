## Provide Orocos Toolchain (RTT/OCL) on top of the official ROS docker images.
ARG OROCOS_TOOLCHAIN_BRANCH=toolchain-2.9
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
    libxml2-dev \
    libeigen3-dev \
    sip-dev \
    libbullet-dev \
    libangles-dev \
    omniorb omniidl omniorb-idl omniorb-nameserver libomniorb4-dev \
    ruby bundler \
    $([[ "$UBUNTU_DISTRO" != "focal" ]] && echo "ruby-facets") \
    && rm -rf /var/lib/apt/lists/*

## Stage build: clone and build orocos_toolchain with colcon
FROM deps AS build
ARG OROCOS_TOOLCHAIN_BRANCH
RUN git clone --recursive https://github.com/orocos-toolchain/orocos_toolchain.git -b ${OROCOS_TOOLCHAIN_BRANCH} /build/orocos_ws/src/orocos_toolchain \
    && git clone --recursive https://github.com/orocos/orocos_kinematics_dynamics.git -b v1.4.0 /build/orocos_ws/src/orocos_kinematics_dynamics
RUN cd /build/orocos_ws \
    && . /opt/ros/${ROS_DISTRO}/setup.sh \
    && DESTDIR=/stage \
        OROCOS_TARGET=gnulinux \
        catkin_make_isolated \
        --install \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_FIND_ROOT_PATH=/stage \
            -DCATKIN_DEVEL_PREFIX=/build/orocos_ws/devel \
            -DCMAKE_INSTALL_PREFIX=/opt/ros/${ROS_DISTRO} \
            -DENABLE_CORBA=ON \
            -DCORBA_IMPLEMENTATION=OMNIORB \
            -DOROCOS_INSTALL_INTO_PREFIX_ROOT=ON

RUN git clone --recursive https://github.com/orocos/rtt_ros_integration.git -b ${OROCOS_TOOLCHAIN_BRANCH} /build/orocos_underlay_ws/src/rtt_ros_integration \
    && git clone --recursive https://github.com/ros/geometry2.git -b ${ROS_DISTRO}-devel /build/orocos_underlay_ws/src/geometry2 \
    && git clone --recursive https://github.com/ros/geometry.git -b ${ROS_DISTRO}-devel /build/orocos_underlay_ws/src/geometry \
    && git clone --recursive https://github.com/ros/angles.git -b master /build/orocos_underlay_ws/src/angles
RUN cd /build/orocos_underlay_ws \
    && . /opt/ros/${ROS_DISTRO}/setup.sh \
    && . /stage/opt/ros/${ROS_DISTRO}/local_setup.sh \
    && DESTDIR=/stage \
        catkin_make \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_FIND_ROOT_PATH=/stage \
            -DCATKIN_DEVEL_PREFIX=/build/orocos_underlay_ws/devel \
            -DCMAKE_INSTALL_PREFIX=/opt/ros/${ROS_DISTRO} \
            -DCATKIN_BLACKLIST_PACKAGES="rtt_tf;rtt_rosdeployment;tf_conversions" \
    && DESTDIR=/stage \
        catkin_make install \
            -DCMAKE_INSTALL_PREFIX=/opt/ros/${ROS_DISTRO}

## Stage deploy: copy the install-space to /opt/ros/${ROS_DISTRO} as a
## new image layer based on deps
FROM deps AS deploy
COPY --from=build /stage/opt/ros/${ROS_DISTRO} /opt/ros/${ROS_DISTRO}
