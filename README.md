# Hadoop, Mahout, Pig and Hive on Docker

The purpose of the image presented is to facilitate the setup of development and integration testing environments for developers. This image is based on [base image docker](https://github.com/phusion/baseimage-docker) from phusion.

### What is inside
- Hadoop 2.6.4
- Mahout 0.12.2
- Pig 0.17.0
- Hive 1.2.2

### How to build
Run the **builddockerimage.sh** script

``` builddockerimage.sh ```

### How to run the container
Start the container with the given image, by running the following command: 

``` docker run -it --name ```