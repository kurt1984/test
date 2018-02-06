FROM mjmg/centos-mro-rstudio-opencpu-shiny-server-cuda

ENV MXNET_VERSION 0.11.0 

WORKDIR /tmp

# Setup NVIDIA CUDNN 7 devel
# From https://gitlab.com/nvidia/cuda/blob/centos7/8.0/devel/cudnn7/Dockerfile

ENV CUDNN_VERSION 7.0.4.31
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

# cuDNN license: https://developer.nvidia.com/cudnn/license_agreement
RUN CUDNN_DOWNLOAD_SUM=c9d6e482063407edaa799c944279e5a1a3a27fd75534982076e62b1bebb4af48 && \
    curl -fsSL http://developer.download.nvidia.com/compute/redist/cudnn/v7.0.4/cudnn-8.0-linux-x64-v7.tgz -O && \
    echo "$CUDNN_DOWNLOAD_SUM  cudnn-8.0-linux-x64-v7.tgz" | sha256sum -c - && \
    tar --no-same-owner -xzf cudnn-8.0-linux-x64-v7.tgz -C /usr/local && \
    rm cudnn-8.0-linux-x64-v7.tgz && \
    ldconfig

RUN \
  yum install -y cairo-devel libXt-devel opencv-devel


