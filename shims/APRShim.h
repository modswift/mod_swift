#ifndef __APR_SWIFT_SHIM_H__
#define __APR_SWIFT_SHIM_H__

#ifdef __linux__
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
