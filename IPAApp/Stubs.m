#import <Foundation/Foundation.h>

// Stub cho kernel exploit
int kfp_write_file(const char *src, const char *dst) {
    NSLog(@"[Stub] kfp_write_file called (no-op)");
    return 0; // luôn thành công
}

// Stub cho userspace exploits
int run_bad_query(void) {
    NSLog(@"[Stub] run_bad_query called (no-op)");
    return 0;
}

int run_wallpaper_zip(void) {
    NSLog(@"[Stub] run_wallpaper_zip called (no-op)");
    return 0;
}

int run_mcm_bridge(void) {
    NSLog(@"[Stub] run_mcm_bridge called (no-op)");
    return 0;
}
