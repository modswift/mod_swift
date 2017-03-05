# GNUmakefile containing rules to build a Swift library or tool using either
# Swift Package Manager, or using regular makefiles.
#

SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# include config.make if that hasn't happened yet

ifneq ($(NOZE_DID_INCLUDE_CONFIG_MAKE),yes)
include $(SELF_DIR)config.make
endif


# setup defaults

ifeq ($(PACKAGE_DIR),)
PACKAGE_DIR=.
endif

ifeq ($(PACKAGE),)
PACKAGE=$(notdir $(shell pwd))
endif

ifeq ($($(PACKAGE)_C_FILES),)
$(PACKAGE)_C_FILES = $(wildcard *.c) $(wildcard */*.c)
endif

# check whether main.swift is available, and set TYPE to `tool` or `library`
# or if the package name contains mod_/mods_, set Apache module type
ifeq ($($(PACKAGE)_TYPE),)
  ifeq (mod_,$(findstring mod_,$(PACKAGE)))
    $(PACKAGE)_TYPE = ApacheCModule
  endif
endif


#include actual rules file, depending on the available build tool

ifeq ($(USE_XCODEBUILD),yes)
else
include $(SELF_DIR)rules-makefile.make
endif
