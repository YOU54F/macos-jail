# macos-jail

[![GitHub Actions](https://github.com/slonopotamus/macos-jail/workflows/CI/badge.svg?branch=master)](https://github.com/slonopotamus/macos-jail/actions/workflows/ci.yml?query=branch%3Amaster)

## Prerequisites

* MacOS Catalina or newer
* Disable https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection[System Identity Protection]. 
SIP https://github.com/containerd/containerd/discussions/5525#discussioncomment-2685649[doesn't allow] to `chroot`.

## Usage

```bash
$ cd <repo root>
$ sudo python3 -m macosjail <jail dir> # prepare chroot dir contents
$ sudo chroot <jail dir> # enter chroot
```
