#import "SandboxEscaper.h"
#import "bad_query.h"
#import "wallpaper_zip.h"
#import "mcm_bridge.h"

int run_bad_query(void);
int run_wallpaper_zip(void);
int run_mcm_bridge(void);

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
- (BOOL)applyPatchFromFile:(NSString *)patchPath 
         toContainerPath:(NSString *)containerPath 
                   error:(NSError **)error {
    NSLog(@"[MHA] Applying patch from %@ to %@", patchPath, containerPath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Check if source file exists
    if (![fileManager fileExistsAtPath:patchPath]) {
        if (error) {
            *error = [NSError errorWithDomain:@"MHAError" 
                                         code:404 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Source file not found"}];
        }
        return NO;
    }
    
    // Create destination directory if needed
    NSString *destDir = [containerPath stringByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:destDir]) {
        [fileManager createDirectoryAtPath:destDir 
               withIntermediateDirectories:YES 
                                attributes:nil 
                                     error:nil];
    }
    
    // Remove existing file if exists
    if ([fileManager fileExistsAtPath:containerPath]) {
        [fileManager removeItemAtPath:containerPath error:nil];
    }
    
    // Copy file
    BOOL success = [fileManager copyItemAtPath:patchPath 
                                        toPath:containerPath 
                                         error:error];
    
    if (success) {
        NSLog(@"[MHA] ✅ Patch applied successfully!");
    } else {
        NSLog(@"[MHA] ❌ Failed to apply patch: %@", *error);
    }
    
    return success;
}

@end
