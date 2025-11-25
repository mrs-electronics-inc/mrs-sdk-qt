# MRS SDK Qt - Virtual Machine Image

Packer configuration for building a VM image with Qt Creator and desktop build kits.

## Overview

Ubuntu 24.04 LTS VM with:
- Qt Creator IDE
- Qt 5 & Qt 6 desktop kits
- OVA output format

## Building

### Local Build

```bash
cd vm
./scripts/build-vm.sh
```

### CI/CD

GitHub Actions automatically builds on:
- Push to main branch
- Tagged releases

Artifacts uploaded as workflow artifacts.

## Configuration

Default VM settings:
- Memory: 4096 MB
- CPUs: 2
- Disk: 60 GB

Customize with script options:
```bash
./scripts/build-vm.sh -m 8192 -c 4
```

## Output

OVA file created in `output/` directory with manifest.json.
