# macos-jail

[![Build Status](https://github.com/macOScontainers/macos-jail/workflows/CI/badge.svg?branch=main)](https://github.com/macOScontainers/macos-jail/actions?query=branch:main)

> **Note**
> Artifacts published in this repo contain software covered by [macOS EULA](https://www.apple.com/legal/sla/) and are only intended to be run on Apple hardware.

## Prerequisites

* MacOS Catalina or newer
* Disable [System Identity Protection](https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection).
SIP [doesn't allow](https://github.com/containerd/containerd/discussions/5525#discussioncomment-2685649) to `chroot` (not needed for building though).

## Usage

```shell
cd "$repo_root"
sudo python3 -m macosjail "$jail_dir" # prepare chroot dir contents
sudo chroot "$jail_dir" # enter chroot
```

In order to make DNS work in chroot, run:

```shell
sudo mkdir -p "$jail_dir/var/run"
sudo link /var/run/mDNSResponder "$jail_dir/var/run/mDNSResponder"
```
? ln -shf /var/run/mDNSResponder "$jail_dir/var/run/mDNSResponder""

## Uploading macOS rootfs as Docker image

```shell
brew install crane

# You might first need to authenticate using
# sudo crane auth login "$registry" -u "$username" -p "$password"
export image_tag="$registry/$image_name:$image_tag"
export jail_dir="$repo_root/jail"
export registry="https://git"
export image_tag="latest"
export image_name="sonoma-jail"
export image_tag="$registry/$image_name:$image_tag"
export jail_dir="$image_name"
sudo bash -c 'crane append --oci-empty-base --platform darwin -t "$image_tag" -f <(tar -f - -c -C "$jail_dir" .)'
```

If you want to run macOS image in [containerd](https://containerd.io), see [rund](https://github.com/macOScontainers/rund) project.

### Issues

## ZSH

```console
sh-3.2# zsh
zsh: failed to load module `zsh/zle': dlopen(/usr/lib/zsh/5.9/zsh/zle.so, 0x0009): tried: '/usr/lib/zsh/5.9/zsh/zle.so' (no such file, not in dyld cache)
```

## Xcode

TL;DR; download and install command line tools https://developer.apple.com/download/all/?q=command%20line%20tools on host

copy into jail /Library/Developer/CommandLineTools

Steps below around license and xcode app, relate to full Xcode.app

### License

1. Unable to install via UI
2. Instead copy in `/Library/Preferences/com.apple.dt.Xcode.plist` from host with accepted license

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>IDELastBetaLicenseAgreedTo</key>
        <string>EA1851</string>
        <key>IDELastGMLicenseAgreedTo</key>
        <string>EA1863</string>
        <key>IDELastPTRLicenseAgreedTo</key>
        <string>EA1863</string>
        <key>IDEXcodeVersionForAgreedToBetaLicense</key>
        <string>15.0</string>
        <key>IDEXcodeVersionForAgreedToGMLicense</key>
        <string>15.0</string>
        <key>IDEXcodeVersionForAgreedToPTRLicense</key>
        <string>15.0</string>
</dict>
</plist>
```

## clang - tmpdir

1. Fails without `TMPDIR` set

```console
./hello
clang: error: unable to make temporary file: No such file or directory
```

### Resolution

```sh
mkdir /tmp
export TMPDIR=/tmp
```

### Hello world

vim hello.c

```c
#include <stdio.h>
int main() {
   // printf() displays the string inside quotation
   printf("Hello, World!");
   return 0;
}
```

```sh
export TMPDIR=/tmp
arch -x86_64 clang -o hello-x86_64 hello.c
./hello-x86_64
file hello-x86_64
arch -arm64 clang -o hello-arm64 hello.c
./hello-arm64
file hello-arm64
# hello-x86_64: Mach-O 64-bit executable x86_64
```

## clang - compiling

_note:_ unncessary if copying in command line tools

Need to provide include and lib paths to compile (normally dealt with by `xcrun`)

```sh
arch -x86_64 clang -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/ -L/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/lib -o hello hello.c
./hello
file hello
# hello: Mach-O 64-bit executable x86_64
```

```sh
clang -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/ -L/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/lib -o hello hello.c
./hello
file hello
# hello: Mach-O 64-bit executable arm64
```

### Virtualization

```sh
clang -v
mkdir /tmp
export TMPDIR=/tmp
curl -LO https://gist.githubusercontent.com/imbushuo/51b09e61ecd7b7ac063853ad65cedf34/raw/fb1387c1d96d682beeb0dc2511ed4e48c7eb1268/simplevm.c
clang -o simplevm -O2 -framework Hypervisor -Wno-nullability-completeness -mmacosx-version-min=11.0 simplevm.c
vim simplevm.entitlements
codesign --entitlements simplevm.entitlements --force -s - simplevm 
./simplevm
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/
PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>com.apple.security.hypervisor</key>
<true/>
<key>com.apple.vm.networking</key>
<true/>
</dict>
</plist>
```

## xcode app

1. Copy Xcode.app to jail /Applications
2. Update `PATH` to reference sdk
   1. `export PATH=/Applications/Xcode.app/Contents/Developer/usr/bin:/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/:$PATH`


```console
ls /Applications/Xcode.app/Contents/Developer/usr/bin
2to3                            devicectl                       iphoneos-optimize               sdp
2to3-3.9                        embeddedBinaryValidationUtility ld                              simctl
DeRez                           extractLocStrings               leaks                           ssu-cli
GetFileInfo                     filtercalltree                  lldb                            ssu-cli-app
ResMerger                       g++                             logdump                         ssu-cli-nlu
Rez                             gamepolicyctl                   make                            stapler
SetFile                         gatherheaderdoc                 malloc_history                  stringdups
SplitForks                      gcc                             mapc                            swinfo
TextureAtlas                    genstrings                      momc                            symbols
TextureConverter                git                             notarytool                      vmmap
actool                          git-receive-pack                opendiff                        xarsigner
agvtool                         git-shell                       pip3                            xccov
altool                          git-upload-archive              pip3.9                          xcdebug
amlint                          git-upload-pack                 placeholderutil                 xcdevice
appleProductTypesTool           gnumake                         pngcrush                        xcdiagnose
atos                            hdxml2manxml                    pydoc3                          xcindex-test
backgroundassets-debug          headerdoc2html                  pydoc3.9                        xcodebuild
bitcode-build-tool              heap                            python3                         xcresulttool
cktool                          iTMSTransporter                 python3.9                       xcsigningtool
compileSceneKitShaders          ibtool                          rctool                          xcstringstool
convertRichTextToAscii          ibtool3                         resolveLinks                    xctest
copySceneKitAssets              ibtoold                         safari-web-extension-converter  xctrace
copypng                         ictool                          sample                          xed
coremlc                         instrumentbuilder               scalar                          xml2man
crashlog                        intentbuilderc                  scntool
desdp                           ipatool                         sdef
```

```ls
ls /Applications/Xcode.app/Contents/Developer/usr/bin
2to3                            devicectl                       iphoneos-optimize               sdp
2to3-3.9                        embeddedBinaryValidationUtility ld                              simctl
DeRez                           extractLocStrings               leaks                           ssu-cli
GetFileInfo                     filtercalltree                  lldb                            ssu-cli-app
ResMerger                       g++                             logdump                         ssu-cli-nlu
Rez                             gamepolicyctl                   make                            stapler
SetFile                         gatherheaderdoc                 malloc_history                  stringdups
SplitForks                      gcc                             mapc                            swinfo
TextureAtlas                    genstrings                      momc                            symbols
TextureConverter                git                             notarytool                      vmmap
actool                          git-receive-pack                opendiff                        xarsigner
agvtool                         git-shell                       pip3                            xccov
altool                          git-upload-archive              pip3.9                          xcdebug
amlint                          git-upload-pack                 placeholderutil                 xcdevice
appleProductTypesTool           gnumake                         pngcrush                        xcdiagnose
atos                            hdxml2manxml                    pydoc3                          xcindex-test
backgroundassets-debug          headerdoc2html                  pydoc3.9                        xcodebuild
bitcode-build-tool              heap                            python3                         xcresulttool
cktool                          iTMSTransporter                 python3.9                       xcsigningtool
compileSceneKitShaders          ibtool                          rctool                          xcstringstool
convertRichTextToAscii          ibtool3                         resolveLinks                    xctest
copySceneKitAssets              ibtoold                         safari-web-extension-converter  xctrace
copypng                         ictool                          sample                          xed
coremlc                         instrumentbuilder               scalar                          xml2man
crashlog                        intentbuilderc                  scntool
desdp                           ipatool                         sdef
safmacm1# ls /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
air-ar                          clang                           llvm-profdata                   ranlib
air-arch                        clang++                         llvm-size                       rpcgen
air-as                          clang-cache                     lorder                          segedit
air-config                      clang-stat-cache                m4                              size
air-dsymutil                    clangd                          metal                           size-classic
air-libtool                     cmpdylib                        metal-ar                        snippet-extract
air-link                        codesign_allocate               metal-arch                      sourcekit-lsp
air-lipo                        codesign_allocate-p             metal-as                        strings
air-lld                         coremlc                         metal-config                    strip
air-nm                          coremlcompiler                  metal-dsymutil                  swift
air-nt                          cpp                             metal-libtool                   swift-api-digester
air-objdump                     ctags                           metal-link                      swift-api-extract
air-opt                         ctf_insert                      metal-lipo                      swift-build
air-pack                        docc                            metal-lld                       swift-build-tool
air-ranlib                      dsymutil                        metal-nm                        swift-demangle
air-readobj                     dwarfdump                       metal-nt                        swift-driver
air-size                        flex                            metal-objdump                   swift-experimental-sdk
air-strip                       flex++                          metal-opt                       swift-frontend
air-tt                          gcov                            metal-pack                      swift-help
air-vtool                       gm4                             metal-ranlib                    swift-package
amdgpu-nt                       gperf                           metal-readobj                   swift-package-collection
appintentsmetadataprocessor     iig                             metal-size                      swift-package-registry
appintentsnltrainingprocessor   indent                          metal-source                    swift-plugin-server
applegpu-nt                     install_name_tool               metal-strip                     swift-run
appshortcutstringsprocessor     intelgpu-nt                     metal-tt                        swift-stdlib-tool
ar                              ld                              metal-vtool                     swift-symbolgraph-extract
as                              ld-classic                      metallib                        swift-test
asa                             lex                             mig                             swiftc
bison                           libtool                         modules-verifier                tapi
bitcode_strip                   lipo                            nm                              tapi-analyze
c++                             llvm-cov                        nm-classic                      unifdef
c++filt                         llvm-cxxfilt                    nmedit                          unifdefall
c89                             llvm-dwarfdump                  objdump                         unwinddump
c99                             llvm-nm                         otool                           vtool
cache-build-session             llvm-objdump                    otool-classic                   yacc
cc                              llvm-otool                      pagestuff
```


## HomeBrew


mkdir -p /var/root
sudo -i -u root printf '$HOME'
chroot -u $(whoami) cli-jail
chroot -u root cli-jail
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://gist.githubusercontent.com/YOU54F/676dc132c2f289ae4c8fa897a783cfd8/raw/e852b7471aae70a59e9fd0a8d131d45172450c94/install.sh)"


### Install

1. create required dirs
2. install as root, as user doesn't have a password for sudo and can't create with disc

```sh
chroot -u root cli-jail
mkdir -p /var/root
sudo -i -u root printf '$HOME'
mkdir -p /private/tmp
export HOMEBREW_NO_ANALYTICS=1
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://gist.githubusercontent.com/YOU54F/676dc132c2f289ae4c8fa897a783cfd8/raw/e852b7471aae70a59e9fd0a8d131d45172450c94/install.sh)"
sudo chown -R saf /Users/saf/Library/Caches/Homebrew /opt/homebrew /opt/homebrew/share/zsh /opt/homebrew/share/zsh/site-functions
```

```sh
chroot -u $(whoami) cli-jail
export HOMEBREW_NO_ANALYTICS=1
brew doctor
brew tap you54f/brew
chown -R saf /private/tmp
brew install passh
```

### SSL Errors


```console
safmacm1% macvz start docker.yaml 
FATA[0000] failed to download the required images, attempted 2 candidates, errors=[image architecture x86_64 didn't match system architecture: aarch64 failed to download required images: failed to download "https://cloud-images.ubuntu.com/releases/focal/release/unpacked/ubuntu-20.04-server-cloudimg-arm64-vmlinuz-generic": Get "https://cloud-images.ubuntu.com/releases/focal/release/unpacked/ubuntu-20.04-server-cloudimg-arm64-vmlinuz-generic": tls: failed to verify certificate: x509: OSStatus -26276] 
```

```sh
export SSL_CERT_FILE=/etc/ssl/cert.pem
```

## Docker - run as non root

Runs as local user, but can't access host network

```sh
docker run --rm -it --user $(id -u):$(id -g) 127.0.0.1:3000/you54f/macos-jail/cli-sonoma:latest zsh
```

Runs as local user, but can't access host network

```sh
docker run --rm -it 127.0.0.1:3000/you54f/macos-jail/cli-sonoma:latest zsh
chroot -u saf /
```

lets trick homebrew

```sh
export UID=501
safmacm1% /opt/homebrew/bin/brew doctor
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/fileutils.rb:239:in `mkdir': Permission denied @ dir_s_mkdir - /private (Errno::EACCES)
	from /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/fileutils.rb:239:in `fu_mkdir'
```

1. need to create 
```sh
export TMPDIR=/tmp
mkdir -p /private/tmp
export HOMEBREW_NO_ANALYTICS=1
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://gist.githubusercontent.com/YOU54F/676dc132c2f289ae4c8fa897a783cfd8/raw/e852b7471aae70a59e9fd0a8d131d45172450c94/install.sh)"
UID=501 /opt/homebrew/bin/brew doctor
git -C "/opt/homebrew" remote remove origin
git -C "/opt/homebrew" remote add origin https://github.com/Homebrew/brew
```

no bueno without hacking brew as use can't resolve host

## MacPorts

try macports instead

```sh
export TMPDIR=/tmp
mkdir -p /opt/mports
cd /opt/mports
git clone https://github.com/macports/macports-base.git
cd macports-base
cd /opt/mports/macports-base
./configure --enable-readline
make
make install # fails on dscl usercreate (https://guide.macports.org/#installing.macports.uninstalling.users)
make distclean
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
port -vd selfupdate # fails due to no certs at /private/etc/ssl
ditto /etc/ssl /private/etc/ssl
port -vd selfupdate
port install go
```

## Pkgx fka Tea.xyz

https://pkgx.dev/

```sh
curl -o ./pkgx-arm64 --compressed -f --proto '=https' https://pkgx.sh/$(uname)/arm64
install -m 755 pkgx-arm64 /usr/local/bin
curl -o ./pkgx-x86_64 --compressed -f --proto '=https' https://pkgx.sh/$(uname)/x86_64
install -m 755 pkgx-x86_64 /usr/local/bin
```

last version before codesigning

```sh
curl -LO https://github.com/pkgxdev/pkgx/releases/download/v0.24.6/tea-0.24.6+darwin+aarch64.tar.xz
tar -xvf tea-0.24.6+darwin+aarch64.tar.xz
./tea +python.org sh
python --version # killed
codesign --remove-signature `which python`
python --version
find .tea -name *.dylib | xargs codesign --remove-signature
```
## Deno

```sh
curl -fsSL https://deno.land/x/install/install.sh | sh
export DENO_INSTALL="/var/root/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
deno --version
```

details

```console
deno 1.37.1 (release, aarch64-apple-darwin)
v8 11.8.172.3
typescript 5.2.2
```

