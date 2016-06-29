# Use the official ubuntu-trusty image
FROM ubuntu:14.04

MAINTAINER EMC{code}

#update this in the Dockerfile to change between Minecraft versions
ARG MC_VERSION=1.10.2

# Use APT (Advanced Packaging Tool) built in the Linux distro to download Java, a dependency
# to run Minecraft.
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get -y update
RUN apt-get -y install openjdk-7-jre wget vim
RUN mkdir /minecraft

# Download Minecraft Server components
RUN wget -q https://s3.amazonaws.com/Minecraft.Download/versions/$MC_VERSION/minecraft_server.$MC_VERSION.jar -O /minecraft/minecraft_server.jar

# Sets working directory for the CMD instruction (also works for RUN, ENTRYPOINT commands)
# Create mount point, and mark it as holding externally mounted volume
WORKDIR /data
VOLUME /data

# Expose the container's network port: 25565 during runtime.
EXPOSE 25565

#Automatically accept Minecraft EULA, and start Minecraft server
CMD echo eula=true > /data/eula.txt && java -jar /minecraft/minecraft_server.jar
