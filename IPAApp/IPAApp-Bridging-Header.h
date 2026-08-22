//
//  IPAApp-Bridging-Header.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/stat.h>

// Import exploit headers
#import "mcm_bridge.h"
#import "vnode.h"
#import "krw.h"
#import "kutils.h"
#import "sandbox_escape.h"

// Kernel exploit functions
int kexploit_opa334(void);
uint64_t proc_self(void);

// Sandbox escape functions
BOOL escapeSandbox(void);
int sandbox_escape(uint64_t self_proc);
int sandbox_elevate_to_root(uint64_t self_proc);

// MCM bridge functions (QUAN TRỌNG - cần cho DownloadManager)
NSString *MCMActivateContainerPath(uint64_t cls, NSString *identifier, BOOL group, NSString **error);
NSString *MCMContainerPathForIdentifier(uint64_t cls, NSString *identifier, BOOL group, NSString **error);
BOOL MCMBridgeAvailable(void);
NSArray<NSString *> *MCMEnumerateIdentifiersForClass(uint64_t cls, NSUInteger limit, NSString **error);

// Kernel file write (iOS 15-16 fallback)
int kfp_write_file(const char *src, const char *dst);
