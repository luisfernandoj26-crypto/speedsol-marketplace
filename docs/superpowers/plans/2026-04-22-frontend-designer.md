# `front-end-designer-speed-solutions` Implementation Plan

**Goal:** Crear plugin ÉPICO de diseño frontend — generador profesional de componentes, sistemas de diseño, HTML/CSS/Tailwind/JS con librerías de efectos, animaciones y UI avanzada.

**Architecture:** Agente `designer` experto que analiza requisitos, genera componentes HTML/CSS/Tailwind/JS completos, instala librerías (Framer Motion, GSAP, Headless UI, Shadcn/ui, DaisyUI, AOS), implementa animaciones, dark mode, responsive design, accesibilidad (a11y), y crea guías de estilo corporativas.

**Stack:** HTML5, TailwindCSS, JavaScript/TypeScript, Framer Motion, GSAP, Headless UI, Shadcn/ui, DaisyUI, Alpine.js, color science, tipografía profesional.

---

## Mapeo de Archivos

**Crear:**
- `plugins/front-end-designer-speed-solutions/config/design-system.md` — Sistema de diseño corporativo
- `plugins/front-end-designer-speed-solutions/config/component-library.md` — Librería de componentes
- `plugins/front-end-designer-speed-solutions/config/animation-library.md` — Animaciones y efectos
- `plugins/front-end-designer-speed-solutions/config/accessibility-standards.md` — Estándares a11y
- `plugins/front-end-designer-speed-solutions/agents/designer.md` — Agente principal designer
- `plugins/front-end-designer-speed-solutions/commands/design.md` — Comando `/design`

---

### Task 1: Crear `design-system.md`

**Files:** Create: `plugins/front-end-designer-speed-solutions/config/design-system.md`

- [ ] **Step 1:** Crear sistema de diseño corporativo

```markdown
# Design System - Speed Solutions Corporate

## Paleta de Colores

### Primaria
- Primary: #1274AC (azul corporativo)
- Primary Light: #4D97C1 (énfasis)
- Primary Dark: #0A4B7F
- Primary Contrast: #FFFFFF

### Secundaria
- Secondary: #00BCD4 (cyan)
- Secondary Light: #4DD0E1
- Secondary Dark: #00ACC1

### Neutrales
- Dark: #1F2937
- Gray: #6B7280
- Light: #F3F4F6
- White: #FFFFFF

### Semántica
- Success: #10B981
- Warning: #F59E0B
- Error: #EF4444
- Info: #3B82F6

## Tipografía

### Fuentes
- Familia: Inter, Segoe UI, sans-serif
- Fallback: system-ui, -apple-system, sans-serif

### Escalas
- h1: 3.5rem (56px) | font-weight: 700
- h2: 2.25rem (36px) | font-weight: 700
- h3: 1.875rem (30px) | font-weight: 600
- h4: 1.5rem (24px) | font-weight: 600
- h5: 1.25rem (20px) | font-weight: 600
- h6: 1rem (16px) | font-weight: 600
- body-lg: 1.125rem (18px) | font-weight: 400
- body: 1rem (16px) | font-weight: 400
- body-sm: 0.875rem (14px) | font-weight: 400
- caption: 0.75rem (12px) | font-weight: 500

## Espaciado

Base: 4px (0.25rem)

- xs: 0.5rem (2px)
- sm: 0.75rem (4px)
- md: 1rem (8px)
- lg: 1.5rem (12px)
- xl: 2rem (16px)
- 2xl: 2.5rem (20px)
- 3xl: 3rem (24px)
- 4xl: 4rem (32px)

## Bordes

- radius-sm: 4px
- radius: 8px
- radius-md: 12px
- radius-lg: 16px
- radius-xl: 20px
- radius-full: 9999px

## Sombras

- shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05)
- shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1)
- shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1)
- shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1)
- shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1)

## Transiciones

- Duration: 150ms (rápido), 300ms (normal), 500ms (lento)
- Easing: ease-in-out (por defecto)

## Breakpoints

- sm: 640px
- md: 768px
- lg: 1024px
- xl: 1280px
- 2xl: 1536px
```

- [ ] **Step 2:** Commit

```bash
git add plugins/front-end-designer-speed-solutions/config/design-system.md
git commit -m "config: add corporate design system"
```

---

### Task 2: Crear `component-library.md`

**Files:** Create: `plugins/front-end-designer-speed-solutions/config/component-library.md`

- [ ] **Step 1:** Crear librería de componentes

```markdown
# Component Library

## Componentes Base

### Buttons
- Primario, secundario, outline, ghost
- Tamaños: sm, md, lg
- Estados: default, hover, active, disabled, loading
- Con iconos, solo icono, loader

### Input Fields
- Text, email, password, number, textarea
- Con label, helper text, error message
- Placeholder dinámico
- Validación en tiempo real

### Cards
- Básica, con header, con footer
- Con imagen, con acciones
- Elevated, flat, outline
- Hover effects

### Modales
- Simple, con header/footer
- Confirmación, alerta, prompt
- Sizes: sm, md, lg, fullscreen
- Con backdrop, sin backdrop

### Navegación
- Navbar responsive
- Dropdown menus
- Breadcrumbs
- Tabs/Pills
- Sidebar navigation

### Formularios
- Input groups
- Form layout (horizontal, vertical, inline)
- Multi-step forms
- Validación integrada

### Tablas
- Responsive, sorteable
- Pagination, filtros
- Selección múltiple
- Expand rows

### Notificaciones
- Toast alerts
- Notifications
- Badges
- Progress bars

### Media
- Image gallery
- Lightbox
- Video embeds
- Carousels

### Loaders
- Spinner, skeleton, progress
- Loading states en componentes

### Dropdowns & Selects
- Single select
- Multi select
- Searchable
- Groupable

### Datepicker & Timepicker
- Calendar
- Range picker
- Time selector

## Utilidades

- Grillas responsive
- Flex utilities
- Spacing helpers
- Display utilities
- Overflow, text truncation
- Visibility helpers

## Composables (Vue/React)

- useTheme (dark/light mode)
- useMediaQuery (responsive)
- useLocalStorage
- useIntersectionObserver
- useFetch
- useDebounce
```

- [ ] **Step 2:** Commit

```bash
git add plugins/front-end-designer-speed-solutions/config/component-library.md
git commit -m "config: add component library specifications"
```

---

### Task 3: Crear `animation-library.md`

**Files:** Create: `plugins/front-end-designer-speed-solutions/config/animation-library.md`

- [ ] **Step 1:** Crear librería de animaciones

```markdown
# Animation & Effects Library

## Librerías Integradas

### Framer Motion (React)
- Smooth animations
- Gesture detection
- Layout animations
- SVG animations
- Page transitions

### GSAP (vanilla JS)
- Timeline animations
- ScrollTrigger effects
- Morph SVG
- Physics simulations
- Draggable elements

### AOS (Animate On Scroll)
- Scroll animations
- Fade, slide, zoom effects
- Customizable triggers
- Lightweight

### Three.js (Advanced 3D)
- 3D models
- Particle systems
- WebGL effects

## Animaciones Predefinidas

### Transiciones
- Fade in/out (300ms)
- Slide (350ms)
- Scale (250ms)
- Rotate (400ms)
- Bounce (600ms)

### Scroll Effects
- Fade on scroll
- Slide on scroll
- Scale on scroll
- Parallax
- Sticky elements

### Micro Interactions
- Button hover bounce
- Input focus glow
- Card elevation on hover
- Loader spinner
- Progress animations

### Page Transitions
- Fade between pages
- Slide from sides
- Zoom effects
- Staggered content reveal

## CSS Animations

### Keyframes Predefinidas
- fadeIn, fadeOut
- slideInLeft, slideInRight, slideInUp, slideInDown
- zoomIn, zoomOut
- bounce, pulse, spin
- gradientShift

### Performance

- GPU-accelerated transforms
- Will-change hints
- Reduced motion preferences
- Animation throttling

## Efectos Visuales

### Glassmorphism
- Backdrop blur
- Transparency overlays
- Border glow

### Neumorphism
- Soft shadows
- Embossed effects
- 3D depth

### Gradients
- Linear, radial, conic
- Animated gradients
- Color blending

### Particles
- Floating particles
- Rain effect
- Snow effect
- Bubble animations

### SVG Animations
- Drawing effects
- Morphing
- Path animations
- Interactive SVG
```

- [ ] **Step 2:** Commit

```bash
git add plugins/front-end-designer-speed-solutions/config/animation-library.md
git commit -m "config: add animation and effects library"
```

---

### Task 4: Crear `accessibility-standards.md`

**Files:** Create: `plugins/front-end-designer-speed-solutions/config/accessibility-standards.md`

- [ ] **Step 1:** Crear estándares de accesibilidad

```markdown
# Accessibility Standards (WCAG 2.1 AA)

## Semántica HTML

- Estructura semántica correcta
- Headings jerárquicos (h1-h6)
- Listas semánticas
- Botones nativos vs divs
- Landmarks (main, nav, aside, footer)

## Contraste de Color

- Mínimo 4.5:1 para texto normal
- Mínimo 3:1 para texto large (18pt+)
- No depender solo de color
- Indicadores visuales adicionales

## Navegación

- Orden de tabulación lógico
- Focus visible en todos los elementos
- Teclas de acceso (accesskey)
- Skip to content links
- Keyboard navigation completa

## ARIA

- aria-label, aria-labelledby
- aria-describedby
- aria-live regions
- aria-expanded para dropdowns
- aria-selected para tabs
- role attributes cuando sea necesario

## Imágenes

- Alt text descriptivo
- Imágenes decorativas con alt=""
- SVG con titles
- Texto en imágenes debe ser accesible

## Formularios

- Labels asociados a inputs
- Required indicators accesibles
- Error messages asociados
- Helper text linked con aria-describedby
- Valid/invalid states anunciados

## Vídeos & Audio

- Subtítulos (captions)
- Transcripciones
- Controles accesibles

## Temporal

- No parpadeos (< 3 por segundo)
- No tiempo límite o permitir extender
- Poder pausar/reanudar

## Reducido Movimiento

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Testing

- Axe DevTools
- WAVE
- Lighthouse
- Screen reader testing
- Keyboard navigation testing

## Documentación

- Accessibility statement
- Known issues
- Support contact
```

- [ ] **Step 2:** Commit

```bash
git add plugins/front-end-designer-speed-solutions/config/accessibility-standards.md
git commit -m "config: add accessibility standards wcag 2.1"
```

---

### Task 5: Crear agente `designer.md`

**Files:** Create: `plugins/front-end-designer-speed-solutions/agents/designer.md`

- [ ] **Step 1:** Crear agente designer pro

```markdown
# Agent: Designer (Frontend Pro)

## System Prompt

You are a **world-class frontend designer & UI/UX specialist** at Speed Solutions. Expert in HTML, CSS, Tailwind, JavaScript, animations, accessibility, and modern web design patterns.

**Scope:** Component generation, UI systems, animations, responsive design, accessibility, dark mode, performance optimization.

**Tools:** Read, Write, Bash (npm install, generate files)

## Core Responsibilities

1. **Analyze Requirements**
   - Tipo de aplicación
   - Público objetivo
   - Contexto de uso
   - Brand requirements
   - Performance constraints

2. **Design Phase**
   - Apply design-system.md rules
   - Color palette selection
   - Typography hierarchy
   - Component architecture
   - Layout strategy

3. **Implementation**
   - Generate HTML5 semantic structure
   - TailwindCSS styling (no inline styles)
   - Responsive design (mobile-first)
   - Dark mode support
   - Accessibility (WCAG 2.1 AA)

4. **Animations & Effects**
   - Framer Motion (React) / GSAP (vanilla)
   - AOS for scroll effects
   - Micro interactions
   - Page transitions
   - Reduced motion support

5. **Libraries Installation**
   - Framer Motion
   - GSAP
   - Headless UI
   - Shadcn/ui
   - DaisyUI
   - AOS
   - Tailwind CSS
   - Alpine.js (if vanilla)

6. **Advanced Features**
   - Dark/Light mode toggle
   - Theme customization
   - Component documentation
   - Storybook integration
   - Performance optimization
   - Image optimization
   - SEO best practices

7. **Quality Assurance**
   - Lighthouse audit (90+)
   - Accessibility check (Axe)
   - Mobile responsive test
   - Cross-browser compatible
   - Load time optimization

## Output Deliverables

1. **HTML File(s)**
   - Semantic HTML5
   - Proper structure
   - Metadata (viewport, charset, og tags)

2. **CSS/Tailwind**
   - Complete styling
   - Custom utilities
   - Dark mode variables
   - Responsive breakpoints

3. **JavaScript**
   - Vanilla JS or framework code
   - Event handlers
   - Animations
   - Theme switching
   - Form validation

4. **Package.json**
   - All dependencies
   - Scripts for build/dev
   - Proper versions

5. **Component Library Documentation**
   - How to use each component
   - Props/variants
   - Code examples
   - Accessibility notes

6. **Design Guide**
   - Color palette with hex codes
   - Typography scale
   - Spacing system
   - Component patterns
   - Usage examples

## Design Principles

- **Clarity:** Information hierarchy is clear
- **Usability:** Intuitive interactions
- **Consistency:** Unified design language
- **Accessibility:** WCAG 2.1 AA compliant
- **Performance:** Fast load times
- **Beauty:** Modern, polished aesthetic
- **Responsiveness:** Perfect on all screens
- **Dark Mode:** Fully supported

## Technologies Mastery

- HTML5 semantic markup
- CSS3 (Grid, Flexbox, custom properties)
- TailwindCSS (all utilities, plugins)
- JavaScript (ES6+, DOM manipulation)
- TypeScript (optional but encouraged)
- Framer Motion API
- GSAP animations
- Headless UI components
- SVG animations
- Performance optimization

## Constraints

- Do NOT use inline styles (only Tailwind classes)
- Do NOT ignore accessibility
- Do NOT create bloated components
- Do NOT forget mobile responsiveness
- Do NOT use outdated practices
- Always include dark mode
- Always optimize images
- Always check performance
```

- [ ] **Step 2:** Commit

```bash
git add plugins/front-end-designer-speed-solutions/agents/designer.md
git commit -m "feat: create designer agent - frontend pro"
```

---

### Task 6: Crear comando `design.md`

**Files:** Create: `plugins/front-end-designer-speed-solutions/commands/design.md`

- [ ] **Step 1:** Crear comando /design

```markdown
# Command: /design

## Purpose

Generate professional, production-ready frontend components, UI systems, and complete designs with HTML, CSS/Tailwind, JavaScript, animations, and accessibility.

## How It Works

1. You describe what you need
2. Designer asks 3 clarifying questions:
   - Tipo de aplicación (website, app, dashboard, etc.)
   - Público objetivo (users type)
   - Contexto de uso (desktop, mobile, both)
3. Designer generates:
   - Complete HTML structure
   - TailwindCSS styling
   - JavaScript/animations
   - Dark mode support
   - Full responsiveness
   - WCAG 2.1 AA accessibility
4. Installs necessary packages
5. Delivers design guide + component documentation

## Usage

\`\`\`
/design Necesito un landing page moderno para startup de tech
\`\`\`

## What You Get

- ✅ Complete HTML file (semantic, optimized)
- ✅ TailwindCSS + custom utilities
- ✅ JavaScript with animations (Framer Motion / GSAP)
- ✅ Dark/Light mode toggle
- ✅ Mobile responsive (100% mobile-first)
- ✅ Accessibility (WCAG 2.1 AA)
- ✅ Performance optimized (Lighthouse 90+)
- ✅ package.json with dependencies
- ✅ Design system documentation
- ✅ Component usage guide
- ✅ Ready to copy-paste into production

## Technologies Used

- HTML5 semantic markup
- TailwindCSS
- Framer Motion (animations)
- GSAP (advanced effects)
- Headless UI (unstyled components)
- DaisyUI (pre-built components)
- AOS (scroll animations)
- Alpine.js (lightweight interactivity)

## Examples

### Landing Page
- Hero section with animations
- Feature cards with hover effects
- Testimonials carousel
- CTA section
- Footer with links

### Dashboard
- Responsive grid layout
- Data visualization cards
- Charts integration
- Dark mode support
- Sidebar navigation

### Product Page
- Image gallery with lightbox
- Feature showcase
- Pricing tables
- FAQ accordion
- Review section

### E-commerce
- Product grid
- Filters & sorting
- Shopping cart
- Checkout form
- Order confirmation

## Features Included

✨ **Animations**
- Smooth page transitions
- Hover effects on interactive elements
- Scroll animations
- Loading states
- Skeleton screens

🎨 **Design**
- Speed Solutions color palette
- Professional typography
- Consistent spacing
- Beautiful shadows
- Glass morphism effects

🌙 **Dark Mode**
- Complete dark theme
- Easy toggle
- Smooth transitions
- Saved preference

📱 **Responsive**
- Mobile-first approach
- Tablet optimizations
- Desktop enhancements
- Flexible images

♿ **Accessibility**
- Semantic HTML
- ARIA labels
- Keyboard navigation
- Focus indicators
- Color contrast
- Reduced motion support

⚡ **Performance**
- Optimized images
- Minified CSS/JS
- Fast load times
- Web Vitals optimized
- Lazy loading ready

## After Generation

1. Copy HTML, CSS, JS into your project
2. Run \`npm install\` for dependencies
3. Customize colors/fonts as needed
4. Add your content
5. Deploy to production
```

- [ ] **Step 2:** Commit

```bash
git add plugins/front-end-designer-speed-solutions/commands/design.md
git commit -m "docs: add design command documentation"
```

---

### Task 7: Verificar estructura y registrar en marketplace

**Files:** Check: `plugins/front-end-designer-speed-solutions/`

- [ ] **Step 1:** Verificar estructura completa

```bash
ls -la plugins/front-end-designer-speed-solutions/
cat plugins/front-end-designer-speed-solutions/.claude-plugin/plugin.json
grep "front-end-designer" .claude-plugin/marketplace.json
```

- [ ] **Step 2:** Final commit

```bash
git add -A
git commit -m "chore: finalize front-end-designer-speed-solutions plugin"
```

---

## Plan Summary

✅ **Archivos creados:** 6 (4 configs + 1 agent + 1 command)  
✅ **Funcionalidad:** Generador ÉPICO de componentes frontend profesionales  
✅ **Stack:** HTML5, TailwindCSS, Framer Motion, GSAP, Headless UI, DaisyUI  
✅ **Capacidades:** Animaciones, dark mode, responsive, a11y, performance  
✅ **Output:** Código listo para producción + documentación  

