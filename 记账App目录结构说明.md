# 记账App目录结构说明

## 正确的Flutter项目结构

当您安装好Flutter环境后，请按照以下结构组织代码文件：

```
expense_tracker/          # 项目根目录
├── lib/                  # 源代码目录
│   ├── main.dart         # 主入口文件
│   ├── models/           # 数据模型
│   │   └── record.dart   # 记账记录模型
│   ├── pages/            # 页面
│   │   ├── home_page.dart       # 首页
│   │   ├── add_record_page.dart # 添加记录页面
│   │   ├── history_page.dart    # 历史记录页面
│   │   └── statistics_page.dart # 统计页面
│   └── utils/            # 工具类
│       └── database_helper.dart # 数据库辅助类
├── pubspec.yaml          # 依赖配置文件
└── README.md             # 项目说明
```

## 如何使用

1. **创建Flutter项目**
   ```bash
   flutter create expense_tracker
   cd expense_tracker
   ```

2. **替换文件**
   - 将下载的代码文件按照上述目录结构复制到对应位置
   - 确保 `pubspec.yaml` 文件包含所有必要的依赖

3. **安装依赖**
   ```bash
   flutter pub get
   ```

4. **运行项目**
   ```bash
   flutter run
   ```

## 功能特性

- ✅ 收支记录管理
- ✅ 分类统计
- ✅ 数据可视化
- ✅ 历史记录查询
- ✅ 日期范围筛选
- ✅ 响应式UI设计

## 技术栈

- Flutter 3.0+
- SQLite (本地存储)
- Provider (状态管理)
- fl_chart (图表库)
- intl (日期格式化)

## 注意事项

1. 确保您的Flutter环境已正确安装
2. 首次运行时会自动创建数据库
3. 应用会请求存储权限以保存数据
4. 您可以通过修改 `record.dart` 文件中的分类定义来自定义收支分类

## 后续扩展建议

1. 添加云同步功能
2. 实现预算管理
3. 支持多账户
4. 添加数据导出功能
5. 实现深色模式