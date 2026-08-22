#import <Foundation/Foundation.h>

// Stub cho kernel exploit
int kfp_write_file(const char *src, const char *dst) {
    NSLog(@"[Stubs] kfp_write_file called (no-op)");
    return 0; // luôn thành công
}

// Stubs cho userspace exploits
int run_bad_query(void) {
    NSLog(@"[Stubs] run_bad_query called (no-op)");
    return 0;
}

int run_wallpaper_zip(void) {
    NSLog(@"[Stubs] run_wallpaper_zip called (no-op)");
    return 0;
}

int run_mcm_bridge(void) {
    NSLog(@"[Stubs] run_mcm_bridge called (no-op)");
    return 0;
}
