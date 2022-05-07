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

2022-05-07:
- It hasn't been tested for a while, it should work, but may require
  some tweaking.
- On macOS, Homebrew AFAIK b0rked Apache modules quite a while ago,
  presumably a custom Apache compilation is necessary on that (or some
  other way to install Apache2, not Homebrew?).

20xx-yy-zz:
This is not a demo anymore, it actually seems to work quite well.

### Who

**mod_swift** is brought to you by
[ZeeZide](http://zeezide.de).
We like feedback, GitHub stars, cool contract work,
presumably any form of praise you can think of.

There is a `#mod_swift` channel on the [Noze.io Slack](http://slack.noze.io).
