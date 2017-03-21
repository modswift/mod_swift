#ifndef __Apache2Shim_H__
#define __Apache2Shim_H__

#ifdef __linux__
#  include <termios.h>
#endif

#include "httpd.h"
#include "http_protocol.h"
#include "http_config.h"
#include "http_core.h"
#include "http_log.h"

#include "apr_dbd.h" // mod_dbd requires this
#include "mod_dbd.h"

#include "mod_swift.h"

#endif /* __Apache2Shim_H__ */
