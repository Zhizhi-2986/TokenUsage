# 项目常用命令

## 一、项目识别

项目名称：TokenUsage

包管理器：npm

## 二、依赖安装

npm install

## 三、本地启动

npm run dev

## 四、代码检查

npm run lint

如果项目没有 lint 命令，请在这里说明。

## 五、类型检查

npm run typecheck

如果项目没有 typecheck 命令，请在这里说明。

## 六、测试

npm run test

如果项目没有 test 命令，请在这里说明。

## 七、构建

npm run build

## 八、AI 修改后默认校验顺序

AI 完成代码修改后，默认按以下顺序验证：

1. git status
2. git diff --stat
3. npm run lint
4. npm run typecheck
5. npm run test
6. npm run build

如果项目没有某些命令，应跳过并记录原因。
