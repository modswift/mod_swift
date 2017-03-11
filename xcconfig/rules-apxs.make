# GNUmakefile

APXS_OUTDIR = .libs
APACHE_C_MODULE_BUILD_RESULT = $(APXS_OUTDIR)/$(PACKAGE)$(APACHE_MODULE_SUFFIX)
APACHE_C_MODULE_INSTALL_NAME = $(PACKAGE)$(APACHE_MODULE_SUFFIX)

all : $(APACHE_C_MODULE_BUILD_RESULT)

clean :
	rm -f $(APACHE_C_MODULE_BUILD_RESULT) \
		*.lo *.o *.slo *.la *.lo \
		$(APXS_OUTDIR)/*.o   \
		$(APXS_OUTDIR)/*.a   \
		$(APXS_OUTDIR)/*.lai \
		$(APXS_OUTDIR)/*.la  \
		$(APXS_OUTDIR)/*.so

distclean : clean
	rm -rf .libs
	rm -f config.make

install : $(APACHE_C_MODULE_BUILD_RESULT)
	cp $(APACHE_C_MODULE_BUILD_RESULT) \
	   $(prefix)/$(APACHE_C_MODULE_INSTALL_NAME)

uninstall :
	rm -f $(prefix)/$(APACHE_C_MODULE_INSTALL_NAME)

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

