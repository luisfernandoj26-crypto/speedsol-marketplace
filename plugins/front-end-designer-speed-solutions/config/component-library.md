# Component Library Reference

Reusable UI components for Speed Solutions applications (FlowLink, PrintLink, BlazorWebFrontEnd).

---

## Base Components

### Button
**Purpose:** Trigger actions, navigate, submit forms

**Variants:**
- Primary (solid blue, full-width CTA)
- Secondary (teal outline)
- Tertiary (ghost, text-only)
- Destructive (red, danger actions)
- Disabled (grayed out, no interaction)

**Sizes:**
- Small (32px height, 12px text)
- Medium (40px height, 14px text) — default
- Large (48px height, 16px text)

**States:**
- Normal
- Hover (darker color, slight lift shadow)
- Active (pressed appearance, no shadow)
- Focus (outline, ring-based)
- Disabled (opacity 0.5, cursor not-allowed)
- Loading (spinner icon, disabled interaction)

**HTML (Blazor Component):**
```blazor
<Button Variant="primary" Size="medium" OnClick="@HandleClick">
    Click Me
</Button>

<Button Variant="destructive" IsLoading="isSubmitting">
    Delete Account
</Button>
```

---

### Input Field
**Purpose:** Collect user text, email, password, numbers

**Types:**
- Text
- Email
- Password
- Number
- Textarea (multi-line)
- Masked (phone, credit card)

**States:**
- Default (border: 1px gray, background white)
- Focused (border: 2px blue, shadow elevation-1)
- Filled (background light gray after focus)
- Error (border red, error message below)
- Disabled (background gray, cursor not-allowed)
- Success (border green checkmark on right)

**Validation:**
- Real-time or on-blur
- Error message display below input
- Success indicators (green check)

**HTML (Blazor):**
```blazor
<InputField 
    Type="email" 
    Label="Email Address"
    Placeholder="name@company.com"
    IsRequired="true"
    ErrorMessage="@emailError"
    OnChange="@((string value) => email = value)" />

<InputField 
    Type="textarea"
    Label="Description"
    Rows="4"
    MaxLength="500" />
```

---

### Select / Dropdown
**Purpose:** Choose from predefined options

**Features:**
- Single select (standard dropdown)
- Multi-select (checkboxes, tag display)
- Searchable (filter options in real-time)
- Grouping (optgroups)
- Virtualization (large lists 1000+)

**States:**
- Closed (show selected value)
- Open (show all options)
- Hover option (light background)
- Selected (blue checkmark)
- Disabled (grayed out)

**HTML (Blazor):**
```blazor
<Select 
    Label="Choose Department"
    Options="@departments"
    SelectedValue="@selected"
    OnChange="@HandleChange"
    IsMultiple="false"
    IsSearchable="true" />
```

---

### Checkbox
**Purpose:** Toggle binary state, multi-select

**States:**
- Unchecked (empty box)
- Checked (box with checkmark)
- Indeterminate (dash, mixed state)
- Disabled (grayed out)
- Focus (ring outline)

**Sizes:**
- Small (16px)
- Medium (20px) — default
- Large (24px)

**HTML (Blazor):**
```blazor
<Checkbox 
    Label="I agree to terms"
    IsChecked="@isAgreed"
    OnChange="@HandleChange" />

<Checkbox 
    Label="Indeterminate"
    IsIndeterminate="true" />
```

---

### Radio Button
**Purpose:** Single selection from mutually exclusive options

**Layout:**
- Horizontal (items in row)
- Vertical (items in column)

**States:**
- Unselected (empty circle)
- Selected (filled circle with dot)
- Disabled (grayed out)
- Focus (ring outline)

**HTML (Blazor):**
```blazor
<RadioGroup 
    Label="Select Priority"
    Options="@priorities"
    SelectedValue="@selected"
    Direction="vertical"
    OnChange="@HandleChange" />
```

---

### Card
**Purpose:** Container for grouped content, data display

**Structure:**
- Header (optional title, subtitle, icon)
- Body (main content area)
- Footer (optional actions, metadata)

**Variants:**
- Elevated (shadow elevation-2, default)
- Outlined (1px border, no shadow)
- Flat (no shadow, no border)

**States:**
- Default
- Hover (slight elevation increase, subtle scale)
- Interactive (clickable, pointer cursor)
- Disabled (opacity 0.5)

**HTML (Blazor):**
```blazor
<Card Variant="elevated" IsInteractive="true" OnClick="@HandleClick">
    <CardHeader>
        <h3>Dashboard Summary</h3>
    </CardHeader>
    <CardBody>
        <p>Total users: 1,234</p>
    </CardBody>
    <CardFooter>
        <Button Variant="secondary">View Details</Button>
    </CardFooter>
</Card>
```

---

### Modal / Dialog
**Purpose:** Focused interaction, confirmation, forms in overlay

**Features:**
- Backdrop (dark overlay, click-to-close optional)
- Header with close button (X icon)
- Body (scrollable if needed)
- Footer with action buttons

**Types:**
- Confirmation (title + question + OK/Cancel)
- Alert (info/error message + OK)
- Form (multi-field input)
- Custom (any content)

**Accessibility:**
- Focus trap (cycle within modal)
- Escape key to close
- ARIA labels and roles
- Announce modal opening

**HTML (Blazor):**
```blazor
<Modal 
    Title="Confirm Delete"
    IsOpen="@showConfirm"
    OnClose="@HandleClose">
    <ModalBody>
        <p>Are you sure? This cannot be undone.</p>
    </ModalBody>
    <ModalFooter>
        <Button Variant="secondary" OnClick="@Cancel">Cancel</Button>
        <Button Variant="destructive" OnClick="@Confirm">Delete</Button>
    </ModalFooter>
</Modal>
```

---

### Toast / Notification
**Purpose:** Temporary messages, status updates, feedback

**Types:**
- Success (green icon, "Action completed")
- Error (red icon, "Error occurred")
- Warning (orange icon, "Warning message")
- Info (blue icon, "FYI message")

**Behavior:**
- Auto-dismiss after 4-6 seconds (except errors)
- Stack vertically (bottom-right default)
- Click to dismiss manually
- Accessible announcement (aria-live)

**HTML (Blazor/JavaScript):**
```blazor
<Toast 
    Type="success"
    Message="Profile updated successfully"
    Duration="4000" />

@code {
    private void ShowNotification() {
        ToastService.Show("Profile saved!", NotificationType.Success);
    }
}
```

---

### Badge
**Purpose:** Label status, count, category

**Variants:**
- Solid (filled background)
- Outline (border only)
- Ghost (text only, minimal)

**Colors:**
- Primary (blue)
- Secondary (teal)
- Success (green)
- Warning (orange)
- Error (red)
- Info (blue)

**Sizes:**
- Small (8px padding, 12px text)
- Medium (10px padding, 14px text) — default
- Large (12px padding, 16px text)

**HTML (Blazor):**
```blazor
<Badge Variant="solid" Color="success">Active</Badge>
<Badge Variant="outline" Color="warning">Pending</Badge>
<Badge Variant="ghost" Color="error" Count="3">Errors</Badge>
```

---

### Spinner / Progress Indicator
**Purpose:** Show loading state, progress

**Types:**
- Spinner (rotating animation, indeterminate)
- Progress Bar (horizontal bar, determinate %)
- Progress Ring (circular, determinate %)

**States:**
- Loading/In Progress
- Complete (100%)
- Error (red color)

**HTML (Blazor):**
```blazor
<Spinner Size="small" Color="primary" />

<ProgressBar 
    Value="@progress"
    Max="100"
    ShowLabel="true" />

<ProgressRing 
    Value="@completionPercent"
    Radius="40" />
```

---

### Avatar
**Purpose:** User profile image, icon placeholder

**Types:**
- Image (photo)
- Initials (letters, fallback)
- Icon (user, group, role)

**Sizes:**
- Small (32px)
- Medium (48px)
- Large (64px)
- Extra Large (96px)

**States:**
- Online (green dot indicator)
- Offline (gray dot indicator)
- Busy (red indicator)

**HTML (Blazor):**
```blazor
<Avatar 
    ImageUrl="https://..."
    Name="John Doe"
    Size="medium"
    Status="online" />

<Avatar 
    Initials="JD"
    Color="primary"
    Size="small" />
```

---

## Composite Components

### Form
**Structure:**
- Form wrapper (handles validation, submission)
- Input fields (organized vertically)
- Buttons (submit, cancel, reset)
- Error summary (if validation fails)

**Features:**
- Validation feedback (inline + summary)
- Required field indicators (*)
- Helper text below inputs
- Success/error states

### Table
**Features:**
- Sortable columns (click header)
- Selectable rows (checkboxes)
- Pagination (numbered pages, prev/next)
- Filtering (column search, advanced filters)
- Responsive (horizontal scroll on mobile)
- Empty state (when no data)

### Navigation Menu
**Types:**
- Horizontal topbar (navigation items in row)
- Vertical sidebar (collapsible menu tree)
- Breadcrumb (hierarchical path)

**States:**
- Active (current page, blue highlight)
- Hover (light background)
- Disabled (grayed out)

### Breadcrumb
**Purpose:** Show navigation hierarchy

**Format:** `Home > Products > Electronics > Laptop`

**Features:**
- Clickable items (navigate back)
- Last item non-clickable (current page)
- Responsive (collapse on mobile)

---

## Utility Components

### Container
**Purpose:** Max-width wrapper, consistent horizontal centering

**Sizes:**
- Fluid (100%, no max-width)
- Small (600px)
- Medium (900px) — default
- Large (1200px)
- Extra Large (1400px)

### Grid
**Purpose:** Responsive multi-column layout

**Columns:**
- Auto-responsive (1-4 columns based on breakpoint)
- 12-column system (Tailwind-style)
- Gap control (8px, 16px, 24px, 32px)

### Flex
**Purpose:** Flexible row/column layout

**Properties:**
- Direction (row, column)
- Alignment (flex-start, center, flex-end, space-between, space-around)
- Justify (flex-start, center, flex-end)
- Gap (8px to 48px)
- Wrap (wrap, nowrap)

### Spacer
**Purpose:** Vertical/horizontal spacing between elements

**Values:** 4px, 8px, 16px, 24px, 32px, 48px, 64px

---

## Data Display

### List
**Types:**
- Ordered (numbered)
- Unordered (bullets)
- Description list (term + definition)

### Table
- Sticky header (on scroll)
- Alternating row colors (zebra striping)
- Dense / Normal / Spacious density

### Statistics Card
- Large number (headline)
- Label/description
- Trend indicator (up/down arrow + percentage)
- Background color optional

---

## Forms & Validation

### Required Field Indicator
Display: Red asterisk (*) after label

### Validation States
- Pristine (no interaction yet)
- Touched (user interacted, may have error)
- Dirty (user changed value)
- Invalid (error state, red border + message)
- Valid (green checkmark)

### Error Messages
- Inline below field (red text, 12px)
- Form-level error summary (top of form, alert box)

### Helper Text
- Below label or input (gray text, 12px)
- Example format, constraints, guidance

---

## Accessibility Checklist

- **Semantic HTML:** Use `<button>`, `<input>`, `<label>` tags
- **ARIA Labels:** `aria-label`, `aria-labelledby` for icons
- **Focus Indicators:** Visible ring on focused elements
- **Color Not Alone:** Use icons/text + color for status
- **Keyboard Navigation:** Tab, Space, Enter, Escape, Arrow keys
- **Screen Reader Support:** Announce buttons, form labels, status changes
- **Touch Targets:** Minimum 44px × 44px
- **Contrast:** 4.5:1 (normal text), 3:1 (UI components)
