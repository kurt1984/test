FROM gcr.io/tensorflow/tensorflow:latest-gpu
MAINTAINER Stefano Picozzi <StefanoPicozzi@gmail.com>

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
 
