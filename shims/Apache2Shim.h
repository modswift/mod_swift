#ifndef __Apache2Shim_H__
#define __Apache2Shim_H__

#ifdef __linux__
  /* Hack required on Raspberry Pi, probably due to incorrect -D (which we can't pass to
   * SPM via pkgconfig).
   */
#  ifdef __ARM_EABI__
     // off64_t is undefined (32bit Xenial on RaspberryPi)
     typedef signed long long int off64_t;
#  endif

#  include <termios.h>
#endif

#include "httpd.h"
#include "http_protocol.h"
#include "http_config.h"
#include "http_core.h"
#include "http_log.h"
#include "http_request.h"

#include "apr_dbd.h" // mod_dbd requires this
#include "mod_dbd.h"

#include "mod_swift.h"

#endif /* __Apache2Shim_H__ */
