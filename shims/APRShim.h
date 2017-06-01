#ifndef __APR_SWIFT_SHIM_H__
#define __APR_SWIFT_SHIM_H__

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

#include "apr.h"
#include "apr_tables.h"
#include "apr_pools.h"
#include "apr_network_io.h"
#include "apr_file_io.h"
#include "apr_general.h"
#include "apr_mmap.h"
#include "apr_errno.h"
#include "apr_ring.h"
#include "apr_strings.h"
#include "apr_time.h"

#include "apr_thread_proc.h"

#endif /* __APR_SWIFT_SHIM_H__ */
