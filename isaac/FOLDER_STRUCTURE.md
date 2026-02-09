# 项目文件夹结构说明

本文档说明了以撒复刻项目的文件夹组织结构，便于协作开发。

## 📁 主要目录结构

```
isaac/
├── scenes/              # 场景文件夹
│   ├── player/         # 玩家相关场景（开发者A负责）
│   ├── enemies/        # 敌人相关场景（开发者B负责）
│   ├── rooms/          # 房间相关场景（开发者A负责）
│   ├── projectiles/     # 子弹相关场景（开发者B负责）
│   ├── items/          # 道具相关场景（开发者B负责）
│   ├── ui/             # UI场景
│   ├── managers/       # 管理器场景
│   └── test/           # 测试场景
│
├── scripts/            # 脚本文件夹
│   ├── player/        # 玩家脚本（开发者A负责）
│   ├── enemies/       # 敌人脚本（开发者B负责）
│   ├── rooms/         # 房间脚本（开发者A负责）
│   ├── projectiles/    # 子弹脚本（开发者B负责）
│   ├── items/         # 道具脚本（开发者B负责）
│   ├── managers/      # 管理器脚本（共享）
│   ├── ui/            # UI脚本
│   ├── combat/        # 战斗系统脚本（开发者B负责）
│   ├── utils/         # 工具脚本（共享）
│   └── autoload/      # 自动加载脚本（共享）
│
├── resources/          # 资源文件夹
│   ├── textures/      # 纹理/图片资源
│   ├── audio/         # 音频资源
│   ├── data/          # 数据文件
│   ├── materials/     # 材质资源
│   └── shaders/       # 着色器
│
├── assets/            # 外部资源
│   ├── placeholders/  # 占位符资源
│   └── sprites/       # 精灵图
│
├── docs/              # 项目文档
│   ├── api/          # API文档
│   ├── design/       # 设计文档
│   └── notes/        # 开发笔记
│
└── addons/            # 插件文件夹
```

## 🎯 职责划分

### 开发者A（玩家与房间系统）
- `scenes/player/` - 玩家场景
- `scenes/rooms/` - 房间场景
- `scripts/player/` - 玩家脚本
- `scripts/rooms/` - 房间脚本

### 开发者B（战斗与敌人系统）
- `scenes/enemies/` - 敌人场景
- `scenes/projectiles/` - 子弹场景
- `scenes/items/` - 道具场景
- `scripts/enemies/` - 敌人脚本
- `scripts/projectiles/` - 子弹脚本
- `scripts/items/` - 道具脚本
- `scripts/combat/` - 战斗系统脚本

### 共享模块
- `scripts/managers/` - 游戏管理器
- `scripts/utils/` - 工具函数
- `scripts/autoload/` - 全局单例
- `scenes/ui/` - UI场景
- `scripts/ui/` - UI脚本

## 📝 使用说明

1. **场景文件**：所有 `.tscn` 场景文件放在对应的 `scenes/` 子目录中
2. **脚本文件**：所有 `.gd` 脚本文件放在对应的 `scripts/` 子目录中
3. **资源文件**：图片、音频等资源放在 `resources/` 对应子目录中
4. **测试场景**：开发测试用的场景放在 `scenes/test/` 中
5. **文档**：接口文档和设计文档放在 `docs/` 对应子目录中

## 🔄 版本控制建议

- 不同模块分开开发，减少文件冲突
- 每日结束前合并代码并测试
- 遇到冲突及时沟通解决

---

**最后更新**：2024年
**维护者**：开发团队

