# Design System Specification: The Precision Curator
 
## 1. Overview & Creative North Star
The core philosophy of this design system is **"The Precision Curator."** 
 
In the world of high-stakes ticketing, users fluctuate between the adrenaline of a purchase and the need for absolute clarity in logistics. We move beyond the "generic utility" look by adopting an editorial aesthetic that mirrors a high-end gallery. We achieve this through **Intentional Asymmetry** and **Air as a Divider**. 
 
Instead of trapping information in rigid boxes, we allow content to breathe. We utilize high-contrast typography scales and overlapping "glass" layers to create a sense of depth and sophistication. This isn't just a platform; it’s an authoritative guide to live experiences.
 
---
 
## 2. Colors & Tonal Architecture
Our palette is anchored by the authoritative `primary` blue (`#003ec7`), balanced against a sophisticated range of neutral surfaces.
 
### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders for sectioning content. 
Boundaries must be defined solely through background color shifts. For example, a `surface-container-low` (`#f3f2ff`) sidebar sitting against a `surface` (`#fbf8ff`) main content area. This creates a seamless, modern interface that feels "carved" rather than "assembled."
 
### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. Use the `surface-container` tiers to define importance:
*   **Background:** `surface` (`#fbf8ff`)
*   **Primary Content Area:** `surface-container-low` (`#f3f2ff`)
*   **Interactive Cards/Modules:** `surface-container-lowest` (`#ffffff`) for maximum "pop" and perceived elevation.
*   **Navigation/Overlays:** `surface-container-high` (`#e7e7f5`) or `highest` (`#e1e1ef`) for recessed or deeply nested elements.
 
### The "Glass & Gradient" Rule
To elevate the brand from "functional" to "premium":
*   **Glassmorphism:** For floating elements like event filters or seat selection summaries, use semi-transparent `surface` colors with a 12px–20px backdrop blur.
*   **Signature Textures:** Main CTAs and Hero sections should utilize a subtle linear gradient from `primary` (`#003ec7`) to `primary_container` (`#0052ff`) at a 135-degree angle. This adds "soul" and depth that a flat hex code cannot provide.
 
---
 
## 3. Typography: The Editorial Voice
We use a dual-font strategy to balance character with readability.
 
*   **Display & Headlines (Manrope):** This is our "Editorial" voice. Manrope’s geometric nature provides a modern, professional edge. Use `display-lg` (3.5rem) for marquee events to create a bold, "poster-like" impact. 
*   **Body & Labels (Inter):** Inter is our "Functional" voice. It handles complex data—like ticket tiers and seat numbers—with surgical precision.
 
**Hierarchy Strategy:** Always maintain a high contrast between display sizes and body copy. A massive headline paired with a small, tracked-out `label-md` creates a premium, intentional look.
 
---
 
## 4. Elevation & Depth
Hierarchy is achieved through **Tonal Layering** rather than traditional drop shadows.
 
*   **The Layering Principle:** Stacking tiers is preferred. A `surface-container-lowest` card placed on a `surface-container-low` background creates a natural lift.
*   **Ambient Shadows:** When an element must float (e.g., a "Buy" button on mobile), use a shadow with a 24px-32px blur at 6% opacity, tinted with the `on_surface` color (`#191b25`). Avoid pure black shadows; they look "dirty."
*   **The Ghost Border Fallback:** If accessibility requires a container boundary, use a "Ghost Border." This is the `outline_variant` (`#c3c5d9`) at 15% opacity. It should be barely perceptible, serving as a suggestion of a boundary rather than a hard wall.
 
---
 
## 5. Component Guidelines
 
### Buttons (The "Jewel" Components)
*   **Primary:** Uses the Signature Gradient (Primary to Primary Container). Roundedness: `md` (`0.375rem`).
*   **Secondary:** No background. Use `primary` text with a `surface-variant` background on hover.
*   **Tertiary:** For low-priority actions (e.g., "View Map"). Use `on_surface_variant` text with no container.
 
### Cards & Event Lists
*   **Constraint:** Zero dividers. Use vertical whitespace (referencing a strict 8px/16px/24px/32px scale) to separate events.
*   **Styling:** Event cards should use the `surface-container-lowest` background. On hover, the card should transition to a slightly higher tonal lift or show a subtle `primary` accent.
 
### Inputs & Search
*   **Design:** Forgo the "box" look. Use a `surface-container-low` fill with a `sm` (`0.125rem`) bottom-only accent in `primary` when focused.
*   **Clarity:** Use `label-sm` for persistent floating labels to ensure the user never loses context in complex seating forms.
 
### Seating Plans (The Complexity Hero)
*   **Interaction:** Use `glassmorphism` for the zoom/pan controls.
*   **States:** Available seats should use `primary_fixed_dim`. Selected seats use the vibrant `primary`. Occupied seats should blend into the background using `surface_variant`.
 
### Chips
*   **Action Chips:** Used for dates or genres. Use `full` roundedness.
*   **Unselected:** `surface-container-high` background.
*   **Selected:** `primary` background with `on_primary` text.
 
---
 
## 6. Do’s and Don’ts
 
### Do:
*   **Do** use asymmetrical layouts for event details (e.g., text aligned left, imagery bleeding off the right edge).
*   **Do** use `tertiary` (`#952200`) sparingly for urgent notifications or "Low Ticket" warnings. It should feel like a premium "accent," not a loud error.
*   **Do** allow for generous "white space" (negative space). In this system, space equals luxury.
 
### Don’t:
*   **Don't** use 1px solid borders to separate list items. Use the Spacing Scale.
*   **Don't** use the `DEFAULT` or `lg` roundedness for everything. Mix `md` for buttons and `xl` for large image containers to create visual rhythm.
*   **Don't** use pure black (`#000000`). Always use the `on_surface` (`#191b25`) for text to maintain a soft, professional contrast.
*   **Don't** use standard "Material" shadows. If it looks like a default template, it's wrong. Think "Atmospheric Light."