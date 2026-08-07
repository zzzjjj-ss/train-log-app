# 铁路运转日志 (Train Log)

面向铁路爱好者的安卓运转记录应用。除行程信息外，还记录所乘列车的机车车辆信息（动车组编号、本务机车等）。

## 功能

- 运转记录：车次、日期、站点、时刻、席别、车厢座位、里程、评分、备注
- 跨天行程：支持跨日到达的行程记录
- 机车车辆信息：动车组（型号自动补全、编号、编组、定员、配属）与多台本务机车（型号、编号、制造厂、牵引区间）
- 车次自动识别：按车次前缀区分高铁/动车/城际/市郊/普速
- 列表筛选：按大类与小类组合多选筛选
- 主题与深色模式：多种主题色，支持跟随系统
- 数据本地存储（SQLite），离线可用

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
│   └── about_screen.dart      # 关于
├── utils/
│   └── train_classify.dart    # 车次前缀分类
└── widgets/
    └── log_card.dart          # 记录卡片
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
