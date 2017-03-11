# GNUmakefile

APXS_OUTDIR = .libs
APACHE_C_MODULE_BUILD_RESULT = $(APXS_OUTDIR)/$(PACKAGE)$(APACHE_MODULE_SUFFIX)
APACHE_C_MODULE_INSTALL_NAME = $(PACKAGE)$(APACHE_MODULE_SUFFIX)

MOD_SWIFT_PKGCONFIG = $(APXS_OUTDIR)/$(PACKAGE).pc

all : $(APACHE_C_MODULE_BUILD_RESULT) $(MOD_SWIFT_PKGCONFIG)

clean :
	rm -f $(APACHE_C_MODULE_BUILD_RESULT) $(MOD_SWIFT_PKGCONFIG) \
		*.lo *.o *.slo *.la *.lo \
		$(APXS_OUTDIR)/*.o   \
		$(APXS_OUTDIR)/*.a   \
		$(APXS_OUTDIR)/*.lai \
		$(APXS_OUTDIR)/*.la  \
		$(APXS_OUTDIR)/*.so

distclean : clean
	rm -rf .libs
	rm -f config.make

# TODO: prefix should be the parent, then $prefix/libexec, $prefix/lib/pkgconfig
install : all
	cp $(APACHE_C_MODULE_BUILD_RESULT) \
	   $(prefix)/$(APACHE_C_MODULE_INSTALL_NAME)
	#cp $(MOD_SWIFT_PKGCONFIG) \
	#   $(prefix)/$(APACHE_C_MODULE_INSTALL_NAME)

uninstall :
	rm -f $(prefix)/$(APACHE_C_MODULE_INSTALL_NAME)


# actual rules

ifeq ($(USE_APXS),no)
  ifeq ($(UNAME_S),Darwin)
    $(error missing Apache apxs, did you brew install homebrew/apache/httpd24?)
  else
    $(error missing Apache apxs, did you install apache2-dev?)
  endif
endif



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

$(MOD_SWIFT_PKGCONFIG) :
	touch "$(MOD_SWIFT_PKGCONFIG)"
