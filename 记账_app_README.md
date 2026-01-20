# 记账App (Flutter)

## 项目结构
```
记账_app/
├── lib/
│   ├── main.dart                # 主入口文件
│   ├── pages/
│   │   ├── home_page.dart       # 首页（收支概览）
│   │   ├── add_record_page.dart # 添加记录页面
│   │   ├── history_page.dart    # 历史记录页面
│   │   └── statistics_page.dart # 统计页面
│   ├── models/
│   │   └── record.dart          # 记账记录模型
│   ├── widgets/
│   │   └── record_card.dart     # 记录卡片组件
│   └── utils/
│       └── database_helper.dart # 数据库辅助类
├── pubspec.yaml                 # 依赖配置文件
└── README.md                    # 项目说明
```

## 功能特点
1. **收支概览**：展示当日、当月收支情况
2. **快速记账**：支持收入和支出记录，包含分类选择
3. **历史记录**：查看所有记账记录，支持按日期筛选
4. **数据统计**：通过图表展示收支趋势和分类占比

## 技术实现
- 使用Flutter 3.0+框架
- 本地SQLite数据库存储
- 状态管理：Provider
- 图表库：fl_chart
- 日期选择：intl

## 安装和运行
1. 确保已安装Flutter环境
2. 克隆项目到本地
3. 运行 `flutter pub get` 安装依赖
4. 运行 `flutter run` 启动应用

## 后续扩展
- 云同步功能
- 预算管理
- 多账户支持
- 导出数据功能