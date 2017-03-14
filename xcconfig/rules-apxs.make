# GNUmakefile


ifeq ($(USE_APXS),no)
  ifeq ($(UNAME_S),Darwin)
    $(error missing Apache apxs, did you brew install homebrew/apache/httpd24?)
  else
    $(error missing Apache apxs, did you install apache2-dev?)
  endif
endif


APXS_OUTDIR = .libs
APACHE_C_MODULE_BUILD_RESULT = $(APXS_OUTDIR)/$(PACKAGE)$(APACHE_MODULE_SUFFIX)
APACHE_C_MODULE_INSTALL_NAME = $(PACKAGE)$(APACHE_MODULE_SUFFIX)

MOD_SWIFT_PKGCONFIG = $(APXS_OUTDIR)/$(PACKAGE).pc

HEADER_FILES_INSTALL_PATHES = $(addprefix $(HEADER_FILES_INSTALL_DIR)/,$(HFILES))

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

all : $(APACHE_C_MODULE_BUILD_RESULT) $(MOD_SWIFT_PKGCONFIG)

clean :
	rm -f $(APXS_BUILD_FILES) $(MOD_SWIFT_PKGCONFIG)

distclean : clean
	rm -rf .libs
	rm -f config.make

install : $(APACHE_C_MODULE_BUILD_RESULT)
	$(MKDIR_P) $(APACHE_MODULE_INSTALL_DIR)
	$(MKDIR_P) $(HEADER_FILES_INSTALL_DIR)
	$(MKDIR_P) $(PKGCONFIG_INSTALL_DIR)
	cp $(APACHE_C_MODULE_BUILD_RESULT) \
	   $(APACHE_MODULE_INSTALL_DIR)/$(APACHE_C_MODULE_INSTALL_NAME)
	cp $(HFILES) $(HEADER_FILES_INSTALL_DIR)/
	#cp $(PKGCONFIG_FILE) $(PKGCONFIG_INSTALL_DIR)/

uninstall :
	rm -f $(APACHE_MODULE_INSTALL_DIR)/$(APACHE_C_MODULE_INSTALL_NAME) \
	      $(HEADER_FILES_INSTALL_PATHES) \
	      $(PKGCONFIG_INSTALL_DIR)/mod_swift.pc

LIBTOOL_CPREFIX=-Wc,
LIBTOOL_LDPREFIX=-Wl,
APXS_EXTRA_CFLAGS_LIBTOOL  = $(addprefix $(LIBTOOL_CPREFIX),$(APXS_EXTRA_CFLAGS))
APXS_EXTRA_LDFLAGS_LIBTOOL = $(addprefix $(LIBTOOL_LDPREFIX),$(APXS_EXTRA_LDFLAGS))
APXS_LIBTOOL_BUILD_RESULT  = .libs/$(PACKAGE).so

$(APACHE_C_MODULE_BUILD_RESULT) : $(CFILES)
	@mkdir -p $(@D)
	$(APXS) $(APXS_EXTRA_CFLAGS_LIBTOOL) $(APXS_EXTRA_LDFLAGS_LIBTOOL) \
	  -n $(PACKAGE)    \
	  -o $(PACKAGE).so \
          -c $(CFILES)


# TODO: pkgconfig

$(MOD_SWIFT_PKGCONFIG) :
	touch "$(MOD_SWIFT_PKGCONFIG)"


# config test

testconfig:
	@echo "Brew:               $(BREW)"
	@echo "Use brew:           $(USE_BREW)"
	@echo "Prefix:             $(prefix)"
	@echo "Install module in:  $(APACHE_MODULE_INSTALL_DIR)"
	@echo "Install headers in: $(HEADER_FILES_INSTALL_DIR)"
	@echo "Install pc in:      $(PKGCONFIG_INSTALL_DIR)"

