# GNUmakefile

# Common configurations

ifeq ($(prefix),)
  prefix=/usr/local
endif

SHARED_LIBRARY_PREFIX=lib

MKDIR_P = mkdir -p

UNAME_S := $(shell uname -s)

# Apache stuff

ifeq ($(APXS),)
  APXS=$(shell which apxs)
endif
ifneq ($(APXS),)
  HAVE_APXS=yes
  ifeq ($(UNAME_S),Darwin)
    ifeq (/usr/sbin/apxs,$(APXS)) # this one is utterly b0rked
      $(warning "Using system Apache apxs - brew version is recommended!")
    endif
  endif
else
  HAVE_APXS=no
endif
USE_APXS=$(HAVE_APXS)

ifeq ($(USE_APXS),yes)
  # APACHE_INCLUDE_DIRS += $(shell $(APXS) -q INCLUDEDIR)
  # APACHE_CFLAGS       += $(shell $(APXS) -q CFLAGS)
  # APACHE_CFLAGS_SHLIB += $(shell $(APXS) -q CFLAGS_SHLIB)
  # APACHE_LD_SHLIB     += $(shell $(APXS) -q LD_SHLIB)

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
      ifeq ($(BREW),)
        BREW=$(shell which brew)
      endif
      ifneq (,$(BREW)) # use Homebrew locations
        USE_BREW=yes
      endif
    endif
  endif
  
  ifeq ($(prefix),)
    prefix = /usr/libexec/apache2
  endif
else # Linux
  # e.g.: OS=ubuntu VER=14.04
  # OS=$(shell lsb_release -si | tr A-Z a-z)
  # VER=$(shell lsb_release -sr)

  SHARED_LIBRARY_SUFFIX=.so
endif

ifeq ($(APACHE_MODULE_SUFFIX),)
  APACHE_MODULE_SUFFIX=$(SHARED_LIBRARY_SUFFIX)
endif


# Debug or Release?

ifeq ($(debug),on)
  APXS_EXTRA_CFLAGS  += -g
  APXS_EXTRA_LDFLAGS += -g
endif


# APR and APU configs

ifeq ($(USE_APXS),yes)
  PKGCONFIG_INCLUDE_DIRS += \
  	$(shell apxs -q INCLUDEDIR) \
	$(shell apxs -q APR_INCLUDEDIR) \
	$(shell apxs -q APU_INCLUDEDIR)
endif


# We have set prefix above, or we got it via ./config.make
# Now we need to derive:
# - APACHE_MODULE_INSTALL_DIR
# - HEADER_FILES_INSTALL_DIR
# - PKGCONFIG_INSTALL_DIR

ifeq ($(APACHE_MODULE_INSTALL_DIR),)
  ifeq ($(USE_APXS),yes)
    # Hm, with brew apxs this just has `libexec` instead of `libexec/apache2`
    # On Trusty it has the full path (${exec_prefix}/lib/apache2/modules)
    APACHE_MODULE_RELDIR=$(shell apxs -q | grep ^libexecdir | sed "s/libexecdir=.*}//g" )
  else
    ifeq ($(UNAME_S),Darwin)
      APACHE_MODULE_RELDIR="/libexec/apache2"
    else # Linux: this may be different depending on the distro
      APACHE_MODULE_RELDIR="/lib/apache2/modules"
    endif
  endif
  APACHE_MODULE_INSTALL_DIR=$(prefix)$(APACHE_MODULE_RELDIR)
endif
ifeq ($(HEADER_FILES_INSTALL_DIR),)
  HEADER_FILES_INSTALL_DIR=$(prefix)/include
endif
ifeq ($(PKGCONFIG_INSTALL_DIR),)
  # on Trusty most live in lib/x86_64-linux-gnu/pkgconfig. TBD
  PKGCONFIG_INSTALL_DIR=$(prefix)/lib/pkgconfig
endif
