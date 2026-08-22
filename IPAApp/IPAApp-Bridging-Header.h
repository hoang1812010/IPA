//
//  IPAApp-Bridging-Header.h
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Kernel exploit functions (iOS 15-16)
int kfp_write_file(const char *src, const char *dst);

// Sandbox escape functions
BOOL escapeSandbox(void);
