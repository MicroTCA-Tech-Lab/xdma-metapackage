# XDMA driver metapackage

This repository adds udev rules and dkms support to the [Xilinx XDMA driver](https://github.com/Xilinx/dma_ip_drivers).

## Usage

Make sure to clone with --recurse-submodules.

### Preparation

```
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
