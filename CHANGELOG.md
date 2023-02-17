# Changelog

## [2.0.1](https://github.com/extra2000/steamcmd-podman/compare/v2.0.0...v2.0.1) (2023-02-17)


### Maintenance

* **gitignore:** add `/secrets/.gitkeep` ([3ab5062](https://github.com/extra2000/steamcmd-podman/commit/3ab506238b733e1a6b53f44b0dced76f7964554e))


### Documentations

* **project-zomboid:** add instruction to soft reset ([143313c](https://github.com/extra2000/steamcmd-podman/commit/143313cb11ba6a8b959fc192b6c7a704b5de83f1))
* **project-zomboid:** add port `16262/udp` ([df6d223](https://github.com/extra2000/steamcmd-podman/commit/df6d223cceb45c64b2f0e3ad9bcd710d43b6629e))

## [2.0.0](https://github.com/extra2000/steamcmd-podman/compare/v1.0.0...v2.0.0) (2023-02-14)


### ⚠ BREAKING CHANGES

* documentations have been redesigned

### Styles

* **docs:** remove logo ([be8c5f0](https://github.com/extra2000/steamcmd-podman/commit/be8c5f0b67e0972619a84588387cee19f7678555))


### Continuous Integrations

* add Github Action ([ef70472](https://github.com/extra2000/steamcmd-podman/commit/ef7047213b8576009070697276ad5404b07103a3))
* remove AppVeyor ([71f8235](https://github.com/extra2000/steamcmd-podman/commit/71f823511930b1c39825e81a71d8e2f851a740bb))


### Fixes

* **selinux:** allow `mongod_port_t` and `self` ([a4166c1](https://github.com/extra2000/steamcmd-podman/commit/a4166c1d3d8ea5e9d4e2d259ffd9a91120dfe861))
* **sphinx:** fix `_static` directory not found ([e441cee](https://github.com/extra2000/steamcmd-podman/commit/e441ceeba2df5370f5883ffb419a57c9de4e7c9f))


### Documentations

* **README:** remove AppVeyor badge ([296589c](https://github.com/extra2000/steamcmd-podman/commit/296589c520276ff27fd587f878e29736c62f0f46))
* redesign documentations ([201d7b0](https://github.com/extra2000/steamcmd-podman/commit/201d7b0081fa2a04bf5b37906ae2df72c2b65e6d))
* remove unused `concept.svg` ([1f80824](https://github.com/extra2000/steamcmd-podman/commit/1f80824f1376a0d738ade637ea6ea336647a9e41))


### Code Refactoring

* **pods:** remove `STEAMCMD_TAG` ([6e1cbae](https://github.com/extra2000/steamcmd-podman/commit/6e1cbaea61e8050710ec4b4bd98663afde9c9d39))
* **selinux:** rename SELinux policy name ([027b9b6](https://github.com/extra2000/steamcmd-podman/commit/027b9b6b92b6172a5d572048b89f7d945495b5ec))

## 1.0.0 (2022-01-18)


### Features

* initial implementations ([4365623](https://github.com/extra2000/steamcmd-podman/commit/436562312ae807bacf78bc0050267bcc9e91f256))


### Documentations

* **README:** update `README.md` ([b7e55f6](https://github.com/extra2000/steamcmd-podman/commit/b7e55f6137bae205450356f39742049391e8be12))


### Continuous Integrations

* add AppVeyor with `semantic-release` ([2677a75](https://github.com/extra2000/steamcmd-podman/commit/2677a756cce802c8a2cc51a72756a3f85144988d))
