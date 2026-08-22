// MHAController.h
#import <Foundation/Foundation.h>

@interface MHAController : NSObject

+ (instancetype)shared;

// Trả về đường dẫn container của app đích sau khi mount thành công
- (NSString *)mountContainerForBundleID:(NSString *)bundleID 
                                  error:(NSError **)error;

// Apply file vào container đã mount
- (BOOL)applyPatchFromFile:(NSString *)patchPath 
            toContainerPath:(NSString *)containerPath 
                      error:(NSError **)error;

@end
