# 日记应用

这是一个简洁、唯美的日记应用示例，支持：
- 新建日记
- 插入图片（相机 / 相册）
- 自动记录日期与时间
- 获取当前天气
- 本地存储到 Hive

## 功能概览
- 纯净白/淡色视觉风格
- 时间 + 天气标注
- 图片展示与卡片列表
- 轻量本地数据库，无需后端

## 运行步骤

1. 安装 Flutter SDK，并确保已运行 `flutter doctor` 通过。
2. 在项目根目录执行：

```bash
flutter pub get
```

3. 运行：

```bash
flutter run
```

## 配置天气 API

本示例使用 OpenWeatherMap 获取实时天气。你需要在 `lib/screens/editor.dart` 中替换以下字段：

```dart
const weatherApiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
```

获取步骤：
- 注册 OpenWeatherMap 账号
- 创建 API Key
- 替换为自己的 key

## Android 权限

在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## iOS 权限

在 `ios/Runner/Info.plist` 中添加：

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>用于获取当前位置以展示天气信息</string>
<key>NSCameraUsageDescription</key>
<string>用于拍照并插入日记</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>用于选择图片插入日记</string>
```

## 说明

这是一个轻量开发版，适合你先快速验证产品方向；后续可以再扩展：
- 搜索与标签
- 月份归档
- 云同步
- 情绪打分
- 导出 PDF / 图片分享
