#import "MHAController.h"

@implementation MHAController

+ (instancetype)shared {
    static MHAController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MHAController alloc] init];
    });
    return instance;
}

- (NSString *)mountContainerForBundleID:(NSString *)bundleID error:(NSError **)error {
    NSLog(@"[MHA] 🔍 Mounting container for bundle ID: %@", bundleID);
    
    NSString *containerBasePath = @"/private/var/mobile/Containers/Data/Application";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *enumError = nil;
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:containerBasePath error:&enumError];
    
    if (enumError) {
        NSLog(@"[MHA] ❌ Error enumerating containers: %@", enumError);
        if (error) *error = enumError;
        return nil;
    }
    
    for (NSString *uuid in contents) {
        NSString *containerPath = [containerBasePath stringByAppendingPathComponent:uuid];
        
        // Method 1: Check metadata plist (most reliable)
        NSString *metadataPath = [containerPath stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];
        
        if ([fileManager fileExistsAtPath:metadataPath]) {
            NSDictionary *metadata = [NSDictionary dictionaryWithContentsOfFile:metadataPath];
            NSString *mcBundleID = metadata[@"MCMMetadataIdentifier"];
            
            if ([mcBundleID isEqualToString:bundleID]) {
                NSLog(@"[MHA] ✅ Found container via metadata: %@", containerPath);
                return containerPath;
            }
        }
        
        // Method 2: Check Info.plist (fallback)
        NSString *infoPlistPath = [containerPath stringByAppendingPathComponent:@".com.apple.mobile_container_manager.metadata.plist"];
        NSString *appInfoPlistPath = [containerPath stringByAppendingPathComponent:@"Info.plist"];
        
        if ([fileManager fileExistsAtPath:appInfoPlistPath]) {
            NSDictionary *appInfo = [NSDictionary dictionaryWithContentsOfFile:appInfoPlistPath];
            NSString *cfBundleID = appInfo[@"CFBundleIdentifier"];
            
            if ([cfBundleID isEqualToString:bundleID]) {
                NSLog(@"[MHA] ✅ Found container via Info.plist: %@", containerPath);
                return containerPath;
            }
        }
    }
    
    NSLog(@"[MHA] ❌ Container not found for bundle ID: %@", bundleID);
    if (error) {
        *error = [NSError errorWithDomain:@"MHAError"
                                     code:404
                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Container not found for %@", bundleID]}];
    }
    return nil;
}

- (BOOL)applyPatchFromFile:(NSString *)patchPath toContainerPath:(NSString *)containerPath error:(NSError **)error {
    NSLog(@"[MHA] 📝 Applying patch");
    NSLog(@"[MHA]   From: %@", patchPath);
    NSLog(@"[MHA]   To:   %@", containerPath);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Check source exists
    if (![fm fileExistsAtPath:patchPath]) {
        NSLog(@"[MHA] ❌ Source file not found: %@", patchPath);
        if (error) {
            *error = [NSError errorWithDomain:@"MHAError"
                                         code:404
                                     userInfo:@{NSLocalizedDescriptionKey: @"Source file not found"}];
        }
        return NO;
    }
    
    // Create destination directory
    NSString *destDir = [containerPath stringByDeletingLastPathComponent];
    if (![fm fileExistsAtPath:destDir]) {
        NSError *createError = nil;
        BOOL created = [fm createDirectoryAtPath:destDir
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:&createError];
        if (!created) {
            NSLog(@"[MHA] ❌ Failed to create directory: %@", createError);
            if (error) *error = createError;
            return NO;
        }
        NSLog(@"[MHA] ✅ Created directory: %@", destDir);
    }
    
    // Remove existing file
    if ([fm fileExistsAtPath:containerPath]) {
        NSError *removeError = nil;
        [fm removeItemAtPath:containerPath error:&removeError];
        if (removeError) {
            NSLog(@"[MHA] ⚠️ Warning removing old file: %@", removeError);
        } else {
            NSLog(@"[MHA] ✅ Removed old file");
        }
    }
    
    // Copy file
    NSError *copyError = nil;
    BOOL success = [fm copyItemAtPath:patchPath toPath:containerPath error:&copyError];
    
    if (success) {
        NSDictionary *attrs = [fm attributesOfItemAtPath:containerPath error:nil];
        NSLog(@"[MHA] ✅ Inject successful! Size: %@ bytes", attrs[NSFileSize]);
    } else {
        NSLog(@"[MHA] ❌ Inject failed: %@", copyError);
        if (error) *error = copyError;
    }
    
    return success;
}

@end
