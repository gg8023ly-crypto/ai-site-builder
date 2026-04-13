# DESIGN.md — AI Site Design System

> AI Agent 读这个文件就知道站点应该长什么样。修改此文件即可定制视觉风格。

## Theme: Midnight (默认)

深色科技感，紫光点缀，像凌晨三点的星空。

### Color Variables

```css
:root {
  --bg:          #0B1020;
  --bg-card:     #111827;
  --bg-card2:    #0F1A2E;
  --text:        #F5F3EE;
  --text-muted:  #9CA3AF;
  --primary:     #B388FF;
  --secondary:   #7DD3FC;
  --accent:      #F9A8D4;
  --border:      rgba(179, 136, 255, 0.15);
  --border-glow: rgba(179, 136, 255, 0.35);
  --success:     #4ADE80;
  --gradient:    linear-gradient(135deg, #B388FF 0%, #7DD3FC 100%);
}
```

## Alternative Themes

### Editorial (杂志风)

```css
:root {
  --bg:          #faf9f6;
  --bg-card:     #ffffff;
  --bg-card2:    #f5f5f0;
  --text:        #1a1a2e;
  --text-muted:  #6b7280;
  --primary:     #2563eb;
  --secondary:   #7DD3FC;
  --accent:      #e74c3c;
  --border:      #e5e7eb;
  --border-glow: rgba(37, 99, 235, 0.3);
  --success:     #059669;
  --gradient:    linear-gradient(135deg, #2563eb 0%, #7DD3FC 100%);
}
```

### Minimal (极简白)

```css
:root {
  --bg:          #ffffff;
  --bg-card:     #f9fafb;
  --bg-card2:    #f3f4f6;
  --text:        #111827;
  --text-muted:  #6b7280;
  --primary:     #111827;
  --secondary:   #6b7280;
  --accent:      #ef4444;
  --border:      #e5e7eb;
  --border-glow: rgba(17, 24, 39, 0.2);
  --success:     #059669;
  --gradient:    linear-gradient(135deg, #111827 0%, #374151 100%);
}
```

## Typography

```
Font Stack:  -apple-system, "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", sans-serif
Mono:        'JetBrains Mono', monospace

Size Scale:
  - Hero title:    clamp(2rem, 5vw, 3.5rem), font-weight: 700
  - Section title: 1.8rem, font-weight: 700
  - Card title:    1.1rem, font-weight: 600
  - Body:          1rem (16px), font-weight: 400
  - Caption:       0.85rem, font-weight: 400
```

## Layout

```
Max Width:       1100px
Card Padding:    24-32px
Border Radius:   16px (cards), 12px (buttons), 8px (inputs)
Spacing Scale:   4px → 8px → 16px → 24px → 32px → 48px → 64px
```

## Do's and Don'ts

### Do ✅
- 用 CSS 变量（var(--xxx)）
- 保持主题一致性
- 响应式设计
- 微动画（hover translateY, border glow）

### Don't ❌
- 不硬编码颜色值
- 不加过多动画
- 不用 box-shadow 做层级（用 border）
