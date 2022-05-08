<h2>mod_swift
  <img src="http://zeezide.com/img/mod_swift.svg"
       align="right" width="128" height="128" />
</h2>

![Apache 2](https://img.shields.io/badge/apache-2-yellow.svg)
![Swift](https://img.shields.io/badge/swift-5-blue.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![tuxOS](https://img.shields.io/badge/os-tuxOS-green.svg?style=flat)

**mod_swift** allows you to write native modules
for the
[Apache Web Server](https://httpd.apache.org)
in the 
[Swift](http://swift.org/)
programming language.
**Server Side Swift the [right](http://www.alwaysrightinstitute.com/) way**.

This project/sourcedir contains the actual C-language `mod_swift`.
It is a straight Apache module which is then used to load Swift based Apache 
modules (mods_xyz).

Also included are Xcode base configurations, module maps for Apache and APR
as well as a few API wrappers that are used to workaround `swiftc` crashers
and Swift-C binding limitations.

**Note**: mod_swift is very low level, we currently provide two efforts to
          make Apache module development more pleasant:
          the Swift [Apache API](https://github.com/modswift/Apache),
          and [ApacheExpress](https://apacheexpress.io/).
          The latter provides a very convenient Node.js/ExpressJS like API
          which makes it very easy to write modules.

### Documentation

You can find pretty neat mod_swift documentation over here:
[docs.mod-swift.org](http://docs.mod-swift.org/).

### Status

- 2022-05-08:
  - Updated for macOS 12 M1 Homebrew. Back in a working state!
  - Note that [Homebrew APRUtil](https://github.com/Homebrew/homebrew-core/pull/31799/commits/584a9faa5c2decf32f25bb9d5f028395bb93ab5f) 
    only comes w/ the SQLite driver. To use other drivers with
    [mod_dbd](http://docs.mod-swift.org/mod_dbd/), a manual install
    is necessary.
- 2017-06-12:
  - This is not a demo anymore, it actually seems to work quite well.


### Quick Install

```bash
brew tap modswift/mod_swift
brew install httpd mod_swift

$ swift apache validate
swift-driver version: 1.45.2 The Swift Apache build environment looks sound.

  srcroot:   /Users/helge/tmp/mods_helloworld
  module:    mods_helloworld
  config:    debug
  product:   /Users/helge/tmp/mods_helloworld/.build/mods_helloworld.so
  apxs:      /opt/homebrew/bin/apxs
  moddir:    /opt/homebrew/lib/httpd/modules
  relmoddir: /
  mod_swift: /opt/homebrew/opt/mod_swift
  swift:     5.6.0
  cert:      self-signed-mod_swift-localhost-server.crt
  http/2:    yes
```

### HelloWorld Apache Module

```bash
$ mkdir mods_helloworld && cd mods_helloworld
$ swift apache init
The Swift Apache build environment looks sound.

  module:    mods_helloworld
  config:    debug
  product:   /Users/helge/tmp/tests/mods_helloworld/.build/mods_helloworld.so
  apxs:      /usr/local/bin/apxs
  mod_swift: /usr/local/opt/mod_swift
```

```bash
$ swift apache build
Fetching https://github.com/modswift/Apache.git
Fetching https://github.com/modswift/CApache.git
Completed resolution in 3.65s
Cloning https://github.com/modswift/CApache.git
Resolving https://github.com/modswift/CApache.git at 2.0.1
Cloning https://github.com/modswift/Apache.git
Resolving https://github.com/modswift/Apache.git at 0.5.0
[2/2] Compiling Swift Module 'mods_helloworld' (1 sources)

$ ls -hl .build/mods_helloworld.so
-rwxr-xr-x  1 helge  staff   173K 12 Mai 15:29 .build/mods_helloworld.so
```

```bash
$ swift apache serve
Note: DocRoot /usr/local/var/www/htdocs
Starting Apache on port 8042/8442:
GET /helloworld/ 200 715 - 0ms
```


### Who

**mod_swift** is brought to you by
[ZeeZide](http://zeezide.de).
We like feedback, GitHub stars, cool contract work,
presumably any form of praise you can think of.

There is a `#mod_swift` channel on the [Noze.io Slack](http://slack.noze.io).

**Want to support my work**?
Buy an app:
[Past for iChat](https://apps.apple.com/us/app/past-for-ichat/id1554897185),
[SVG Shaper](https://apps.apple.com/us/app/svg-shaper-for-swiftui/id1566140414),
[Shrugs](https://shrugs.app/),
[HMScriptEditor](https://apps.apple.com/us/app/hmscripteditor/id1483239744).
You don't have to use it! 😀
