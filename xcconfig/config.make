# GNUmakefile

# Common configurations

ifeq ($(prefix),)
  prefix=/usr/local
endif

SHARED_LIBRARY_PREFIX=lib

MKDIR_P      = mkdir -p
INSTALL_FILE = cp

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
  INSTALL_FILE = cp -X
  
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
  ifeq ($(APR_CONFIG),)
    APR_CONFIG = $(shell apxs -q APR_CONFIG)
  endif
  ifeq ($(APU_CONFIG),)
    APU_CONFIG = $(shell apxs -q APU_CONFIG)
  endif

  PKGCONFIG_INCLUDE_DIRS += \
	$(shell apxs -q INCLUDEDIR) \
	$(shell apxs -q APR_INCLUDEDIR) \
	$(shell apxs -q APU_INCLUDEDIR)


  # There is no APR/APU_LIBDIR because Apache doesn't assume us to link to it
  # explicitly. But this is exactly what the module maps do (because clients
  # can also link that)

  # We leave out this one, with Brew it doesn't exist and well, it doesn't
  # make much sense as we are not linking Apache.
  #   PKGCONFIG_LIB_DIRS += $(shell apxs -q LIBDIR)

  # this is a little fishy, but well
  ifneq ($(APR_CONFIG),)
    PKGCONFIG_LDFLAGS += $(shell $(APR_CONFIG) --link-ld)
  endif
  ifneq ($(APU_CONFIG),)
    PKGCONFIG_LDFLAGS += $(shell $(APU_CONFIG) --link-ld)
  endif
  PKGCONFIG_LIB_DIRS += \
	 $(patsubst -L%,%,$(patsubst -l%,,$(PKGCONFIG_LDFLAGS)))
endif


# We have set prefix above, or we got it via ./config.make
# Now we need to derive:
# - BINARY_INSTALL_DIR            e.g. /usr/local/bin
# - APACHE_MODULE_INSTALL_DIR
# - HEADER_FILES_INSTALL_DIR      e.g. /usr/local/include
# - PKGCONFIG_INSTALL_DIR         e.g. /usr/local/lib/pkgconfig
# - XCCONFIG_INSTALL_DIR          e.g. /usr/local/lib/xcconfig
# - MODMAP_INSTALL_DIR            e.g. /usr/local/lib/modmap
# - SWIFT_SHIM_INSTALL_DIR        e.g. /usr/local/lib/swift/shims
# - APACHE_CONFIG_TEMPLATES_INSTALL_DIR
#                        e.g. /usr/local/lib/mod_swift/apache-config-templates
# - MODULE_LOAD_INSTALL_DIR       e.g. /etc/apache2/mods-available
# - APACHE_CERT_INSTALL_DIR       e.g. /usr/local/lib/mod_swift/certificates

ifeq ($(BINARY_INSTALL_DIR),)
  BINARY_INSTALL_DIR=$(prefix)/bin
endif

ifeq ($(APACHE_MODULE_INSTALL_DIR),)
  ifeq ($(USE_APXS),yes)
    # Hm, with old brew apxs this just has `libexec` instead of
    # `libexec/apache2`.
    # On Trusty it has the full path (${exec_prefix}/lib/apache2/modules)
    #
    # On 10.13 Brew this is absolute and doesn't contain the ${prefix} pattern,
    # but a FQP /usr/local/lib/httpd/modules. Which I guess is a bug (exp_ vs
    # non-exp)
    # And there is not var for just `/usr/local/`.
    #
    # If we are installing into Brew, the Prefix is /usr/local/Cellar/abc and
    # this really needs to be dynamic and relative.
    #   /usr/local/opt/apache2/lib/httpd/modules
    #   apxs -q gives: libexecdir=/usr/local/lib/httpd/modules
    #   we need: lib/httpd/modules
    #   but apxs doesn't have any `/usr/local` prefix, all the variables are
    #   more explicitly qualified.
    # So we hardcode /usr/local /usr prefixes for now :-(
    APACHE_MODULE_RELDIR3=$(shell apxs -q | grep ^libexecdir | sed "s/libexecdir=.*}//g" | sed "sTlibexecdir=$(prefix)TTg" | sed "s/libexecdir=//g" )
    APACHE_MODULE_RELDIR2=$(subst /usr/local,,$(APACHE_MODULE_RELDIR3))
    APACHE_MODULE_RELDIR=$(subst /usr,,$(APACHE_MODULE_RELDIR2))
    APACHE_MODULE_INSTALL_DIR=${prefix}/${APACHE_MODULE_RELDIR}
  else
    ifeq ($(UNAME_S),Darwin)
      APACHE_MODULE_INSTALL_DIR="$(prefix)/libexec/apache2"
    else # Linux: this may be different depending on the distro
      APACHE_MODULE_INSTALL_DIR="$(prefix)/lib/apache2/modules"
    endif
  endif
endif

ifeq ($(HEADER_FILES_INSTALL_DIR),)
  HEADER_FILES_INSTALL_DIR=$(prefix)/include
endif
ifeq ($(PKGCONFIG_INSTALL_DIR),)
  # on Trusty most live in lib/x86_64-linux-gnu/pkgconfig. TBD
  PKGCONFIG_INSTALL_DIR=$(prefix)/lib/pkgconfig
endif

ifeq ($(XCCONFIG_INSTALL_DIR),)
  XCCONFIG_INSTALL_DIR=$(prefix)/lib/xcconfig
endif
ifeq ($(MODMAP_INSTALL_DIR),)
  MODMAP_INSTALL_DIR=$(prefix)/lib/modmap
endif

ifeq ($(SWIFT_SHIM_INSTALL_DIR),)
  SWIFT_SHIM_INSTALL_DIR=$(prefix)/lib/swift/shims
endif

ifeq ($(APACHE_CONFIG_TEMPLATES_INSTALL_DIR),)
  APACHE_CONFIG_TEMPLATES_INSTALL_DIR=$(prefix)/lib/mod_swift/apache-config-templates
endif

ifeq ($(MODULE_LOAD_INSTALL_DIR),)
  # Ubuntu
  MODULE_LOAD_INSTALL_DIR=/etc/apache2/mods-available
endif

ifeq ($(APACHE_CERT_INSTALL_DIR),)
  APACHE_CERT_INSTALL_DIR=$(prefix)/lib/mod_swift/certificates
endif
