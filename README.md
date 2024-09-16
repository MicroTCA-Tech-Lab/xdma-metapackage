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

## Workarounds for upstream driver

### Kernel compatibility

Since Xilinx upstream driver is poorly maintained and does not build with a current kernel, this package uses a [community fork](https://github.com/alonbl/dma_ip_drivers/tree/alonbl) ([alonbl's stable patchset](https://github.com/Xilinx/dma_ip_drivers/pull/240)).

### Versioning

Since Xilinx does not bump the version of the upstream driver, this package uses a different versioning.

## Debugging

### Build the module with debugging enabled

Invoke cmake with `-DXDMA_DEBUG='1'`.

So the preparation step from above becomes:

```
git submodule init && git submodule update
mkdir build && cd build && cmake -DXDMA_DEBUG='1' ..
```
