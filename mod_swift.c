//
// Copyright (C) 2017 ZeeZide GmbH, All Rights Reserved
// Created by Helge Hess on 23/01/2017.
//

#include <httpd.h>
#include <http_protocol.h>
#include <http_config.h>

#include <apr_strings.h>

#include <assert.h>


#pragma mark Swift Loading Module Logic

static const char *cmdLoadSwiftModule
  (cmd_parms *cmd, void *cfg, const char *entryPoint, const char *shlib)
{
  // Insipired my LoadModule ;->
  char errbuf[256];
  
  const char *modpath = ap_server_root_relative(cmd->temp_pool, shlib);
  //printf("%s: %s %s %s\n", cmd->cmd->name, entryPoint, shlib, filename);
  
  if (modpath == NULL) {
    return apr_psprintf(cmd->temp_pool, "Invalid %s path %s",
                        cmd->cmd->name, modpath);
  }

  apr_dso_handle_t *fh = NULL;
  if (apr_dso_load(&fh, modpath, cmd->pool) != APR_SUCCESS) {
    return apr_pstrcat(cmd->temp_pool, "Cannot load ", modpath,
                       " into server: ",
                       apr_dso_error(fh, errbuf, sizeof(errbuf)),
                       NULL);
  }
  
  apr_dso_handle_sym_t eph = NULL;
  if (apr_dso_sym(&eph, fh, entryPoint) != APR_SUCCESS || eph == NULL) {
    eph = NULL;
  }
  
  if (eph == NULL) {
    // _TF16mods_expressdemo10ApacheMainFT3cmdVs13OpaquePointer_T_
    // mangingling:
    //   _TF16mods_expressdemo [16]
    //   10ApacheMain          [10]
    //   FT 3cmd Vs13OpaquePointer_T_
    // _TF16mods_expressdemo10ApacheMain F Vs13OpaquePointerT_
    
    const char *bn = rindex(modpath, '/');
    if (bn != NULL) bn++;
    else bn = modpath;

    const char *dotidx = index(bn, '.');
    const char *moduleName;
    if (dotidx == NULL)
      moduleName = apr_pstrdup(cmd->pool, bn);
    else
      moduleName = apr_pstrndup(cmd->pool, bn, dotidx - bn);
    
    size_t modlen = strlen(moduleName);
    size_t eplen  = strlen(entryPoint);
    
    const char *mep;
    
    const char *typeVariants[] = {
      // Swift 3.0
      "FVs13OpaquePointerT_",           // ApacheMain(_:)
      "FT3cmdVs13OpaquePointerT_",      // ApacheMain(cmd:)
      "FT7commandVs13OpaquePointerT_",  // ApacheMain(command:)
      // Swift 3.1 (is that change for realz?)
      "FVs13OpaquePointer_T_",          // ApacheMain(_:)
      "FT3cmdVs13OpaquePointer_T_",     // ApacheMain(cmd:)
      "FT7commandVs13OpaquePointer_T_", // ApacheMain(command:)
      NULL
    };
    
    for (const char **p = typeVariants; eph == NULL && *p != NULL; p++) {
      const char *mep = apr_psprintf(cmd->pool,
                                     "_TF%lu%s%lu%s%s",
                                     modlen, moduleName, eplen, entryPoint, *p);
      if (apr_dso_sym(&eph, fh, mep) != APR_SUCCESS || eph == NULL) {
        eph = NULL;
      }
    }
    
    if (eph == NULL && strstr(moduleName, "mods_") == moduleName) {
      for (const char **p = typeVariants; eph == NULL && *p != NULL; p++) {    
        const char *mep = apr_psprintf(cmd->pool,
                                       "_TF%lu%s%lu%s%s",
                                       modlen - 5, moduleName + 5, 
                                       eplen, entryPoint, *p);
        if (apr_dso_sym(&eph, fh, mep) != APR_SUCCESS || eph == NULL) {
          eph = NULL;
        }
      }
    }
  }
  
  
  if (eph == NULL) {
    return apr_pstrcat(cmd->pool, "Can't locate Swift entrypoint function `",
                       entryPoint, "' in file ", modpath, ": ",
                       apr_dso_error(fh, errbuf, sizeof(errbuf)),
                       NULL);
  }
  
  // OK, pass over control to Swift (do we need to pass over a pool or sth?)
  void (*fn)(cmd_parms *) = eph;
  fn(cmd);
    
  return NULL;
}

static const command_rec commands[] = {
  AP_INIT_TAKE2("LoadSwiftModule", cmdLoadSwiftModule,
                NULL, RSRC_CONF, "Load a Swift Apache module"),
  { NULL }
};

int pre_config(apr_pool_t *pconf,apr_pool_t *plog, apr_pool_t *ptemp) {
  ap_reserve_module_slots(8); // hh: guesswork. 8 Swift mods max?
  return OK;
}

static void hooks(apr_pool_t *_pool) {
  ap_hook_pre_config(pre_config, NULL, NULL, APR_HOOK_MIDDLE);
}

module AP_MODULE_DECLARE_DATA swift_module = {
  STANDARD20_MODULE_STUFF,
  NULL,     /* per-directory config creator */
  NULL,     /* dir config merger */
  NULL,     /* server config creator */
  NULL,     /* server config merger */
  commands, /* command table */
  hooks     /* hooks */
};
