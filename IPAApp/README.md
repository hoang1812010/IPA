# IPA Tool - iOS Application

Ứng dụng iOS với giao diện tối màu hiện đại, có chức năng tải file từ remote và ghi đè lên file target cố định sử dụng kernel exploit.

## Cấu trúc dự án

```
IPAApp/
├── IPAApp/
│   ├── IPAAppApp.swift          # Entry point
│   ├── ContentView.swift         # View chính chuyển đổi giữa Login và Main
│   ├── LoginView.swift           # Màn hình nhập key kích hoạt
│   ├── MainView.swift            # Màn hình chính với các chức năng
│   ├── DownloadManager.swift     # Xử lý tải file và ghi đè
│   └── Info.plist                # Configuration
└── IPAApp.xcodeproj/
    └── project.pbxproj
```

## Tính năng

### 1. Màn hình đăng nhập
- Hiển thị Device ID (UDID) của thiết bị
- Nhập activation key
- Validate key với server (cần cấu hình URL server)
- Ràng buộc key với thiết bị

### 2. Màn hình chính
- **Chọn Bundle**: 
  - `com.dts.freefireth` (Free Fire TH)
  - `com.dts.freefiremax` (Free Fire Max)
  
- **4 Chức năng** (chỉ bật được 1 chức năng tại một thời điểm):
  - Nhẹ Tâm
  - Proxy Body
  - Proxy Neck
  - Proxy Drag

### 3. Cơ chế hoạt động
Khi người dùng chọn một chức năng:
1. Tải file data từ URL tương ứng
2. Sử dụng kernel exploit để vượt qua sandbox
3. Ghi đè lên file target tại đường dẫn:
   ```
   /private/var/mobile/Containers/Data/Application/<bundle>/Library/Caches/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D
   ```

## Cấu hình

### 1. Cấu hình URL download cho từng chức năng

Mở file `MainView.swift` và thay đổi các URL trong `featureURLs`:

```swift
let featureURLs: [String: String] = [
    "nhe_tam": "https://yourserver.com/data/nhe_tam.bin",
    "proxy_body": "https://yourserver.com/data/proxy_body.bin",
    "proxy_neck": "https://yourserver.com/data/proxy_neck.bin",
    "proxy_drag": "https://yourserver.com/data/proxy_drag.bin"
]
```

### 2. Cấu hình server validation key

Mở file `DownloadManager.swift` và thay đổi `serverURL`:

```swift
var serverURL: String = "https://yourserver.com/api/validate"
```

Server cần trả về JSON format:
```json
{
    "valid": true,
    "message": "Key hợp lệ"
}
```

### 3. Tích hợp Kernel Exploit

Để chức năng ghi đè file hoạt động, bạn cần tích hợp code exploit từ repository:

#### Bước 1: Thêm files exploit vào project

Copy các file sau từ repo vào project Xcode:
- Từ thư mục `kexploit/`:
  - `kexploit_opa334.h` và `kexploit_opa334.m`
  - `vnode.h` và `vnode.m`
  - `sandbox_escape.h` và `sandbox_escape.m`
  - `krw.h` và `krw.m`
  - `kutils.h` và `kutils.m`
  - `offsets.h` và `offsets.m`
  - `machine_info.h`
  - `xpaci.h`

- Từ thư mục `exploit/`:
  - `bad_query.c` và `bad_query.h`
  - `wallpaper_zip.c` và `wallpaper_zip.h`
  - `mcm_bridge.h` và `mcm_bridge.m`

#### Bước 2: Tạo bridging header

Tạo file `IPAApp-Bridging-Header.h`:

```objc
#ifndef IPAApp_Bridging_Header_h
#define IPAApp_Bridging_Header_h

#import "vnode.h"
#import "sandbox_escape.h"
#import "kexploit_opa334.h"

#endif
```

#### Bước 3: Update DownloadManager.swift

Thay thế placeholder trong hàm `replaceTargetFile`:

```swift
// Thay vì:
let success = true // Placeholder

// Sử dụng:
let success = vnode_overwrite(targetPath, fileData.bytes, fileData.count)
```

Hoặc sử dụng sandbox escape:

```swift
let success = sandbox_escape_and_write(targetPath, fileData.bytes, fileData.count)
```

## Build và Export

### Yêu cầu:
- macOS với Xcode 15.0+
- Apple Developer Account (để ký app)
- iOS 15.0+ deployment target

### Các bước build:

1. Mở `IPAApp.xcodeproj` trong Xcode
2. Chọn team signing trong project settings
3. Build project (Cmd + B)
4. Archive và export IPA

### Export IPA:

```bash
# Build archive
xcodebuild -project IPAApp.xcodeproj -scheme IPAApp -configuration Release -archivePath ./IPAApp.xcarchive archive

# Export IPA
xcodebuild -exportArchive -archivePath ./IPAApp.xcarchive -exportPath ./ -exportOptionsPlist ExportOptions.plist
```

## Lưu ý quan trọng

⚠️ **Cảnh báo**: 
- Ứng dụng này sử dụng kernel exploit và chỉ hoạt động trên các thiết bị chưa được vá lỗi bảo mật
- Chỉ sử dụng cho mục đích học tập và nghiên cứu
- Không chịu trách nhiệm cho bất kỳ thiệt hại nào xảy ra

## TODO

- [ ] Tích hợp đầy đủ kernel exploit từ repository
- [ ] Thêm cơ chế kiểm tra phiên bản iOS hỗ trợ
- [ ] Thêm logging chi tiết cho debugging
- [ ] Tối ưu hóa UI/UX
- [ ] Thêm tính năng backup file gốc trước khi ghi đè

## License

Chỉ sử dụng cho mục đích giáo dục và nghiên cứu.
