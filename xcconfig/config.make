# GNUmakefile

debug=on
xcodebuild=no
brew=yes

NOZE_DID_INCLUDE_CONFIG_MAKE=yes

# Common configurations

SHARED_LIBRARY_PREFIX=lib

UNAME_S := $(shell uname -s)

# Apache stuff

APXS=$(shell which apxs)
ifneq ($(APXS),)
  HAVE_APXS=yes
  ifeq ($(UNAME_S),Darwin)
    ifeq (/usr/sbin/apxs,$(APXS)) # this one is utterly b0rked
      HAVE_APXS=no
    endif
  endif
else
  HAVE_APXS=no
endif
USE_APXS=$(HAVE_APXS)

ifeq ($(USE_APXS),yes)
  APACHE_INCLUDE_DIRS += $(shell $(APXS) -q INCLUDEDIR)
  APACHE_CFLAGS       += $(shell $(APXS) -q CFLAGS)
  APACHE_CFLAGS_SHLIB += $(shell $(APXS) -q CFLAGS_SHLIB)
  APACHE_LD_SHLIB     += $(shell $(APXS) -q LD_SHLIB)

  APXS_EXTRA_CFLAGS=
  APXS_EXTRA_LDFLAGS=
endif


# System specific configuration

USE_BREW=no

ifeq ($(UNAME_S),Darwin)
  ifeq ($(USE_APXS),no)
    xcodebuild=yes
  endif

  # platform settings

  SHARED_LIBRARY_SUFFIX=.dylib
  DEFAULT_SDK=$(shell xcrun -sdk macosx --show-sdk-path)

  ifeq ($(USE_APXS),yes)
    APXS_EXTRA_CFLAGS += -Wno-nullability-completeness

    ifneq ($(brew),no)
      BREW=$(shell which brew)
      ifneq (,$(BREW)) # use Homebrew locations
        BREW_APR_LOCATION=$(shell $(BREW) --prefix apr)
        BREW_APU_LOCATION=$(shell $(BREW) --prefix apr-util)
        APR_CONFIG=$(wildcard $(BREW_APR_LOCATION)/bin/apr-1-config)
        APU_CONFIG=$(wildcard $(BREW_APU_LOCATION)/bin/apu-1-config)
        USE_BREW=yes
      endif
    endif
  endif
else # Linux
  xcode=no

  # determine linux version
  OS=$(shell lsb_release -si | tr A-Z a-z)
  VER=$(shell lsb_release -sr)

  SHARED_LIBRARY_SUFFIX=.so
endif


ifeq ($(xcodebuild),yes)
  USE_XCODEBUILD=yes
endif


# APR/APU default setup (Homebrew handled above)

ifeq (,$(APR_CONFIG))
  APR_CONFIG=$(shell which apr-1-config)
  ifeq (,$(APU_CONFIG))
    APU_CONFIG=$(shell which apu-1-config)
  endif
endif
ifneq (,$(APR_CONFIG))
  APR_INCLUDE_DIRS = $(shell $(APR_CONFIG) --includedir)
  APR_CFLAGS       = $(shell $(APR_CONFIG) --cflags)
  APR_LDFLAGS      = $(shell $(APR_CONFIG) --ldflags)
  APR_LIBS         = $(shell $(APR_CONFIG) --libs)

  ifneq (,$(APU_CONFIG))
    APR_INCLUDE_DIRS += $(shell $(APU_CONFIG) --includedir)
    # APU has no --cflags
    APR_LDFLAGS += $(shell $(APU_CONFIG) --ldflags)
    APR_LIBS    += $(shell $(APU_CONFIG) --libs)
  endif
endif


# Debug or Release?

ifeq ($(debug),on)
  APXS_EXTRA_CFLAGS  += -g
  APXS_EXTRA_LDFLAGS += -g
endif

SWIFT_REL_BUILD_DIR=.libs
SWIFT_BUILD_DIR=$(PACKAGE_DIR)/$(SWIFT_REL_BUILD_DIR)
