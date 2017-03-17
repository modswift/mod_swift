//
// Copyright (C) 2017 ZeeZide GmbH, All Rights Reserved
// Created by Helge Hess on 23/01/2017.
//

#ifndef __mod_swift_H__
#define __mod_swift_H__

#include <httpd.h>

#if defined(__clang__)
#  if __linux__
#    define apz_non_null // hm? shouldn't that work on Linux? (3.8.0)
#  else
#    define apz_non_null __nonnull
#  endif
#  define apz_swift_name(__X__) __attribute__((swift_name(__X__)))
#else
#  define apz_non_null
#  define apz_swift_name(__X__)
#endif

#pragma mark ApacheRequest

struct ApacheRequest {
  // own struct which hides the swiftc-crash-prone Apache C structure
  request_rec * apz_non_null raw;
};

extern struct ApacheRequest ApacheRequestCreate(void * apz_non_null raw)
                apz_swift_name("ApacheRequest.init(raw:)");


#pragma mark Logging
// Helpers required because Swift doesn't support C vararg funcs

extern void apz_log_rerror_(const char *file, int line, int module_index,
                            int level, apr_status_t status,
                            const request_rec *r, const char *s);
extern void apz_log_error_ (const char *file, int line, int module_index,
                            int level, apr_status_t status,
                            const server_rec *r, const char *s);


#pragma mark Bucket Brigade Helpers

extern apr_status_t apz_fwrite(struct ap_filter_t *f, apr_bucket_brigade *bb,
                               const void *data, apr_size_t nbyte);

extern void apz_brigade_insert_tail(apr_bucket_brigade *bb, apr_bucket *b);


#pragma mark Module Helpers

extern apr_status_t apz_register_swift_module(void *cmd, void *module);

#endif /* __mod_swift_H__ */
