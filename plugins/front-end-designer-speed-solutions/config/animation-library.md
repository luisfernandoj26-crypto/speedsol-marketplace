# Animation & Effects Library

Comprehensive animation library for Speed Solutions front-end applications. Integrates Framer Motion (React), GSAP, AOS (Animate On Scroll), and Three.js for advanced visual effects.

---

## 1. ANIMATION LIBRARIES

### Framer Motion (React)
**Installation:**
```bash
npm install framer-motion
```

**Use Cases:**
- Component entrance/exit animations
- Gesture-based interactions (drag, hover, tap)
- Page transitions
- Layout animations (shared layout animation)

**Example:**
```jsx
import { motion } from 'framer-motion';

<motion.button
  whileHover={{ scale: 1.05 }}
  whileTap={{ scale: 0.95 }}
  transition={{ duration: 0.2 }}
>
  Hover Me
</motion.button>
```

### GSAP (GreenSock Animation Platform)
**Installation:**
```bash
npm install gsap
```

**Use Cases:**
- Complex multi-element animations
- Timeline sequencing
- Scroll-triggered animations
- Performance-critical animations

**Example:**
```javascript
gsap.to('.element', {
  duration: 1,
  x: 100,
  opacity: 0.8,
  ease: 'power2.inOut'
});
```

### AOS (Animate On Scroll)
**Installation:**
```bash
npm install aos
```

**Use Cases:**
- Entrance animations on scroll
- Parallax effects
- Fade-in/slide-in on viewport enter
- Lightweight scroll animations

**Example:**
```html
<div data-aos="fade-up" data-aos-duration="1000">
  Animates when scrolled into view
</div>
```

### Three.js (3D Graphics)
**Installation:**
```bash
npm install three
```

**Use Cases:**
- 3D product visualizations
- Interactive 3D scenes
- Advanced visual effects
- Data visualization in 3D

---

## 2. PREDEFINED ANIMATIONS

### Entrance Animations (150ms - 500ms)

#### Fade In
- Start: opacity 0
- End: opacity 1
- Duration: 200ms
- Easing: ease-out
- Use: Default entrance for UI elements

#### Slide In (from left)
- Start: transform translateX(-100px), opacity 0
- End: transform translateX(0), opacity 1
- Duration: 300ms
- Easing: ease-out
- Use: Navigation items, sidebar elements

#### Slide In (from top)
- Start: transform translateY(-50px), opacity 0
- End: transform translateY(0), opacity 1
- Duration: 300ms
- Easing: ease-out
- Use: Modal headers, dropdown menus

#### Zoom In
- Start: transform scale(0.95), opacity 0
- End: transform scale(1), opacity 1
- Duration: 200ms
- Easing: ease-out
- Use: Cards, buttons, focus states

#### Bounce In
- Start: transform scale(0.3), opacity 0
- End: transform scale(1), opacity 1
- Duration: 500ms
- Easing: cubic-bezier(0.34, 1.56, 0.64, 1)
- Use: Alerts, important notifications

### Exit Animations (100ms - 300ms)

#### Fade Out
- Start: opacity 1
- End: opacity 0
- Duration: 150ms
- Easing: ease-in
- Use: Component unmount, dismiss modals

#### Slide Out (to right)
- Start: transform translateX(0)
- End: transform translateX(100px), opacity 0
- Duration: 250ms
- Easing: ease-in
- Use: Sidebar collapse, element removal

#### Scale Down
- Start: transform scale(1), opacity 1
- End: transform scale(0.95), opacity 0
- Duration: 200ms
- Easing: ease-in
- Use: Menu close, button click feedback

### Hover/Interactive Animations (150ms - 200ms)

#### Button Lift
- Hover: transform translateY(-2px), box-shadow elevation-2
- Duration: 150ms
- Easing: ease-out
- Use: Primary buttons, clickable elements

#### Button Press
- Active: transform translateY(1px), box-shadow elevation-1
- Duration: 100ms
- Easing: ease-in
- Use: All button variants on active state

#### Icon Rotate
- Hover: transform rotate(180deg)
- Duration: 300ms
- Easing: ease-in-out
- Use: Refresh icons, expand/collapse toggles

#### Underline Expand
- Hover: width 0% → 100% (underline)
- Duration: 200ms
- Easing: ease-in-out
- Use: Navigation links, text links

#### Color Shift
- Hover: color #0066CC → #003D7A
- Duration: 150ms
- Easing: ease-in-out
- Use: Text colors, icon colors

### Loading Animations (Infinite)

#### Spinner (Rotation)
- Animation: rotate 0deg → 360deg
- Duration: 800ms
- Easing: linear
- Use: Loading indicators, async operations

#### Pulse
- Animation: opacity 1 → 0.5 → 1
- Duration: 2000ms
- Easing: ease-in-out
- Use: Skeleton screens, placeholder content

#### Bounce (Vertical)
- Animation: translateY(0px) → translateY(-10px) → translateY(0px)
- Duration: 1000ms
- Easing: ease-in-out
- Use: Loading dots, attention seekers

#### Shimmer (Skeleton)
- Animation: Linear gradient slide left to right
- Duration: 1500ms
- Direction: RTL (right-to-left)
- Use: Skeleton loaders during data fetch

### Page Transition Animations (300ms - 500ms)

#### Fade Through
- Current page: opacity 1 → 0 (150ms)
- New page: opacity 0 → 1 (150ms)
- Total: 300ms
- Easing: ease-in-out
- Use: Standard page navigation

#### Slide Over
- Current page: transform translateX(-100%) (300ms)
- New page: transform translateX(0) (300ms, parallel)
- Easing: ease-in-out
- Use: SPA routing, modal slides

#### Expand
- Start: transform scale(0.95), opacity 0
- End: transform scale(1), opacity 1
- Duration: 300ms
- Easing: ease-out
- Use: Modal/dialog openings

---

## 3. TIMING FUNCTIONS (CSS/JS)

### Ease Functions
```css
--ease-linear: cubic-bezier(0, 0, 1, 1);
--ease-in: cubic-bezier(0.4, 0, 1, 1);
--ease-out: cubic-bezier(0, 0, 0.2, 1);
--ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
--ease-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);
--ease-elastic: cubic-bezier(0.68, -0.55, 0.265, 1.55);
```

### Duration Scale
```
Fast:     100ms, 150ms
Normal:   200ms, 300ms
Slow:     500ms, 700ms
Very Slow: 1000ms+
```

---

## 4. VISUAL EFFECTS

### Hover Effects

#### Glass Morphism
```css
backdrop-filter: blur(10px);
background: rgba(255, 255, 255, 0.1);
border: 1px solid rgba(255, 255, 255, 0.2);
```

#### Glow Effect
```css
box-shadow: 0 0 20px rgba(59, 130, 246, 0.6);
filter: drop-shadow(0 0 10px rgba(59, 130, 246, 0.4));
```

#### Color Overlay
```css
background: linear-gradient(rgba(59, 130, 246, 0.1), rgba(59, 130, 246, 0.1)), url(...);
```

#### Blur Transition
```css
filter: blur(0px) → blur(2px) on hover
transition: filter 200ms ease-in-out;
```

### Advanced Effects

#### Parallax Scrolling
- **Tool**: GSAP ScrollTrigger or AOS
- **Offset**: Different scroll speeds for background/foreground
- **Example**: Hero image moves slower than scroll

#### Gradient Animation
```css
background: linear-gradient(-45deg, #ee7752, #e73c7e, #23a6d5, #23d5ab);
background-size: 400% 400%;
animation: gradient 15s ease infinite;

@keyframes gradient {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}
```

#### Morphing Shapes
- **Tool**: SVG morphing with Framer Motion
- **Use**: Logo animations, shape transitions

#### Particle Effects
- **Tool**: Three.js or custom Canvas
- **Use**: Celebrations, special moments, visual embellishment

---

## 5. ACCESSIBILITY CONSIDERATIONS

### Motion Preferences
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Guidelines
1. Respect `prefers-reduced-motion` system preference
2. Keep animations under 500ms for UI interactions
3. Avoid seizure-inducing animations (flashing, rapid movement)
4. Don't block important content with animations
5. Provide static alternatives to animated content

---

## 6. PERFORMANCE OPTIMIZATION

### GPU Acceleration
Use `will-change` and `transform` for smooth animations:
```css
.element {
  will-change: transform, opacity;
  transform: translateZ(0);
}
```

### Debouncing Animations
```javascript
let animationTimeout;
element.addEventListener('mousemove', () => {
  clearTimeout(animationTimeout);
  animationTimeout = setTimeout(() => {
    // Trigger animation
  }, 100);
});
```

### Lazy Loading Animations
Only animate elements visible in viewport:
```javascript
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('animate');
    }
  });
});
```

---

## 7. ANIMATION EXAMPLES BY COMPONENT

### Button Hover State
```css
button {
  transition: all 150ms ease-out;
}

button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.12);
}

button:active {
  transform: translateY(1px);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
}
```

### Modal Entrance
```jsx
<motion.div
  initial={{ opacity: 0, scale: 0.95, y: 20 }}
  animate={{ opacity: 1, scale: 1, y: 0 }}
  exit={{ opacity: 0, scale: 0.95 }}
  transition={{ duration: 0.2 }}
>
  Modal Content
</motion.div>
```

### List Item Stagger
```jsx
<motion.ul>
  <AnimatePresence>
    {items.map((item) => (
      <motion.li
        key={item.id}
        initial={{ opacity: 0, x: -20 }}
        animate={{ opacity: 1, x: 0 }}
        exit={{ opacity: 0, x: 20 }}
        transition={{ duration: 0.3 }}
      >
        {item.name}
      </motion.li>
    ))}
  </AnimatePresence>
</motion.ul>
```

---

**Last Updated**: 2026-04-22
**Version**: 1.0.0
