---
description: Professional front-end design — design system, components, accessibility, responsive layouts, and animations
allowed-tools: Read, Grep, Write
---

# Command: /design

**Purpose**: Access Speed Solutions' world-class front-end design capabilities. Design UI components, create responsive layouts, ensure accessibility compliance, and apply animations using the Speed Solutions design system.

---

## What You Can Do

### Design Components
Design professional UI components (buttons, forms, modals, cards, etc.) with:
- Full design system integration (colors, typography, spacing, shadows)
- Multiple interactive states (hover, active, focus, disabled, loading, error)
- Complete accessibility support (WCAG 2.1 AA compliance)
- Responsive designs for mobile, tablet, and desktop
- HTML/CSS/React code examples

### Create Layouts
Design responsive page layouts and templates with:
- Mobile-first responsive design
- Semantic HTML structure
- Proper use of grids, flexbox, and containers
- Keyboard navigation support
- Touch-friendly spacing (minimum 44px × 44px touch targets)

### Ensure Accessibility
Implement WCAG 2.1 Level AA compliance with:
- Semantic HTML elements
- ARIA attributes and labels
- Keyboard navigation (Tab, Enter, Escape, Arrow keys)
- Color contrast verification (4.5:1 for text)
- Focus indicators and visual feedback
- Screen reader support

### Apply Animations
Design smooth, purposeful micro-interactions using:
- Framer Motion (React components)
- GSAP (complex animations)
- AOS (scroll animations)
- CSS transitions and keyframes
- Performance optimization (GPU acceleration)
- Motion accessibility (prefers-reduced-motion)

### Reference Design System
Access Speed Solutions' complete design system:
- **Colors**: Primary blue, secondary teal, semantic colors (success, error, warning, info)
- **Typography**: Font families, sizes, weights, line heights
- **Spacing**: 8px scale (xs: 4px to 4xl: 80px)
- **Shadows**: Elevation system (subtle to extra-large)
- **Transitions**: Timing functions and duration scales
- **Borders**: Radius and width specifications
- **Breakpoints**: Mobile (< 480px), Tablet (480-1024px), Desktop (1024px+)

---

## How It Works

### Step 1: Describe Your Design Need

Provide a detailed request, such as:
- "Design a dashboard statistics card component"
- "Create a responsive navigation menu for mobile and desktop"
- "Design a form with email, password, and terms acceptance"
- "Design an error state page with recovery options"

The command will:
1. Ask 1-2 clarifying questions (target users, specific requirements, constraints)
2. Load the Speed Solutions design system and reference materials
3. Analyze your request and design approach

### Step 2: Receive Design Specification

You'll get a comprehensive design specification including:

**Component Structure**
- Semantic HTML markup
- Component hierarchy and layout
- Visual hierarchy using typography and spacing

**Design Tokens Applied**
- Color values from design palette
- Typography sizes and weights
- Spacing and padding values
- Shadow elevations
- Border radius specifications

**Interactive States**
- Default state styling
- Hover state (shadow lift, opacity, color change)
- Active/pressed state
- Focus state (outline ring, focus-visible)
- Disabled state (opacity reduction, cursor)
- Loading state (spinner, disabled interaction)
- Error state (red border, error message)

**Responsive Design**
- Mobile-first base styles
- Tablet breakpoint adjustments (@media 768px+)
- Desktop breakpoint enhancements (@media 1024px+)
- Touch target sizing (minimum 44px)

**Accessibility Features**
- Semantic HTML elements (`<button>`, `<label>`, `<form>`, etc.)
- ARIA attributes (aria-label, aria-describedby, aria-expanded, etc.)
- Keyboard support (Tab navigation, Enter activation, Escape to close)
- Color contrast ratios verified
- Focus indicators visible
- Screen reader announcements

**Animation & Transitions**
- Hover animations (lift, scale, color shift)
- Entrance/exit animations (fade, slide, zoom)
- Duration and easing functions
- Performance optimization notes
- Accessibility considerations (prefers-reduced-motion)

**Code Examples**
- HTML/CSS structure
- React component example (if applicable)
- Usage patterns and API
- Error handling examples

---

## Usage Examples

### Example 1: Design a Button Component

**Request**:
```
/design

Design a primary action button component that:
- Is prominent and calls to action (CTA)
- Supports multiple sizes (small, medium, large)
- Shows loading state during async operations
- Is fully accessible and keyboard-navigable
- Works on mobile and desktop
```

**You'll Receive**:
- Button structure with semantic `<button>` element
- All state designs (default, hover, active, focus, disabled, loading)
- Responsive sizing across breakpoints
- Color tokens from design system
- ARIA labels for loading state
- Keyboard support (Enter, Space activation)
- React code example with loading spinner

### Example 2: Design a Form Layout

**Request**:
```
/design

Create a user registration form with:
- Email and password fields
- Password strength indicator
- Terms acceptance checkbox
- Submit button
- Error display and validation feedback
- Mobile and desktop responsive layouts
```

**You'll Receive**:
- Form structure with `<form>` and `<fieldset>` elements
- Input field designs with validation states
- Label associations (proper `for` and `id` attributes)
- Error message placement and styling
- Checkbox design with accessibility features
- Responsive form layout (single column on mobile, optimized on desktop)
- HTML form example with error summary
- ARIA attributes for form validation

### Example 3: Design a Navigation Menu

**Request**:
```
/design

Design a responsive navigation menu that:
- Works as horizontal top bar on desktop
- Collapses to mobile hamburger menu on small screens
- Supports dropdown submenus
- Highlights the current page
- Is fully keyboard accessible
- Shows active states clearly
```

**You'll Receive**:
- Navigation bar structure for desktop and mobile
- Hamburger menu icon and toggle button
- Dropdown menu interaction states
- Mobile-optimized touch targets (44px+)
- Desktop horizontal layout
- Keyboard navigation (Tab, Enter, Arrow keys)
- aria-current="page" for current navigation item
- ARIA labels for navigation menu
- CSS for responsive behavior (@media queries)

---

## Output Format

### Design Specification Template

```markdown
## Component: [Component Name]

### Purpose
[Why does this component exist? What user problem does it solve?]

### Design System Tokens Used
- **Colors**: [list color tokens and hex values]
- **Typography**: [font size, weight, line-height]
- **Spacing**: [padding, margin, gap values]
- **Shadows**: [elevation level used]
- **Transitions**: [duration, easing for interactions]
- **Breakpoints**: [responsive design considerations]

### Component States

#### Default State
[Description and styling]

#### Hover State
- **Effect**: [visual change]
- **Animation**: [transition details]
- **Duration**: [timing]

#### Focus State
- **Indicator**: [outline, ring, shadow]
- **Accessibility**: [for keyboard navigation]

#### Disabled State
- **Visual**: [opacity, cursor, color changes]
- **Interaction**: [no user interaction]

#### Loading State
- **Indicator**: [spinner, progress bar]
- **Feedback**: [button disabled, message]

#### Error State
- **Visual**: [red border, error message]
- **Associated Text**: [error description]

### Responsive Design

#### Mobile (< 480px)
[Mobile-optimized styles]

#### Tablet (480px - 1024px)
[Tablet adjustments]

#### Desktop (1024px+)
[Full desktop experience]

### Accessibility Features

**Semantic HTML**:
- [Required elements: button, label, form, etc.]

**ARIA Attributes**:
- [aria-label, aria-describedby, aria-expanded, etc.]

**Keyboard Support**:
- Tab: Navigate to element
- Enter/Space: Activate button
- Escape: Close modal/menu
- Arrow Keys: Navigate options

**Contrast Ratio**: [4.5:1 or better]

**Focus Indicator**: [Visible outline or ring]

### Code Example

[HTML, CSS, React component code]

### Usage Notes
[Implementation tips, performance considerations, browser support]
```

---

## Technologies & Stack

### Front-End Frameworks
- **React**: Modern component-based framework with hooks
- **Blazor**: .NET server-side rendering with C# components
- **Vanilla JavaScript**: For lightweight, framework-agnostic components

### Styling
- **Tailwind CSS**: Utility-first CSS for rapid styling
- **CSS Modules**: Scoped component styling
- **CSS-in-JS**: Styled Components, Emotion for dynamic styles
- **CSS Variables**: Design tokens (colors, spacing, typography)

### Animation Libraries
- **Framer Motion**: React animation and gesture library
- **GSAP**: Professional-grade animation library
- **AOS**: Scroll-triggered animations
- **CSS Keyframes**: Native CSS animations

### Accessibility & Testing
- **axe DevTools**: Accessibility audit
- **WAVE**: Web accessibility evaluation
- **Lighthouse**: Chrome DevTools audit
- **NVDA/JAWS**: Screen reader testing
- **WCAG 2.1**: Accessibility compliance standard

---

## Design System Resources

The following design system files are automatically loaded and referenced:

1. **design-system.md** — Colors, typography, spacing, shadows, transitions, breakpoints
2. **component-library.md** — Pre-designed UI components and patterns
3. **animation-library.md** — Animation effects, timing, and performance
4. **accessibility-standards.md** — WCAG 2.1 Level AA compliance guidelines

---

## Key Features

### Comprehensive Design Output
- Full visual specification with design tokens
- All interactive states documented
- Responsive design for multiple breakpoints
- Accessibility features detailed
- Code-ready HTML/CSS/React examples

### Design System Compliance
- Uses Speed Solutions colors, typography, and spacing
- Consistent design language across all components
- Traceable design token usage
- Design system extensions documented

### Accessibility First
- WCAG 2.1 Level AA compliance guaranteed
- Semantic HTML structure
- Keyboard navigation fully supported
- ARIA labels and attributes included
- Color contrast verified
- Screen reader compatible

### Responsive & Mobile-First
- Mobile designs come first
- Touch-friendly spacing (44px+ targets)
- Adaptive layouts for all breakpoints
- Tested across device sizes

### Production-Ready
- Code examples ready for implementation
- Performance optimizations included
- Browser compatibility noted
- Implementation tips provided

---

## Tips for Best Results

1. **Be Specific**: Provide context about the component's purpose and users
2. **Ask Questions**: If you need clarification, ask before the design starts
3. **Mention Constraints**: "Works on React/Blazor", "Mobile first", etc.
4. **Consider States**: Think about error, loading, disabled, and empty states
5. **Test Accessibility**: Review keyboard navigation and screen reader support
6. **Reference Examples**: Point to similar components if applicable

---

## No Arguments? No Problem!

If you use `/design` without any request, the agent will ask you:
1. "What would you like to design?" (component, page, feature, etc.)
2. "Who will be using this component?" (end users, internal teams, etc.)
3. "Are there any specific requirements or constraints?"

---

**Available**: Speed Solutions Design Team
**Last Updated**: 2026-04-22
**Compliance**: WCAG 2.1 Level AA
