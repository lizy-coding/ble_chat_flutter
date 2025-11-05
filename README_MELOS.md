# Melos ble_chat_flutter Guide

## 准备 Melos 3+
根目录的 `pubspec.yaml` 已声明 `melos` 依赖，首次拉取或版本更新后运行：
```
dart pub get
```
随后所有 Melos 指令都通过 `dart run melos <command>` 执行（也可使用 `dart run melos run <script>` 调用 `melos.yaml` 中的脚本）。

## 初始化（安装所有包依赖 + 建立本地依赖链接）
```
dart run melos bootstrap
```

## 代码生成（json_serializable / isar 等）
```
dart run melos run gen
```

## 清理 / 格式化 / 测试
```
dart run melos run clean
dart run melos run format
dart run melos run test
```
