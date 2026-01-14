# 审批系统 - Tailwind CSS 样式规范

## 1. 技术概述

| 技术 | 版本 | 说明 |
|------|------|------|
| Tailwind CSS | 4.1.18 | 原子化 CSS 框架 |
| PostCSS | 8.5.6 | CSS 处理器 |
| Autoprefixer | 10.4.23 | 自动添加浏览器前缀 |

## 2. 安装配置

### 2.1 安装依赖

```bash
pnpm add -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### 2.2 Tailwind 配置 (tailwind.config.js)

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  darkMode: ["class"],
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      // 自定义颜色
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
        success: '#22c55e',
        warning: '#f59e0b',
        danger: '#ef4444',
        info: '#3b82f6',
      },
      // 自定义字体
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      // 自定义圆角
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      // 自定义动画
      animation: {
        'fade-in': 'fadeIn 0.3s ease-out',
        'slide-up': 'slideUp 0.3s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}
```

### 2.3 全局样式 (src/styles/globals.css)

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --radius: 0.5rem;
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 199 89% 48%;
    --primary-foreground: 210 40% 98%;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
  }
  
  * {
    @apply border-border;
  }
  
  body {
    @apply bg-background text-foreground;
  }
}

@layer components {
  /* 自定义按钮样式 */
  .btn-primary {
    @apply bg-primary-500 text-white px-4 py-2 rounded-md 
           hover:bg-primary-600 transition-colors duration-200;
  }

  /* 卡片样式 */
  .card {
    @apply bg-white rounded-lg shadow-md p-6 
           border border-gray-100;
  }
}
```

## 3. 样式使用规范

### 3.1 常用类名速查

| 类别 | 示例 | 说明 |
|------|------|------|
| 间距 | `p-4`, `mx-auto`, `mt-2` | padding/margin |
| 布局 | `flex`, `grid`, `container` | 布局方式 |
| 尺寸 | `w-full`, `h-screen`, `max-w-xl` | 宽高 |
| 文字 | `text-lg`, `font-bold`, `text-gray-600` | 字体样式 |
| 背景 | `bg-white`, `bg-primary-500` | 背景色 |
| 边框 | `border`, `rounded-lg`, `shadow-md` | 边框阴影 |
| 响应式 | `md:flex`, `lg:grid-cols-3` | 断点前缀 |

### 3.2 响应式断点

```
sm: 640px   - 小屏幕设备
md: 768px   - 平板设备
lg: 1024px  - 笔记本
xl: 1280px  - 桌面显示器
2xl: 1536px - 大屏显示器
```

### 3.3 组件示例

```tsx
// 响应式卡片布局
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  <div className="bg-white rounded-lg shadow p-4 hover:shadow-lg transition-shadow">
    <h3 className="text-lg font-semibold text-gray-800">标题</h3>
    <p className="mt-2 text-gray-600">内容描述</p>
  </div>
</div>

// 表单输入框
<input
  type="text"
  className="w-full px-3 py-2 border border-gray-300 rounded-md 
             focus:outline-none focus:ring-2 focus:ring-primary-500"
  placeholder="请输入..."
/>

// 状态标签
<span className="inline-flex items-center px-2.5 py-0.5 rounded-full 
                 text-xs font-medium bg-green-100 text-green-800">
  已通过
</span>
```

## 4. 最佳实践

1. **保持一致性**：使用设计系统中定义的颜色和间距
2. **语义化命名**：使用 `@layer components` 定义可复用样式
3. **响应式优先**：从移动端开始设计，逐步增强
4. **避免过度嵌套**：保持类名简洁，必要时提取组件
