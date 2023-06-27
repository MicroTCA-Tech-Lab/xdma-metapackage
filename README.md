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

## Troubleshooting

### Can't build on Ubuntu 22.04 / Kernel 5.19

There is a [unmerged PR on the Xilinx driver](https://github.com/Xilinx/dma_ip_drivers/pull/179) following a breaking change in the DMA API. Until Xilinx merges this, the fix has to be applied manually.

```bash
cd dma_ip_drivers
git remote add fix git@github.com:vkomenda/dma_ip_drivers.git
git pull fix
git checkout fix/dma-compat-fix-linux-5.19
```

## Debugging

### Build the module with debugging enabled

Invoke cmake with `-DXDMA_DEBUG='1'`.

So the preparation step from above becomes:

```
git submodule init && git submodule update
mkdir build && cd build && cmake -DXDMA_DEBUG='1' ..
```