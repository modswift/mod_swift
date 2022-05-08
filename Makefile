# GNUmakefile

-include config.make
include xcconfig/config.make

MAJOR=0
MINOR=9
SUBMINOR=2

PACKAGE = mod_swift
CFILES  = mod_swift.c mod_swift_api.c
HFILES  = mod_swift.h

SWIFT_SHIM_FILES = $(wildcard shims/*.h)

SCRIPTS                 = $(wildcard swift-apache/swift-apache*)
APACHE_CONFIG_TEMPLATES = $(wildcard swift-apache/mod_swift-*.conf.template)

PACKAGE_DESCRIPTION = "Swift language support for Apache"

APACHE_CERTIFICATES = $(wildcard certs/*.crt) $(wildcard certs/*.key)

include xcconfig/rules-apxs.make
