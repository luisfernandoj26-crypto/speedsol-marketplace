# Accessibility Standards (WCAG 2.1 Level AA)

Comprehensive accessibility guidelines for Speed Solutions applications. Complies with WCAG 2.1 Level AA, ensuring usability for all users including those with disabilities.

---

## 1. FOUNDATIONAL PRINCIPLES

### WCAG 2.1 Principles
1. **Perceivable** — Users can perceive the content
2. **Operable** — Users can navigate and operate
3. **Understandable** — Users can understand the content
4. **Robust** — Content works with assistive technologies

---

## 2. SEMANTIC HTML

### Proper Element Usage

#### Headings
```html
<!-- CORRECT -->
<h1>Page Title</h1>
<h2>Section Header</h2>
<h3>Subsection</h3>

<!-- INCORRECT - avoid skipping levels -->
<h1>Title</h1>
<h3>Subsection</h3> <!-- Should be h2 -->
```

#### Buttons vs Links
```html
<!-- Button: Triggers action -->
<button onclick="handleSubmit()">Submit</button>

<!-- Link: Navigates to URL -->
<a href="/page">Go to Page</a>

<!-- NOT: Using divs as buttons -->
<div onclick="doSomething()" role="button"><!-- Bad --></div>
```

#### Form Structure
```html
<!-- CORRECT -->
<form>
  <label for="email">Email Address</label>
  <input id="email" type="email" required />
  
  <label for="password">Password</label>
  <input id="password" type="password" required />
  
  <button type="submit">Login</button>
</form>

<!-- INCORRECT - missing labels -->
<form>
  <input type="email" placeholder="Email" />
  <input type="password" placeholder="Password" />
  <button>Login</button>
</form>
```

#### Lists
```html
<!-- Unordered list -->
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
</ul>

<!-- Ordered list -->
<ol>
  <li>First step</li>
  <li>Second step</li>
</ol>

<!-- Description list -->
<dl>
  <dt>Term</dt>
  <dd>Definition</dd>
</dl>
```

---

## 3. COLOR & CONTRAST

### Contrast Ratios (WCAG AA)

| Content Type | Ratio | Example |
|---|---|---|
| Normal text | 4.5:1 | #333 on #FFF |
| Large text (18px+) | 3:1 | #666 on #FFF |
| UI Components | 3:1 | Button border |
| Graphical objects | 3:1 | Icons, charts |

### Testing Color Combinations
```
Dark Gray (#333) on White (#FFF): 19.56:1 ✓ Pass
Primary Blue (#0066CC) on White (#FFF): 8.59:1 ✓ Pass
Error Red (#DC3545) on White (#FFF): 5.16:1 ✓ Pass
Medium Gray (#999) on White (#FFF): 5.74:1 ✓ Pass
Light Gray (#CCC) on White (#FFF): 1.48:1 ✗ Fail
```

### Color Usage Rules
1. Never use color alone to convey meaning
2. Always pair color with text, icons, or patterns
3. Check combinations with tools (WCAG Contrast Checker, Axe)

**Example:**
```html
<!-- CORRECT: Color + text -->
<span class="text-success">✓ Profile complete</span>

<!-- CORRECT: Color + icon -->
<button class="btn-error">
  <IconClose /> Delete
</button>

<!-- INCORRECT: Color alone -->
<div style="color: red;">Form has errors</div> <!-- No context -->
```

---

## 4. KEYBOARD NAVIGATION

### Keyboard Support Requirements

#### Tab Order
```html
<!-- Natural DOM order (preferred) -->
<button>First</button>
<button>Second</button>
<button>Third</button>

<!-- Or use tabindex (when necessary) -->
<button tabindex="1">First</button>
<button tabindex="2">Second</button>
```

#### Skip Links
```html
<!-- At top of page -->
<a href="#main-content" class="skip-link">
  Skip to main content
</a>

<!-- Main content anchor -->
<main id="main-content">
  Page content here
</main>
```

#### Keyboard Events
| Key | Action | Example |
|---|---|---|
| Tab | Move forward | Navigate between buttons |
| Shift+Tab | Move backward | Navigate between buttons |
| Enter | Activate button | Submit form, click link |
| Space | Activate button | Checkbox toggle |
| Arrow Up/Down | Menu navigation | Select dropdown option |
| Escape | Close modal | Dismiss popup |

### Component Keyboard Behavior
```javascript
// Button
element.addEventListener('keydown', (e) => {
  if (e.key === 'Enter' || e.key === ' ') {
    handleClick();
  }
});

// Select/Dropdown
element.addEventListener('keydown', (e) => {
  if (e.key === 'ArrowUp') selectPrevious();
  if (e.key === 'ArrowDown') selectNext();
  if (e.key === 'Enter') confirm();
  if (e.key === 'Escape') close();
});

// Modal
element.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') closeModal();
});
```

---

## 5. ARIA (Accessible Rich Internet Applications)

### ARIA Attributes

#### Landmarks (via role)
```html
<header role="banner">
  <nav role="navigation">
    <ul>
      <li><a href="/">Home</a></li>
      <li><a href="/about">About</a></li>
    </ul>
  </nav>
</header>

<main role="main">Content here</main>

<aside role="complementary">Sidebar</aside>

<footer role="contentinfo">Footer</footer>
```

#### Labels
```html
<!-- aria-label: For icon-only buttons -->
<button aria-label="Close menu" onclick="closeMenu()">
  ✕
</button>

<!-- aria-labelledby: Connect label to element -->
<h2 id="dialog-title">Delete Account</h2>
<div role="dialog" aria-labelledby="dialog-title">
  Are you sure?
</div>

<!-- aria-describedby: Add description -->
<input 
  type="password"
  aria-describedby="pwd-hint"
/>
<small id="pwd-hint">
  Password must be 8+ characters
</small>
```

#### States
```html
<!-- aria-expanded: Toggle state -->
<button 
  aria-expanded="false" 
  aria-controls="menu"
  onclick="toggleMenu()"
>
  Menu
</button>
<ul id="menu" hidden>
  <!-- Menu items -->
</ul>

<!-- aria-disabled: For inactive elements -->
<button aria-disabled="true" disabled>
  Disabled
</button>

<!-- aria-pressed: Toggle buttons -->
<button aria-pressed="false" onclick="toggleBold()">
  Bold
</button>

<!-- aria-current: Current page in navigation -->
<a href="/" aria-current="page">Home</a>
<a href="/about">About</a>
```

#### Live Regions
```html
<!-- aria-live: Announce dynamic changes -->
<div aria-live="polite" aria-atomic="true">
  3 items added to cart
</div>

<!-- aria-busy: Show loading state -->
<div aria-busy="true">
  Loading...
</div>
```

---

## 6. FORM ACCESSIBILITY

### Form Structure
```html
<form>
  <!-- Required field indicator -->
  <fieldset>
    <legend>Personal Information</legend>
    
    <!-- Input with label -->
    <div class="form-group">
      <label for="name">
        Full Name 
        <span aria-label="required">*</span>
      </label>
      <input 
        id="name"
        type="text"
        required
        aria-required="true"
        aria-describedby="name-error"
      />
      <small id="name-error" class="error">
        This field is required
      </small>
    </div>

    <!-- Checkbox -->
    <div class="form-group">
      <input 
        id="agree"
        type="checkbox"
        required
      />
      <label for="agree">
        I agree to the terms
      </label>
    </div>

    <!-- Radio group -->
    <fieldset>
      <legend>Select an option</legend>
      <div>
        <input id="opt1" type="radio" name="choice" />
        <label for="opt1">Option 1</label>
      </div>
      <div>
        <input id="opt2" type="radio" name="choice" />
        <label for="opt2">Option 2</label>
      </div>
    </fieldset>
  </fieldset>

  <!-- Error summary (when form fails validation) -->
  <div role="alert" aria-labelledby="error-title">
    <h2 id="error-title">Form has errors:</h2>
    <ul>
      <li><a href="#email">Email is invalid</a></li>
      <li><a href="#password">Password is required</a></li>
    </ul>
  </div>

  <button type="submit">Submit</button>
</form>
```

### Validation Messages
```html
<!-- Real-time validation -->
<input 
  type="email"
  aria-invalid="false"
  aria-describedby="email-error"
  onchange="validateEmail()"
/>
<small 
  id="email-error" 
  role="alert"
  style="color: #dc3545;"
  hidden
>
  Please enter a valid email
</small>
```

---

## 7. IMAGES & MEDIA

### Alternative Text
```html
<!-- Informative image -->
<img 
  src="chart.png"
  alt="Sales trend 2026: Q1 $100K, Q2 $150K, Q3 $180K"
/>

<!-- Decorative image -->
<img 
  src="divider.png"
  alt=""
  aria-hidden="true"
/>

<!-- Complex image (use long description) -->
<img 
  src="org-chart.png"
  alt="Company organization chart"
  usemap="#org-map"
/>
<map name="org-map">
  <area href="/ceo" alt="CEO - John Doe" />
  <area href="/cto" alt="CTO - Jane Smith" />
</map>

<!-- Or link to description -->
<img 
  src="complex-diagram.png"
  alt="Complex diagram"
/>
<a href="diagram-description.html">View detailed description</a>
```

### Video & Audio
```html
<!-- Video with captions -->
<video controls>
  <source src="video.mp4" type="video/mp4" />
  <track 
    kind="captions" 
    src="captions.vtt" 
    srclang="en"
  />
  Your browser doesn't support video
</video>

<!-- Audio transcript -->
<audio controls>
  <source src="podcast.mp3" type="audio/mpeg" />
</audio>
<details>
  <summary>Transcript</summary>
  <p>[Full transcript of audio]</p>
</details>
```

---

## 8. FOCUS MANAGEMENT

### Focus Indicators
```css
/* Visible focus ring */
*:focus {
  outline: 2px solid #0066CC;
  outline-offset: 2px;
}

/* Or use box-shadow for button-like elements */
button:focus {
  box-shadow: 0 0 0 3px rgba(0, 102, 204, 0.3);
}

/* Don't remove focus styles */
*:focus {
  outline: none !important; /* NEVER do this */
}
```

### Focus Management in JavaScript
```javascript
// Modal: Move focus to first focusable element
function openModal() {
  const modal = document.getElementById('modal');
  modal.showModal();
  const firstFocusable = modal.querySelector('button, [href], input');
  firstFocusable.focus();
}

// Cleanup: Return focus when closing
function closeModal() {
  const modal = document.getElementById('modal');
  modal.close();
  triggerButton.focus(); // Return focus to trigger
}

// Trap focus within modal
function handleKeydown(e) {
  if (e.key === 'Tab') {
    const focusableElements = modal.querySelectorAll('button, [href], input');
    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];

    if (e.shiftKey && document.activeElement === firstElement) {
      lastElement.focus();
      e.preventDefault();
    } else if (!e.shiftKey && document.activeElement === lastElement) {
      firstElement.focus();
      e.preventDefault();
    }
  }
}
```

---

## 9. TESTING & VALIDATION

### Automated Testing Tools
- **axe DevTools**: Browser extension for accessibility audits
- **WAVE**: WebAIM accessibility evaluation tool
- **Lighthouse**: Chrome DevTools accessibility audit
- **NVDA**: Free screen reader (Windows)
- **JAWS**: Commercial screen reader

### Manual Testing Checklist
```
Navigation:
  [ ] Can navigate entire site with keyboard only (no mouse)
  [ ] Focus indicators visible at all times
  [ ] Tab order is logical (top-to-bottom, left-to-right)
  [ ] No keyboard traps

Content:
  [ ] Page structure with headings (H1-H6 in order)
  [ ] Images have descriptive alt text
  [ ] Color not used as sole indicator
  [ ] Contrast ratios meet 4.5:1 (normal text)

Forms:
  [ ] All inputs have associated labels
  [ ] Required fields marked
  [ ] Error messages clear and linked to fields
  [ ] Form can be submitted with keyboard

Dynamic Content:
  [ ] Changes announced with ARIA live regions
  [ ] Modal announces when opened
  [ ] Loading states visible to all
  [ ] Content updates don't reset focus

Mobile/Touch:
  [ ] Touch targets minimum 44x44px
  [ ] Zoom still works on mobile
  [ ] Text resize up to 200% works
```

---

## 10. IMPLEMENTATION CHECKLIST

### Per Component

#### Buttons
- [ ] Semantic `<button>` element
- [ ] Visible focus indicator
- [ ] Keyboard accessible (Enter/Space)
- [ ] Proper aria-label for icon-only buttons
- [ ] aria-pressed for toggle buttons
- [ ] Disabled state properly marked

#### Forms
- [ ] All inputs have `<label>` elements
- [ ] Labels associated via `for` and `id`
- [ ] Required fields marked
- [ ] Error messages linked via aria-describedby
- [ ] Fieldsets with legends for grouped inputs
- [ ] Form submission feedback

#### Modals
- [ ] Focus trapped within modal
- [ ] Close button present
- [ ] aria-modal and aria-labelledby
- [ ] Can close with Escape key
- [ ] Focus returns when closed

#### Navigation
- [ ] Semantic `<nav>` with landmarks
- [ ] Current page marked with aria-current
- [ ] Dropdown menus keyboard accessible
- [ ] Skip links present

#### Images
- [ ] All images have alt attributes
- [ ] Decorative images have empty alt and aria-hidden
- [ ] Complex images have long descriptions
- [ ] SVGs have titles/descriptions

---

## 11. RESOURCES

### Guidelines
- [WCAG 2.1 Official](https://www.w3.org/WAI/WCAG21/quickref/)
- [MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)
- [WebAIM](https://webaim.org/)

### Tools
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [axe DevTools](https://www.deque.com/axe/devtools/)
- [NVDA Screen Reader](https://www.nvaccess.org/)
- [JAWS Screen Reader](https://www.freedomscientific.com/products/software/jaws/)

---

**Last Updated**: 2026-04-22
**Version**: 1.0.0
**Compliance**: WCAG 2.1 Level AA
