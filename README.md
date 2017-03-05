<h2>mod_swift
  <img src="http://zeezide.com/img/mod_swift.svg"
       align="right" width="128" height="128" />
</h2>

![Apache 2](https://img.shields.io/badge/apache-2-yellow.svg)
![Swift3](https://img.shields.io/badge/swift-3-blue.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![tuxOS](https://img.shields.io/badge/os-tuxOS-green.svg?style=flat)
![Travis](https://travis-ci.org/AlwaysRightInstitute/mod_swift.svg?branch=master)

**mod_swift** is a technology demo which shows how to write native modules
for the
[Apache Web Server](https://httpd.apache.org)
in the 
[Swift 3](http://swift.org/)
programming language.
The demo includes a 
[C module to load Swift modules](mod_swift/README.md),
a [basic demo module](mods_baredemo/README.md),
the [ApacheExpress](ApacheExpress/README.md) framework which provides an Express 
like API for mod_swift,
a [demo for ApacheExpress](mods_expressdemo/README.md),
a [Todo MVC](mods_todomvc/README.md) backend (w/ CalDAV support!),
and a few supporting libraries
(such as Freddy or Noze.io [Mustache](ThirdParty/mustache/README.md)).

**Server Side Swift the [right](http://www.alwaysrightinstitute.com/) way**.
Instead of reinventing the HTTP server, hook into something that just works
and is battle proven. 
And comes with HTTP/2 as well as TLS support out of the box 🤓
(If you don't care, [Noze.io](http://noze.io) might be something for you.)

**Important**: The demo repro for this is still [AlwaysRightInstitute/mod_swift](https://github.com/AlwaysRightInstitute/mod_swift).
