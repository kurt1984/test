FROM gcr.io/tensorflow/tensorflow:latest-gpu
MAINTAINER Lei

# Install R
# https://cran.rstudio.com/bin/linux/ubuntu/README.html
# Dockerfile example at https://github.com/rocker-org/rocker-versioned/blob/master/r-ver/Dockerfile
ENV R_VERSION=${R_VERSION:-3.4.3} \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm
RUN apt-get update
RUN apt-get install -y apt-transport-https locales
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen 
RUN locale-gen en_US.utf8
RUN /usr/sbin/update-locale LANG=en_US.UTF-8
RUN echo "deb http://cran.csiro.au/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list
RUN cat /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --allow-unauthenticated r-base r-base-dev
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
RUN apt-get update
RUN apt-get upgrade -y

# Install RStudio
# https://www.rstudio.com/products/rstudio/download-server/
# Dockerfile example at https://github.com/rocker-org/rocker-versioned/blob/master/rstudio/Dockerfile
RUN apt-get install -y wget gdebi-core
RUN cd /tmp; wget https://download2.rstudio.org/rstudio-server-1.1.419-amd64.deb
RUN cd /tmp; gdebi -n rstudio-server-1.1.419-amd64.deb


# create root password
RUN echo "root:Docker!" | chpasswd

# Create rstudio user
RUN useradd rstudio \
    && echo "rstudio:rstudio" | chpasswd \
	&& mkdir /home/rstudio \
	&& chown rstudio:rstudio /home/rstudio \
	&& addgroup rstudio staff 

# Needed for R GPU tools and debugging
RUN apt-get install -y libcurl4-openssl-dev libssl-dev libssh2-1-dev vim \
    python-virtualenv mlocate git sudo libedit2 libapparmor1 psmisc python-setuptools iputils-ping \
    r-cran-ggplot2
RUN updatedb

# Not sure this is needed
RUN mkdir /etc/OpenCL; mkdir /etc/OpenCL/vendors; echo "libnvidia-opencl.so.1" >> /etc/OpenCL/vendors/nvidia.icd

# Set up S6 init system
RUN wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz \
    && tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
    && mkdir -p /etc/services.d/rstudio \
    && echo '#!/bin/bash \
    \n exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0' \
    > /etc/services.d/rstudio/run \
    && echo '#!/bin/bash \
    \n rstudio-server stop' \
    > /etc/services.d/rstudio/finish

# tidyverse

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  libxml2-dev \
  libcairo2-dev \
  libsqlite-dev \
  libmariadbd-dev \
  libmariadb-client-lgpl-dev \
  libpq-dev \
  libssh2-1-dev \
  && R -e "source('https://bioconductor.org/biocLite.R')" \
  && install2.r --error \
    --deps TRUE \
    tidyverse \ 
    dplyr \
    ggplot2 \
    devtools \
    formatR \
    remotes \
    selectr \
    caTools

# pandoc

  ## Symlink pandoc & standard pandoc templates for use system-wide
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin \
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc-citeproc /usr/local/bin \
  && git clone https://github.com/jgm/pandoc-templates \
  && mkdir -p /opt/pandoc/templates \
  && cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* \
  && mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates \

# install r packages

r -e "install.packages('keras')"
r -e "install.packages('devtools')"
r -e "devtools::install_github('yihui/tinytex')"
r -e "tinytex::install_tinytex()"
r -e "keras::install_keras(tensorflow = 'gpu')"

# Launch rstudio-server
USER root
EXPOSE 8787
CMD ["/init"]
