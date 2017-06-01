#ifndef __APRUTIL_SWIFT_SHIM_H__
#define __APRUTIL_SWIFT_SHIM_H__

#ifdef __linux__
  /* Hack required on Raspberry Pi, probably due to incorrect -D (which we can't pass to
   * SPM via pkgconfig).
   */
#  ifdef __ARM_EABI__
     // off64_t is undefined (32bit Xenial on RaspberryPi)
     typedef signed long long int off64_t;
#  endif
#endif
     
#include "apu.h"
#include "apr_buckets.h"
#include "apr_dbd.h"
#include "apr_xml.h"

#endif /* __APRUTIL_SWIFT_SHIM_H__ */
