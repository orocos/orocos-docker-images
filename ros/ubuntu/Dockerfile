## Provide Orocos Toolchain (RTT/OCL) and rtt_ros_integration overlay workspace on top of the
## official ROS 2 docker images.

ARG ROS_DISTRO
ARG UBUNTU_DISTRO

## *************************************************************************************************
## Stage base: prepare build environment
## *************************************************************************************************
FROM ros:${ROS_DISTRO}-ros-base-${UBUNTU_DISTRO} AS base

# add custom rosdep rule file and update rosdep database
COPY prereqs.yaml /etc/ros/rosdep/
RUN echo "yaml file:///etc/ros/rosdep/prereqs.yaml" > /etc/ros/rosdep/sources.list.d/10-custom.list
RUN rosdep update

# install python-vcstool used to clone repositories below
RUN apt-get update \
    && apt-get install -y python-vcstool \
    && rm -rf /var/lib/apt/lists/*

# setup new entrypoint and default command
COPY orocos_entrypoint.sh /orocos_entrypoint.sh
ENTRYPOINT [ "/orocos_entrypoint.sh" ]
CMD [ "bash" ]

## *************************************************************************************************
## Stage orocos_toolchain: clone, build and install Orocos Toolchain using CMake (with CORBA)
## *************************************************************************************************
FROM base AS orocos_toolchain

COPY orocos_toolchain.repos /build/src/
RUN vcs import --recursive /build/src < /build/src/orocos_toolchain.repos \
    && cd /build \
    && . /opt/ros/${ROS_DISTRO}/local_setup.sh \
    #
    # Install dependencies with rosdep
    && apt-get update \
    && apt-get install -y ruby \
    && rosdep install -y --from-path src --ignore-src \
    && rm -rf /var/lib/apt/lists/* \
    #
    # Build the workspace
    && catkin_make_isolated \
        --install \
        --install-space /opt/orocos/${ROS_DISTRO} \
        --cmake-args \
            -DBUILD_TESTING=OFF \
            -DCMAKE_BUILD_TYPE=Release \
            -DENABLE_CORBA=ON \
            -DCORBA_IMPLEMENTATION=OMNIORB \
            -DOROCOS_INSTALL_INTO_PREFIX_ROOT=ON \
    #
    # Cleanup
    && rm -rf /build

## *************************************************************************************************
## Stage overlay: clone, build and install overlay workspaces to /opt/ros/${ROS_DISTRO}
## *************************************************************************************************
FROM orocos_toolchain AS overlay

COPY overlay.repos /build/src/
RUN vcs import --recursive /build/src < /build/src/overlay.repos \
    && cd /build \
    && . /opt/ros/${ROS_DISTRO}/local_setup.sh \
    && . /opt/orocos/${ROS_DISTRO}/local_setup.sh \
    #
    # Install dependencies with rosdep
    && apt-get update \
    && ROS_PACKAGE_PATH=/opt/orocos/${ROS_DISTRO}/share:/opt/ros/${ROS_DISTRO}/share \
           rosdep install -y --from-path . --ignore-src \
    && rm -rf /var/lib/apt/lists/* \
    #
    # Build the workspace
    && catkin_make_isolated \
        --install \
        --install-space /opt/orocos/${ROS_DISTRO} \
        --cmake-args \
            -DCATKIN_ENABLE_TESTING=OFF \
            -DCMAKE_BUILD_TYPE=Release \
    #
    # Cleanup
    && rm -rf /build
