# 前端路由与交互设计文档

## 1. 概述
本项目采用 `React Router v6` 进行单页应用（SPA）的路由管理。路由结构分为公共路由（Public）和受保护路由（Protected），配合权限守卫（Route Guard）确保系统的安全性和用户体验。

## 2. 路由架构

### 2.1 路由守卫
- **PublicRoute**: 用于登录、注册等无需认证的页面。如果用户已登录，访问此类路由将自动重定向至仪表盘（Dashboard）。
- **ProtectedRoute**: 用于需要身份验证的页面。如果用户未登录，访问此类路由将被重定向至登录页。

### 2.2 布局结构 (Layout)
- **MainLayout**: 受保护页面的主布局，包含侧边导航栏、顶部栏等公共区域。

## 3. 路由清单 (Route Map)

| 路径 (Path) | 组件 (Component) | 访问权限 | 描述 |
| :--- | :--- | :--- | :--- |
| **Auth** | | | |
| `/login` | `LoginPage` | Public | 用户登录页面 |
| `/register` | `RegisterPage` | Public | 用户注册页面 |
| **Core** | | | |
| `/dashboard` | `DashboardPage` | Protected | **[首页]** 仪表盘，展示概览数据 |
| `/notifications` | `NotificationsPage` | Protected | 系统通知消息中心 |
| `/profile` | `ProfilePage` | Protected | 用户个人资料设置 |
| **Approval** | | | |
| `/approval` | `ApprovalListPage` | Protected | 审批列表（我发起的、我审批的） |
| `/approval/new` | `ApprovalCreatePage` | Protected | 发起新的审批申请 |
| `/approval/:id` | `ApprovalDetailPage` | Protected | 审批详情页（查看详情、执行审批操作） |
| **Admin** | | | |
| `/admin/users` | `MemberManagementPage` | Protected | **[管理员]** 成员/用户管理 |
| `/admin/workflows` | `WorkflowConfigPage` | Protected | **[管理员]** 审批流程配置 |
| **System** | | | |
| `/` | - | - | 默认重定向至 `/dashboard` |
| `*` | `NotFoundPage` | Public | 404 页面未找到 |

## 4. 页面交互设计

### 4.1 核心跳转流程
1.  **登录流程**:
    *   用户访问 `/login` -> 输入凭证 -> 成功 -> 跳转 `/dashboard`。
    *   未登录用户访问受保护路由 -> 被拦截重定向至 `/login`。

2.  **审批流程**:
    *   **发起审批**: 仪表盘/列表页 -> 点击"新建审批" -> 跳转 `/approval/new` -> 提交表单 -> 跳转 `/approval` (或详情页)。
    *   **处理审批**: 列表页 -> 点击某条目 -> 跳转 `/approval/:id` -> 执行通过/拒绝 -> 刷新详情页状态或返回列表。

3.  **管理流程**:
    *   侧边栏 -> 点击"成员管理" -> 跳转 `/admin/users`。
    *   侧边栏 -> 点击"流程设置" -> 跳转 `/admin/workflows`。

### 4.2 导航方式
*   **侧边栏 (Sidebar)**: 主要的一级导航入口。
*   **面包屑 (Breadcrumbs)**: (建议实现)用于展示当前页面路径层级，方便返回上一级。
*   **编程式导航**: 使用 `useNavigate` hook 在业务逻辑（如表单提交成功后）中进行跳转。

## 5. 组件与目录映射
建议遵循以下目录结构映射路由：
```
src/pages/
├── auth/           # 认证相关 (Login, Register)
├── dashboard/      # 仪表盘
├── approval/       # 审批业务 (List, Create, Detail)
├── admin/          # 管理后台 (Users, Workflows)
└── ...
```
