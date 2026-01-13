# 前端接口与数据交互设计文档

## 1. 概述
前端使用 `Axios` 作为 HTTP 客户端与后端 API 进行通信。所有的 API 请求通过统一的 `services/api.ts` 实例发出，确保全局统一的配置、拦截器处理和错误管理。

## 2. API 基础配置

### 2.1 实例配置
*   **Base URL**: 从环境变量 `VITE_API_BASE_URL` 获取，开发环境默认为 `/api`。
*   **Timeout**: 设置为 30s (30000ms)，避免请求过长时间挂起。
*   **Headers**: 默认 `Content-Type: application/json`。

### 2.2 拦截器设计 (Interceptors)

#### 请求拦截器 (Request Interceptor)
*   **Token 注入**: 每次请求前，从 `AuthStore` (Zustand) 中获取当前用户的 access_token。
*   **Authorization Header**: 如果 token 存在，自动添加到请求头中：`Authorization: Bearer <token>`。

#### 响应拦截器 (Response Interceptor)
*   **通用处理**: 直接提取 response 数据或保持原样返回（根据后端包装格式决定）。
*   **错误处理 (Error Handling)**:
    *   **401 Unauthorized**: 检测到 token 过期或无效，自动调用 `logout()` 清除本地状态，并触发页面重定向至登录页。
    *   **通用错误**: 记录错误日志，可结合 UI 组件（如 Toast）全局提示错误信息。

## 3. 接口服务模块划分 (Service Modules)
建议根据业务领域将 API 定义分散在不同的服务文件中，避免单一文件过大。

| 模块 | 文件路径 | 职责 |
| :--- | :--- | :--- |
| **基础服务** | `src/services/api.ts` | Axios 实例、拦截器、通用配置 |
| **认证服务** | `src/services/authService.ts` | 登录、注册、刷新 Token、获取当前用户信息 |
| **审批服务** | `src/services/approvalService.ts` | 审批单的增删改查、审批操作（通过/拒绝） |
| **文件服务** | `src/services/fileService.ts` | 文件上传、下载、预览链接获取 |
| **用户管理** | `src/services/userService.ts` | 用户列表、角色分配、信息更新 |
| **配置服务** | `src/services/workflowService.ts` | 审批流模版配置、节点设置 |

## 4. 接口定义规范 (Best Practices)

### 4.1 函数命名
使用 动词 + 名词 的形式，清晰表达意图。
*   `login(data: LoginRequest)`
*   `getApprovalList(params: QueryParams)`
*   `createApproval(data: CreateApprovalRequest)`
*   `approveRequest(id: string, comment?: string)`

### 4.2 类型定义 (TypeScript)
所有的请求参数和响应数据必须定义严格的 TypeScript 接口，放置在 `src/types/` 目录下。

```typescript
// src/types/approval.ts
export interface ApprovalItem {
  id: string;
  title: string;
  status: 'pending' | 'approved' | 'rejected';
  applicantId: string;
  createdAt: string;
}

export interface CreateApprovalPayload {
  title: string;
  content: string;
  attachments?: string[];
}
```

### 4.3 调用示例
在组件中建议使用 `React Query` (TanStack Query) 或 `useEffect` 配合 Service 调用，以管理加载状态和缓存。

```typescript
// 示例：组件内调用
import { approvalService } from '@/services/approvalService';

const handleSubmit = async (data) => {
  try {
    await approvalService.create(data);
    toast.success('提交成功');
  } catch (error) {
    toast.error('提交失败');
  }
};
```
