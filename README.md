# 铁路运转日志 (Train Log)

面向铁路爱好者的安卓运转记录应用。

## 这是什么

铁路运转日志用于记录每次乘坐列车的详细信息。除了车次、日期、站点这些行程信息，它还会记录铁路迷真正关心的车辆信息——你坐的是哪一列动车组（型号、编号、编组、定员、配属），或者牵引这趟普速列车的是哪台机车（型号、编号、制造厂、牵引区间）。

主要特点：

- 记录车次、日期、站点、席别、车厢座位、里程、评分、备注
- 支持跨天行程（如 1 月 2 日出发、1 月 3 日到达）
- 动车组型号自动补全（内置常见车型库），选中后自动填写编组和定员
- 支持记录多台本务机车（换挂/重联），每台可分别填写牵引区间
- 按车次前缀自动识别列车类别（高铁/动车/城际/市郊/普速），列表支持组合筛选
- **车票样式**：每条记录都能渲染成一张仿真车票，长按可看大图、存相册、分享
- 购票信息：票价、检票口、购票标记（网购/儿童/折扣）、流水号与编号自动生成
- 数据导出 / 导入（JSON 备份），换手机也不丢记录
- 多种主题色与深色模式，可跟随系统

所有数据保存在手机本地（SQLite），离线可用，无需联网。

## 下载

安卓用户直接下载 APK 安装包即可使用：

[![GitHub Release](https://img.shields.io/github/v/release/zzzjjj-ss/train-log-app?label=%E6%9C%80%E6%96%B0%E7%89%88%E6%9C%AC)](https://github.com/zzzjjj-ss/train-log-app/releases/latest)

> **[下载最新版 APK](https://github.com/zzzjjj-ss/train-log-app/releases/latest)**

历史版本与更新说明见 [Releases 页面](https://github.com/zzzjjj-ss/train-log-app/releases)。

## 构建

环境要求：Flutter 3.44+，Android SDK 36

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

APK 输出：`build/app/outputs/flutter-apk/app-release.apk`

## 技术栈

| 技术 | 用途 |
|------|------|
| Flutter + Dart | UI 框架 |
| Riverpod | 状态管理 |
| drift | 本地数据库 |
| go_router | 路由 |
| shared_preferences | 设置持久化 |

## 项目结构

```
lib/
├── main.dart                  # 入口
├── app.dart                   # 根组件 + 路由
├── data/
│   ├── database.dart          # drift 数据库（表定义与迁移）
│   └── emu_models.dart        # 动车组车型库
├── providers/
│   └── providers.dart         # Riverpod Provider
├── screens/
│   ├── home_screen.dart       # 主页
│   ├── log_form_screen.dart   # 记录表单
│   ├── settings_screen.dart   # 设置
│   ├── about_screen.dart      # 关于
│   └── ticket_preview_screen.dart  # 车票大图预览
├── utils/
│   ├── train_classify.dart    # 车次前缀分类
│   └── ticket_gen.dart        # 流水号/编号生成
└── widgets/
    ├── log_card.dart          # 记录卡片
    └── ticket_card.dart       # 车票样式卡片（CustomPainter）
```

## 数据说明

- 动车组车型库数据来自路路通公开页面（http://wap.lltskb.com/shfw/lcxh/index.html），定员为参考值
- 机车、动车组编号等信息由用户自行记录

## 许可证

本项目采用 Mozilla Public License 2.0（MPL-2.0），详见 [LICENSE](LICENSE)。

- 修改本项目源文件的部分必须以 MPL-2.0 开源并保留署名
- 新增的独立文件可选择其他许可证
- 分发需附带许可证全文

## 声明

本应用为铁路爱好者的个人开发项目。受版权保护的数据（如时刻表）不内置，数据由用户自行记录。
