#import "MHAController.h"

@implementation MHAController

- (BOOL)applyPatchFromFile:(NSString *)patchPath toContainerPath:(NSString *)containerPath error:(NSError **)error {
    NSLog(@"[MHA] Applying patch from %@ to %@", patchPath, containerPath);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // 1. Tạo thư mục đích nếu chưa có
    NSString *destDir = [containerPath stringByDeletingLastPathComponent];
    if (![fm fileExistsAtPath:destDir]) {
        [fm createDirectoryAtPath:destDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 2. Xóa file cũ nếu có
    if ([fm fileExistsAtPath:containerPath]) {
        [fm removeItemAtPath:containerPath error:nil];
    }
    
    // 3. Copy file mod vào container của Free Fire
    // (Nhờ Entitlements com.apple.private.security.storage.AppDataContainers, 
    // FileManager có quyền ghi vào container của app khác)
    BOOL success = [fm copyItemAtPath:patchPath toPath:containerPath error:error];
    
    if (success) {
        NSLog(@"[MHA] ✅ Inject successful!");
    } else {
        NSLog(@"[MHA] ❌ Inject failed: %@", *error);
    }
    
    return success;
}

@end
