# Web 版 — 唯美日记

项目已从 Flutter 移植为 Web（React + Vite）启动版，功能对齐移动版的最小可行实现：

- 新建日记（标题、正文）
- 插入图片（本地文件，转为 base64 存储在 localStorage）
- 时间选择（datetime-local）
- 获取天气（使用 OpenWeatherMap + 浏览器定位）
- 本地存储：localStorage（key = diary_entries_v1）

快速运行：

1. 安装依赖

```bash
npm install
```

2. 本地调试

```bash
npm run dev
```

3. 构建

```bash
npm run build
```

注意事项：
- 请在 src/components/Editor.jsx 中把 WEATHER_API_KEY 替换为你自己的 OpenWeatherMap Key 才能使用天气功能。
- 当前数据保存在浏览器 localStorage，换设备或清除浏览器数据会丢失。
- 图片以 base64 存储，若需要长期大量图片建议改为上传或使用 IndexedDB / 后端存储。

下一步建议：
- 添加登陆/云同步（Firebase / 自建后端）
- 支持 Markdown / 富文本
- 日记导出（PDF / 图片）
