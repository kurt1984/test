FROM tensorflow/tensorflow:latest-gpu

# Install system dependancy
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        wget \
        libgtk2.0-dev \
        pkg-config \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev\
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libjasper-dev \
        libdc1394-22-dev \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-numpy \
        python-pip \
        python-tk \
        python-scipy \
        python-skimage && \
    rm -rf /var/lib/apt/lists/*

# Download and install opencv
WORKDIR /opt
RUN git clone https://github.com/Itseez/opencv.git && \
    cd opencv && \
    git checkout master && \
    cd /opt/opencv && \
    mkdir release && \
    cd release && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D INSTALL_PYTHON_EXAMPLES=ON /opt/opencv/ && \
    make -j"$(nproc)" && \
    make install && \
    cp /opt/opencv/release/lib/cv2.so /usr/local/lib/python2.7/dist-packages && \
    rm -rf /opt/opencv && \
    ldconfig

RUN pip install keras

ADD ./requirements.txt .
RUN pip install -r requirements.txt

# fix "Couldn't open CUDA library libcupti.so"
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/extras/CUPTI/lib64

WORKDIR /root
