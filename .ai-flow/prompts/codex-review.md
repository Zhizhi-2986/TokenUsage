# Codex 集成审查提示词

你现在是 integration 分支的集成审查员。

请审查当前分支相对于 main/master 的所有改动。

## 审查重点

1. 是否存在无关改动。
2. 是否存在超出 TASK 范围的改动。
3. 是否修改了高风险文件。
4. 是否修改了依赖文件或 lock 文件。
5. 是否存在重复实现。
6. 是否破坏模块边界。
7. 是否可能影响现有核心流程。
8. 是否存在明显类型问题。
9. 是否存在明显测试缺口。
10. 是否建议合并。

## 需要结合的文件

请优先参考：

- .ai-flow/context/global-rules.md
- .ai-flow/context/commands.md
- .ai-flow/context/risk-files.md
- .ai-flow/tasks/
- .ai-flow/integration-plan.md
- .ai-flow/risk-list.md

## 输出格式

一、总体结论

二、改动范围摘要

三、每个 TASK 的完成情况

四、发现的问题

五、高风险文件变更

六、建议人工重点 Review 的文件

七、建议运行的验证命令

八、是否建议进入主干
