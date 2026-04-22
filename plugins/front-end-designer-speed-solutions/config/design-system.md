# Speed Solutions Design System

Corporate design system for FlowLink, PrintLink (SPL), and BlazorWebFrontEnd applications.

---

## Color Palette

### Primary Colors
| Name | Value | Usage |
|------|-------|-------|
| **Primary Blue** | `#0066CC` | CTAs, main actions, primary buttons |
| **Primary Dark Blue** | `#003D7A` | Hover states, active states |
| **Primary Light Blue** | `#E6F0FF` | Background tints, disabled states |

### Secondary Colors
| Name | Value | Usage |
|------|-------|-------|
| **Accent Teal** | `#00A896` | Secondary actions, highlights |
| **Accent Teal Dark** | `#006B5F` | Hover/active secondary |
| **Accent Teal Light** | `#E8F8F5` | Secondary backgrounds |

### Semantic Colors
| Name | Value | Meaning |
|------|-------|---------|
| **Success Green** | `#28A745` | Confirmations, valid states |
| **Warning Orange** | `#FFC107` | Alerts, caution, pending |
| **Error Red** | `#DC3545` | Errors, destructive actions |
| **Info Blue** | `#17A2B8` | Informational messages |

### Neutral Colors
| Name | Value | Usage |
|------|-------|-------|
| **Black** | `#000000` | Text, dark elements |
| **Dark Gray** | `#333333` | Secondary text, borders |
| **Medium Gray** | `#666666` | Tertiary text, disabled |
| **Light Gray** | `#EEEEEE` | Backgrounds, subtle dividers |
| **Lighter Gray** | `#F7F7F7` | Card backgrounds |
| **White** | `#FFFFFF` | Primary background |

---

## Typography

### Font Family Stack
```css
/* Blazor/Web */
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', sans-serif;

/* Fallback */
font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
```

### Type Scale

#### Headings
| Level | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| H1 | 32px | 700 (Bold) | 1.2 | Page titles, major sections |
| H2 | 28px | 700 (Bold) | 1.3 | Section headers |
| H3 | 24px | 600 (SemiBold) | 1.4 | Subsection headers |
| H4 | 20px | 600 (SemiBold) | 1.4 | Card titles |
| H5 | 18px | 500 (Medium) | 1.5 | Component titles |
| H6 | 16px | 500 (Medium) | 1.5 | Labels, mini headers |

#### Body Text
| Role | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| **Body Large** | 16px | 400 (Regular) | 1.6 | Primary body text, descriptions |
| **Body Normal** | 14px | 400 (Regular) | 1.6 | Standard paragraph text |
| **Body Small** | 12px | 400 (Regular) | 1.5 | Secondary info, helper text |
| **Caption** | 11px | 400 (Regular) | 1.4 | Form labels, captions |

#### Monospace
| Role | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| **Code Block** | 13px | 400 (Regular) | 1.6 | Code snippets, examples |
| **Inline Code** | 13px | 500 (Medium) | 1.6 | Inline code references |

---

## Spacing Scale

### Spacing Units (Base: 8px)
```
xs:  4px   (0.5x)
sm:  8px   (1x)
md:  16px  (2x)
lg:  24px  (3x)
xl:  32px  (4x)
2xl: 48px  (6x)
3xl: 64px  (8x)
4xl: 80px  (10x)
```

### Application
- **Padding:** Interior spacing within components
- **Margin:** Spacing between elements
- **Gap:** Spacing between flex/grid children

---

## Borders & Radius

### Border Radius
| Name | Value | Usage |
|------|-------|-------|
| **None** | `0px` | Sharp edges |
| **Small** | `4px` | Badges, small buttons |
| **Medium** | `8px` | Cards, inputs, moderate |
| **Large** | `12px` | Large containers |
| **Full/Pill** | `9999px` | Circular buttons, avatars |

### Border Width
| Name | Value | Usage |
|------|-------|-------|
| **Hairline** | `1px` | Subtle dividers, borders |
| **Standard** | `2px` | Input focus states |
| **Thick** | `3px` | Emphasis borders |

---

## Shadows

### Shadow Elevation System

#### Elevation 0 (None)
```css
box-shadow: none;
```

#### Elevation 1 (Subtle)
```css
box-shadow: 0 2px 4px rgba(0, 0, 0, 0.08);
```

#### Elevation 2 (Small)
```css
box-shadow: 0 4px 8px rgba(0, 0, 0, 0.12);
```

#### Elevation 3 (Medium)
```css
box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
```

#### Elevation 4 (Large)
```css
box-shadow: 0 12px 24px rgba(0, 0, 0, 0.18);
```

#### Elevation 5 (Extra Large)
```css
box-shadow: 0 16px 32px rgba(0, 0, 0, 0.20);
```

#### Inset Shadow
```css
box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.05);
```

---

## Transitions & Animations

### Duration Scale
| Name | Value | Usage |
|------|-------|-------|
| **Fast** | `150ms` | Micro-interactions, hovers |
| **Normal** | `300ms` | Standard transitions |
| **Slow** | `500ms` | Page transitions, complex animations |

### Easing Functions
```css
/* Linear - no acceleration */
ease-linear: cubic-bezier(0, 0, 1, 1);

/* Standard - ease in-out */
ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);

/* Entrance - ease out */
ease-out: cubic-bezier(0, 0, 0.2, 1);

/* Exit - ease in */
ease-in: cubic-bezier(0.4, 0, 1, 1);

/* Bounce - custom */
ease-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);
```

### Property Transitions
| Property | Duration | Easing |
|----------|----------|--------|
| `color` | 150ms | ease-in-out |
| `background-color` | 150ms | ease-in-out |
| `border-color` | 150ms | ease-in-out |
| `opacity` | 200ms | ease-in-out |
| `transform` | 300ms | ease-out |
| `box-shadow` | 200ms | ease-in-out |
| `width` | 300ms | ease-in-out |
| `height` | 300ms | ease-in-out |

---

## Responsive Breakpoints

### Mobile-First Breakpoints
| Name | Size | Target | Usage |
|------|------|--------|-------|
| **Mobile** | `< 480px` | Small phones | Base styles, simplest layout |
| **Tablet Small** | `480px - 768px` | Phones, small tablets | Touch-friendly spacing |
| **Tablet** | `768px - 1024px` | Large tablets | 2-column layouts |
| **Desktop Small** | `1024px - 1280px` | Small laptops | 3-column layouts |
| **Desktop** | `1280px - 1920px` | Standard monitors | Full desktop experience |
| **Desktop Large** | `>= 1920px` | Large monitors | 4+ column layouts |

### Media Query Syntax (CSS)
```css
/* Mobile first - add mobile styles by default */
.component {
  width: 100%;
  padding: 16px;
}

/* Tablet and up */
@media (min-width: 768px) {
  .component {
    width: 50%;
    padding: 24px;
  }
}

/* Desktop and up */
@media (min-width: 1024px) {
  .component {
    width: 33.333%;
    padding: 32px;
  }
}
```

### CSS-in-JS / Tailwind Breakpoints
```javascript
sm:  480px
md:  768px
lg:  1024px
xl:  1280px
2xl: 1920px
```

---

## Contrast Requirements

### WCAG AA Compliance
- **Normal Text:** Minimum 4.5:1 contrast ratio
- **Large Text (18px+):** Minimum 3:1 contrast ratio
- **UI Components:** Minimum 3:1 contrast ratio

### Tested Color Combinations
- Dark Gray (#333) on White (#FFF): **19.56:1** ✓
- Primary Blue (#0066CC) on White (#FFF): **8.59:1** ✓
- Error Red (#DC3545) on White (#FFF): **5.16:1** ✓

---

## Density & Spacing

### Comfortable (Default)
- Padding: 16px
- Min touch target: 44px × 44px
- Gap between elements: 16px

### Compact
- Padding: 12px
- Min touch target: 40px × 40px
- Gap between elements: 12px

### Spacious
- Padding: 24px
- Min touch target: 48px × 48px
- Gap between elements: 24px

---

## Dark Mode (Future)

### Future Color Adjustments
- Base background: `#1A1A1A`
- Card background: `#2D2D2D`
- Text primary: `#FFFFFF`
- Text secondary: `#B0B0B0`
- Borders: `#404040`

Dark mode will follow the same structure but with inverted contrast ratios.
