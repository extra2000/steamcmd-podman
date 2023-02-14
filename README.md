# steamcmd-podman

| License | Versioning |
| ------- | ---------- |
| [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) | [![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release) |

SteamCMD deployment using Podman.


## How to build docs into HTML

Create `./output` to store rendered HTML output:
```
mkdir -pv output
```

Allow this project directory to be mounted into Podman container:
```
chcon -R -v -t container_file_t .
```

**NOTE:** The `chcon` commands are for SELinux platforms only.

To build docs for all versions (uncommit changes will not be included into build due to `sphinx-multiversion` limitations):
```
podman run -it --rm \
--network none \
-v ./:/srv:rw extra2000/sphinx \
sphinx-multiversion ./docs/source ./output/html
```

To build docs for current uncommit changes:
```
podman run -it --rm \
--network none \
-v ./:/srv:rw \
extra2000/sphinx sphinx-build ./docs/source ./output/html/dev
```
