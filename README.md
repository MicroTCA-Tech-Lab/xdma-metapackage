# XDMA driver metapackage

This repository adds udev rules and dkms support to the [Xilinx XDMA driver](https://github.com/Xilinx/dma_ip_drivers).

## Usage

### Preparation

```
git submodule init && git submodule update
mkdir build && cd build && cmake ..
```

### Install driver

```
sudo make install
```

### Create Debian package

```
make package
```
