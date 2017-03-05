# GNUmakefile

# Variables to set:
#   xyz_SWIFT_MODULES          - modules in the same package
#   xyz_EXTERNAL_SWIFT_MODULES - modules in a different package
#   xyz_TYPE - [tool / library]
#   xys_INCLUDE_DIRS
#   xys_LIB_DIRS
#   xys_LIBS

ifeq ($($(PACKAGE)_TYPE),ApacheCModule)
  ifeq ($(USE_APXS),no)
    ifeq ($(UNAME_S),Darwin)
      $(error missing Apache apxs)
    else
      $(error missing Apache apxs, did you install apache2-dev?)
    endif
  else
    LIBTOOL_CPREFIX=-Wc,
    LIBTOOL_LDPREFIX=-Wl,
    APXS_EXTRA_CFLAGS_LIBTOOL  = $(addprefix $(LIBTOOL_CPREFIX),$(APXS_EXTRA_CFLAGS))
    APXS_EXTRA_LDFLAGS_LIBTOOL = $(addprefix $(LIBTOOL_LDPREFIX),$(APXS_EXTRA_LDFLAGS))
    APXS_LIBTOOL_BUILD_RESULT  = .libs/$(PACKAGE).so
  endif
endif


# rules

ifeq ($($(PACKAGE)_TYPE),ApacheCModule)
all : all-apache-c-module
endif

APACHE_C_MODULE_BUILD_RESULT = $(SWIFT_BUILD_DIR)/$(PACKAGE).so

clean :
	rm -rf $(TOOL_BUILD_RESULT) $(LIBRARY_BUILD_RESULT) \
	       $(APACHE_C_MODULE_BUILD_RESULT) $(APACHE_SWIFT_MODULE_BUILD_RESULT) \
	       *.o *.slo *.la *.lo Sources/*.o Sources/*.slo Sources/*.la Sources/*.lo \
	       .libs Sources/.libs
# rm -rf $(SWIFT_BUILD_DIR)

all-apache-c-module : $(APACHE_C_MODULE_BUILD_RESULT)


ifeq ($($(PACKAGE)_TYPE),ApacheCModule)
# Note: Cannot change target location via apxs -o, hence
#       we move it over after the build.
$(APACHE_C_MODULE_BUILD_RESULT) : $($(PACKAGE)_C_FILES)
	@mkdir -p $(@D)
	$(APXS) $(APXS_EXTRA_CFLAGS_LIBTOOL) $(APXS_EXTRA_LDFLAGS_LIBTOOL) \
	  -n $(PACKAGE)    \
	  -o $(PACKAGE).so \
          -c $($(PACKAGE)_C_FILES)
	rm -f $(APACHE_C_MODULE_BUILD_RESULT)
	# mv $(APXS_LIBTOOL_BUILD_RESULT) $(APACHE_C_MODULE_BUILD_RESULT)
endif

# load extra rules

-include rules-$($(PACKAGE)_TYPE).make
