#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/stat.h>

// Kernel exploit functions
int kfp_write_file(const char *src, const char *dst);

// Sandbox escape functions
BOOL escapeSandbox(void);
uint64_t proc_self(void);
int sandbox_escape(uint64_t self_proc);

// MCM functions (QUAN TRỌNG!)
NSString *MCMActivateContainerPath(uint64_t cls, NSString *identifier, BOOL group, NSString **error);
NSString *MCMContainerPathForIdentifier(uint64_t cls, NSString *identifier, BOOL group, NSString **error);
BOOL MCMBridgeAvailable(void);
