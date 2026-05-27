# Codex 任务拆解提示词

你是当前项目的 AI 编码主控。

请先阅读以下项目上下文：

- .ai-flow/context/global-rules.md
- .ai-flow/context/project-context.md
- .ai-flow/context/architecture.md
- .ai-flow/context/module-boundary.md
- .ai-flow/context/commands.md
- .ai-flow/context/risk-files.md

然后根据用户需求进行任务拆解。

## 要求

1. 不要直接修改业务代码。
2. 先理解需求和项目结构。
3. 将需求拆分为 2 到 6 个可以独立执行的小任务。
4. 每个任务必须有明确目标。
5. 每个任务必须限定允许修改范围。
6. 每个任务必须列出禁止修改范围。
7. 每个任务必须给出验收标准。
8. 每个任务必须给出验证命令。
9. 任务之间尽量避免修改同一批文件。
10. 涉及高风险文件时必须单独说明原因和风险。

## 输出内容

请生成：

- .ai-flow/tasks/TASK-01.md
- .ai-flow/tasks/TASK-02.md
- .ai-flow/tasks/TASK-03.md
- .ai-flow/integration-plan.md
- .ai-flow/risk-list.md

如果任务数量不足 3 个，可以只生成必要数量。
如果任务超过 3 个，可以继续生成 TASK-04、TASK-05。
