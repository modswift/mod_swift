# GNUmakefile

prefix=/usr/local

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
  SHARED_LIBRARY_SUFFIX=.dylib
  APACHE_MODULE_SUFFIX:=.so # yes

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
  OS=$(shell lsb_release -si | tr A-Z a-z)
  VER=$(shell lsb_release -sr)

  SHARED_LIBRARY_SUFFIX=.so
endif

APACHE_MODULE_SUFFIX=$(SHARED_LIBRARY_SUFFIX)


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
