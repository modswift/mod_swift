# GNUmakefile


ifeq ($(USE_APXS),no)
  ifeq ($(UNAME_S),Darwin)
    $(error missing Apache apxs, did you brew install homebrew/apache/httpd24 --with-mpm-event --with-http2?)
  else
    $(error missing Apache apxs, did you install apache2-dev?)
  endif
endif

LLDB_INIT_FILE = $(HOME)/.lldbinit

APXS_OUTDIR = .libs
APACHE_C_MODULE_BUILD_RESULT = $(APXS_OUTDIR)/$(PACKAGE)$(APACHE_MODULE_SUFFIX)
APACHE_C_MODULE_INSTALL_NAME = $(PACKAGE)$(APACHE_MODULE_SUFFIX)

PACKAGE_PKGCONFIG = $(APXS_OUTDIR)/$(PACKAGE).pc
PACKAGE_XCCONFIG  = $(APXS_OUTDIR)/$(PACKAGE).xcconfig
PACKAGE_MODMAP    = $(APXS_OUTDIR)/module.map
PACKAGE_MODULE_LOAD_FILE = $(APXS_OUTDIR)/$(patsubst mod_%,%,$(PACKAGE)).load
PACKAGE_HELPERS   = $(PACKAGE_PKGCONFIG) $(PACKAGE_XCCONFIG) $(PACKAGE_MODMAP) \
                    $(PACKAGE_MODULE_LOAD_FILE)

PACKAGE_MODMAP_INSTALL_DIR = $(MODMAP_INSTALL_DIR)/$(PACKAGE)/

HEADER_FILES_INSTALL_PATHES = $(addprefix $(HEADER_FILES_INSTALL_DIR)/,$(HFILES))
SHIM_FILES_INSTALL_PATHES   = $(addprefix $(SWIFT_SHIM_INSTALL_DIR)/,$(notdir $(SWIFT_SHIM_FILES)))

APXS_BUILD_FILES = \
	$(APACHE_C_MODULE_BUILD_RESULT)	\
	$(CFILES:.c=.o)			\
	$(CFILES:.c=.lo)		\
	$(CFILES:.c=.slo)		\
	$(CFILES:.c=.lo)		\
	$(PACKAGE).la     		\
	$(APXS_OUTDIR)/$(PACKAGE).a	\
	$(APXS_OUTDIR)/$(PACKAGE).la	\
	$(APXS_OUTDIR)/$(PACKAGE).lai	\
	$(addprefix $(APXS_OUTDIR)/,$(CFILES:.c=.o))

all : $(APACHE_C_MODULE_BUILD_RESULT) $(PACKAGE_HELPERS)

clean :
	rm -f $(APXS_BUILD_FILES) $(PACKAGE_HELPERS)

distclean : clean
	rm -rf $(APXS_OUTDIR)
	rm -f config.make

install-lldbinit:
	@if test "$(UNAME_S)" = "Darwin"; then \
	  if test -f "$(LLDB_INIT_FILE)"; then \
	    if ! grep -q SIGPIPE "$(LLDB_INIT_FILE)"; then \
	      echo "NOTE: adding SIGPIPE handling to your ~/.lldbinit ..."; \
	      echo "" >> "$(LLDB_INIT_FILE)";\
	      echo "# mod-swift.org: ignore httpd SIGPIPE's in debugger" \
	           >> "$(LLDB_INIT_FILE)";\
	      echo "process handle SIGPIPE -n true -p true -s false" \
	           >> "$(LLDB_INIT_FILE)";\
	    fi; \
	  else \
	    echo "NOTE: creating an ~/.lldbinit for Xcode ..."; \
	    echo "# mod-swift.org: ignore httpd SIGPIPE's in debugger" \
	         >> "$(LLDB_INIT_FILE)";\
	    echo "process handle SIGPIPE -n true -p true -s false" \
	         >> "$(LLDB_INIT_FILE)";\
	  fi \
	fi

install : all install-lldbinit
	$(MKDIR_P) $(APACHE_MODULE_INSTALL_DIR) \
		   $(HEADER_FILES_INSTALL_DIR)  \
		   $(PKGCONFIG_INSTALL_DIR)	\
		   $(SWIFT_SHIM_INSTALL_DIR)	\
		   $(APACHE_CONFIG_TEMPLATES_INSTALL_DIR) \
		   $(APACHE_CERT_INSTALL_DIR)   \
		   $(BINARY_INSTALL_DIR)
	$(INSTALL_FILE) $(APACHE_C_MODULE_BUILD_RESULT) \
			$(APACHE_MODULE_INSTALL_DIR)/$(APACHE_C_MODULE_INSTALL_NAME)
	$(INSTALL_FILE) $(HFILES) $(HEADER_FILES_INSTALL_DIR)/
	$(INSTALL_FILE) $(SWIFT_SHIM_FILES) $(SWIFT_SHIM_INSTALL_DIR)/
	$(INSTALL_FILE) $(PACKAGE_PKGCONFIG) $(PKGCONFIG_INSTALL_DIR)/
	if test "$(UNAME_S)" = "Darwin"; then \
	  $(MKDIR_P) $(XCCONFIG_INSTALL_DIR)  $(PACKAGE_MODMAP_INSTALL_DIR); \
	  $(INSTALL_FILE) $(PACKAGE_XCCONFIG) $(XCCONFIG_INSTALL_DIR)/;	\
	  $(INSTALL_FILE) $(PACKAGE_MODMAP)   $(PACKAGE_MODMAP_INSTALL_DIR)/; \
	else \
	  $(MKDIR_P) $(MODULE_LOAD_INSTALL_DIR); \
	  $(INSTALL_FILE) $(PACKAGE_MODULE_LOAD_FILE) $(MODULE_LOAD_INSTALL_DIR)/; \
	fi;
	$(INSTALL_FILE) $(SCRIPTS)                 $(BINARY_INSTALL_DIR)/
	$(INSTALL_FILE) $(APACHE_CONFIG_TEMPLATES) $(APACHE_CONFIG_TEMPLATES_INSTALL_DIR)/
	$(INSTALL_FILE) $(APACHE_CERTIFICATES)     $(APACHE_CERT_INSTALL_DIR)/

uninstall :
	rm -f $(APACHE_MODULE_INSTALL_DIR)/$(APACHE_C_MODULE_INSTALL_NAME) \
	      $(HEADER_FILES_INSTALL_PATHES) 				\
	      $(SHIM_FILES_INSTALL_PATHES)   				\
	      $(PKGCONFIG_INSTALL_DIR)/$(PACKAGE).pc 			\
	      $(XCCONFIG_INSTALL_DIR)/$(PACKAGE).xcconfig 		\
	      $(PACKAGE_MODMAP_INSTALL_DIR)/module.map 			\
	      $(MODULE_LOAD_INSTALL_DIR)/$(PACKAGE_MODULE_LOAD_FILE) 	\
	      $(addprefix $(BINARY_INSTALL_DIR)/,$(notdir $(SCRIPTS)))	\
	      $(addprefix $(APACHE_CONFIG_TEMPLATES_INSTALL_DIR)/,$(notdir $(APACHE_CONFIG_TEMPLATES))) \
	      $(addprefix $(APACHE_CERT_INSTALL_DIR)/,$(notdir $(APACHE_CERTIFICATES)))

LIBTOOL_CPREFIX=-Wc,
LIBTOOL_LDPREFIX=-Wl,
APXS_EXTRA_CFLAGS_LIBTOOL  = $(addprefix $(LIBTOOL_CPREFIX),$(APXS_EXTRA_CFLAGS))
APXS_EXTRA_LDFLAGS_LIBTOOL = $(addprefix $(LIBTOOL_LDPREFIX),$(APXS_EXTRA_LDFLAGS))
APXS_LIBTOOL_BUILD_RESULT  = $(APXS_OUTDIR)/$(PACKAGE).so

$(APACHE_C_MODULE_BUILD_RESULT) : $(CFILES)
	@mkdir -p $(@D)
	$(APXS) $(APXS_EXTRA_CFLAGS_LIBTOOL) $(APXS_EXTRA_LDFLAGS_LIBTOOL) \
	  -n $(PACKAGE)    \
	  -o $(PACKAGE).so \
          -c $(CFILES)


# config test

testconfig:
	@echo "Brew:                $(BREW)"
	@echo "Use brew:            $(USE_BREW)"
	@echo "APXS:                $(APXS)"
	@echo "Prefix:              $(prefix)"
	@echo "Install module in:   $(APACHE_MODULE_INSTALL_DIR)"
	@echo "Install headers in:  $(HEADER_FILES_INSTALL_DIR)"
	@echo "Install pc in:       $(PKGCONFIG_INSTALL_DIR)"
	@echo "Install cfgtmpls in: $(APACHE_CONFIG_TEMPLATES_INSTALL_DIR)"

testconfig-swift-docker:
	docker run --rm -v $(PWD):/src helje5/swift-apache-dev bash -c "cd /src; make testconfig"


# pkg config

PACKAGE_VERSION_STRING=$(MAJOR).$(MINOR).$(SUBMINOR)

PKGCONFIG_CFLAGS = \
	"-I\$${includedir}"		\
	"-I\$${libdir}/swift/shims"	\
	$(addprefix -I,$(PKGCONFIG_INCLUDE_DIRS))

# pickup the right APR
ifeq ($(UNAME_S),Darwin)
  PKGCONFIG_LDFLAGS_NO_LIBS = \
	$(addprefix -L,$(PKGCONFIG_LIB_DIRS))
else
  # on Linux we want the system to handle this
  PKGCONFIG_LDFLAGS_NO_LIBS =
endif

# Also: libs. Not served by apxs which doesn't need libs, but we might still
#.      want to do those for apr/apu apps?
$(PACKAGE_PKGCONFIG) : $(wildcard config.make)
	@echo "prefix=$(prefix)" > "$(PACKAGE_PKGCONFIG)"
	@echo "includedir=$(HEADER_FILES_INSTALL_DIR)" >> "$(PACKAGE_PKGCONFIG)"
	@echo "libdir=$(prefix)/lib" >> "$(PACKAGE_PKGCONFIG)"
	@echo "" >> "$(PACKAGE_PKGCONFIG)"
	@echo "Name: $(PACKAGE)" >> "$(PACKAGE_PKGCONFIG)"
	@echo "Description: $(PACKAGE_DESCRIPTION)" >> "$(PACKAGE_PKGCONFIG)"
	@echo "Version: $(PACKAGE_VERSION_STRING)" >> "$(PACKAGE_PKGCONFIG)"
	@echo "Cflags: $(PKGCONFIG_CFLAGS)" >> "$(PACKAGE_PKGCONFIG)"
	@echo "Libs: $(PKGCONFIG_LDFLAGS_NO_LIBS)" >> "$(PACKAGE_PKGCONFIG)"


# xcconfig

# OTHER_LDFLAGS:
# Note: The Apache API is part of the server itself and only becomes available
#       when the module is loaded into the server.
# Absolute pathes to Swift static libs because rpath. No idea :-)
#
# SWIFT_INCLUDE_PATHS is a little crazy. When using the Apache2 modmap, the
# linker can't resolve -lswiftDarwin.a anymore even though it seems to pass in
# a proper -L
# Fix: specify absolute path to .a above
#
$(PACKAGE_XCCONFIG) : $(wildcard config.make)
	@echo "// Xcode configuration set for mod_swift" > "$(PACKAGE_XCCONFIG)"
	@echo "// generated on $(shell date)" >> "$(PACKAGE_XCCONFIG)"
	@echo "" >> "$(PACKAGE_XCCONFIG)"
	@echo "DYLIB_INSTALL_NAME_BASE = $(shell $(APXS) -q exp_libexecdir)" >> "$(PACKAGE_XCCONFIG)"
	@echo "EXECUTABLE_EXTENSION    = so" >> "$(PACKAGE_XCCONFIG)"
	@echo "EXECUTABLE_PREFIX       = "   >> "$(PACKAGE_XCCONFIG)"
	@echo "" >> "$(PACKAGE_XCCONFIG)"
	@echo "HEADER_SEARCH_PATHS     = \$$(inherited) $(HEADER_FILES_INSTALL_DIR) $(PKGCONFIG_INCLUDE_DIRS)" >> "$(PACKAGE_XCCONFIG)"
	@echo "LIBRARY_SEARCH_PATHS    = \$$(inherited) $(PKGCONFIG_LIB_DIRS) \$$(TOOLCHAIN_DIR)/usr/lib/swift/macosx \$$(BUILT_PRODUCTS_DIR)" >> "$(PACKAGE_XCCONFIG)"
	@echo "LD_RUNPATH_SEARCH_PATHS = \$$(inherited) \$$(TOOLCHAIN_DIR)/usr/lib/swift/macosx \$$(BUILT_PRODUCTS_DIR)" >> "$(PACKAGE_XCCONFIG)"
	@echo "" >> "$(PACKAGE_XCCONFIG)"
	@echo "OTHER_CFLAGS            = \$$(inherited) $(shell $(APXS) -q EXTRA_CPPFLAGS)" >> "$(PACKAGE_XCCONFIG)"
	@echo "" >> "$(PACKAGE_XCCONFIG)"
	@echo "OTHER_LDFLAGS           = \$$(inherited) -rpath \$$(TOOLCHAIN_DIR)/usr/lib/swift/macosx -rpath \$$(BUILT_PRODUCTS_DIR) -undefined dynamic_lookup -lswiftFoundation -lswiftDarwin -lswiftCore" >> "$(PACKAGE_XCCONFIG)"
	@echo "" >> "$(PACKAGE_XCCONFIG)"
	@echo "// Note: Apache headers use documentation but using a different style" >> "$(PACKAGE_XCCONFIG)"
	@echo "CLANG_WARN_DOCUMENTATION_COMMENTS = NO" >> "$(PACKAGE_XCCONFIG)"
	@echo "" >> "$(PACKAGE_XCCONFIG)"
	@echo "SWIFT_INCLUDE_PATHS     = \$$(inherited) $(PACKAGE_MODMAP_INSTALL_DIR) \$$(TOOLCHAIN_DIR)/usr/lib/swift" >> "$(PACKAGE_XCCONFIG)"

# modmap

$(PACKAGE_MODMAP) : $(wildcard config.make)
	@echo "// mod_swift module.map for Apache 2" > "$(PACKAGE_MODMAP)"
	@echo "// generated on $(shell date)" >> "$(PACKAGE_MODMAP)"
	@echo "" >> "$(PACKAGE_MODMAP)"
	@echo "module CAPR [system] {" >> "$(PACKAGE_MODMAP)"
	@echo "  header \"$(SWIFT_SHIM_INSTALL_DIR)/APRShim.h\"" >> "$(PACKAGE_MODMAP)"
	@echo "  link \"apr-1\"" >> "$(PACKAGE_MODMAP)"
	@echo "  export *" >> "$(PACKAGE_MODMAP)"
	@echo "}" >> "$(PACKAGE_MODMAP)"
	@echo "" >> "$(PACKAGE_MODMAP)"
	@echo "module CAPRUtil [system] {" >> "$(PACKAGE_MODMAP)"
	@echo "  use CAPR" >> "$(PACKAGE_MODMAP)"
	@echo "  header \"$(SWIFT_SHIM_INSTALL_DIR)/APRUtilShim.h\"" >> "$(PACKAGE_MODMAP)"
	@echo "  link \"aprutil-1\"" >> "$(PACKAGE_MODMAP)"
	@echo "  export *" >> "$(PACKAGE_MODMAP)"
	@echo "}" >> "$(PACKAGE_MODMAP)"
	@echo "" >> "$(PACKAGE_MODMAP)"
	@echo "module CApache [system] {" >> "$(PACKAGE_MODMAP)"
	@echo "  use CAPR" >> "$(PACKAGE_MODMAP)"
	@echo "  use CAPRUtil" >> "$(PACKAGE_MODMAP)"
	@echo "  header \"$(SWIFT_SHIM_INSTALL_DIR)/Apache2Shim.h\"" >> "$(PACKAGE_MODMAP)"
	@echo "  export *" >> "$(PACKAGE_MODMAP)"
	@echo "}" >> "$(PACKAGE_MODMAP)"

# conf-load

$(PACKAGE_MODULE_LOAD_FILE) : $(wildcard config.make)
	@echo "LoadModule $(PACKAGE) $(APACHE_MODULE_INSTALL_DIR)/$(APACHE_C_MODULE_INSTALL_NAME)" > "$(PACKAGE_MODULE_LOAD_FILE)"

