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
    NSLog(@"[MHA] Mounting container for bundle ID: %@", bundleID);
    
    // Với MHA-C2, khi có đúng entitlements, FileManager có thể truy cập trực tiếp
    // Trả về đường dẫn container tiêu chuẩn của iOS
    NSString *containerPath = [NSString stringWithFormat:@"/private/var/mobile/Containers/Data/Application/%@", bundleID];
    return containerPath;
}

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
    BOOL success = [fm copyItemAtPath:patchPath toPath:containerPath error:error];
    
    if (success) {
        NSLog(@"[MHA] ✅ Inject successful!");
    } else {
        NSLog(@"[MHA] ❌ Inject failed: %@", *error);
    }
    
    return success;
}

@end
