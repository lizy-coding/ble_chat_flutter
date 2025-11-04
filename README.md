# ble_chat_flutter

Melos 管理的 Flutter 多包仓：`app/` 目录容纳主应用，`packages/` 目录收纳可复用的核心模块。自 Melos 3 起需先在仓库根目录安装工具依赖：执行 `dart pub get` 之后，再通过 `dart run melos bootstrap`、`dart run melos run gen` 与 `dart run melos run test` 驱动常见流程（详见 `README_MELOS.md`）。

## 仓库结构速览

```
app/                             # Flutter 应用 (需在此目录内运行 flutter 命令)
├── analysis_options.yaml
├── android/
├── lib/
│   ├── main.dart                # 应用入口
│   └── src/
│       ├── app/                 # UI 外壳与路由 (app.dart, router.dart)
│       ├── core/                # 共享服务 (ble/domain/storage/foreground/notifications)
│       └── features/            # 各功能页面 (chat/devices)
├── test/                        # 单元与组件测试，结构镜像 lib/src
└── windows/                     # Windows 原生外壳
packages/
├── core_ble/                    # BLE 管理
├── core_domain/                 # DTO 与序列化模型
├── core_foreground/             # 前台服务封装
├── core_notifications/          # 通知辅助
└── core_storage/                # 本地存储/Isar
tool/                            # 跨平台辅助脚本
melos.yaml                       # 工作区定义
README_MELOS.md                  # Melos 使用说明
```

## 在 app 包内生成 `.g.dart`

1. **进入应用目录并安装依赖**  
   ```bash
   cd app
   flutter pub get
   ```  
   确保 `build_runner` 与 `json_serializable` 等依赖齐全。

2. **一次性生成**  
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```  
   - `build_runner` 会扫描 `lib/src/core/domain` 及其它带 `part 'xxx.g.dart';` 的文件。  
   - `--delete-conflicting-outputs` 先清理过期产物，避免写入失败。  
   - 成功时会输出 `Succeeded after ... with ... outputs`；如有错误会定位到具体 Dart 文件行号。

3. **持续监听（可选）**  
   ```bash
   dart run build_runner watch --delete-conflicting-outputs
   ```  
   适合开发阶段，DTO 每次变更都会重新生成；按 `Ctrl+C` 退出。

> 若需在整个工作区统一生成，可使用 `melos run gen` 或 `./tool/gen_all.sh`，它会对 `app/` 与 `packages/*` 同步执行构建。
