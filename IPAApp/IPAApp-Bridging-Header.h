//
//  IPAApp-Bridging-Header.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "mcm_bridge.h"
#import "vnode.h"
#import "krw.h"
#import "kutils.h"
#import "sandbox_escape.h"

// Kernel exploit functions
int kexploit_init(void);
int kfp_write_file(const char *src, const char *dst);
int32_t kexploit_find_container(const char *bundleID, char *uuidBuffer, int32_t bufferSize);

// Sandbox escape functions
BOOL escapeSandbox(void);
int sandbox_escape(uint64_t self_proc);
int sandbox_elevate_to_root(uint64_t self_proc);

// MCM bridge functions
NSString *MCMActivateContainerPath(uint64_t cls, NSString *identifier, BOOL group, NSString **error);
NSString *MCMContainerPathForIdentifier(uint64_t cls, NSString *identifier, BOOL group, NSString **error);
BOOL MCMBridgeAvailable(void);
