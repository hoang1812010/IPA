//
//  IPAApp-Bridging-Header.h
//  IPAApp
//

#ifndef IPAApp_Bridging_Header_h
#define IPAApp_Bridging_Header_h

// Import kernel exploit headers
#import "kexploit_opa334.h"
#import "krw.h"
#import "kutils.h"
#import "sandbox_escape.h"

// Khai báo hàm C từ kernel exploit
int kfp_write_file(const char *src, const char *dst);

#endif
