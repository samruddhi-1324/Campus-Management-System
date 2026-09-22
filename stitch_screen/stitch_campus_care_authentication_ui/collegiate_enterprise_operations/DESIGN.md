---
name: Collegiate Enterprise & Operations
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#47464f'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#787680'
  outline-variant: '#c8c5d0'
  surface-tint: '#5b598c'
  primary: '#070235'
  on-primary: '#ffffff'
  primary-container: '#1e1b4b'
  on-primary-container: '#8683ba'
  inverse-primary: '#c4c1fb'
  secondary: '#0051d5'
  on-secondary: '#ffffff'
  secondary-container: '#316bf3'
  on-secondary-container: '#fefcff'
  tertiary: '#000f07'
  on-tertiary: '#ffffff'
  tertiary-container: '#002819'
  on-tertiary-container: '#179c6e'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e3dfff'
  primary-fixed-dim: '#c4c1fb'
  on-primary-fixed: '#181445'
  on-primary-fixed-variant: '#444173'
  secondary-fixed: '#dbe1ff'
  secondary-fixed-dim: '#b4c5ff'
  on-secondary-fixed: '#00174b'
  on-secondary-fixed-variant: '#003ea8'
  tertiary-fixed: '#85f8c4'
  tertiary-fixed-dim: '#68dba9'
  on-tertiary-fixed: '#002114'
  on-tertiary-fixed-variant: '#005137'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Newsreader
    fontSize: 3.5rem
    fontWeight: '400'
    lineHeight: 4rem
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Newsreader
    fontSize: 2.25rem
    fontWeight: '400'
    lineHeight: 2.75rem
    letterSpacing: -0.01em
  headline-xl:
    fontFamily: Newsreader
    fontSize: 2.5rem
    fontWeight: '400'
    lineHeight: 3rem
    letterSpacing: -0.015em
  headline-xl-mobile:
    fontFamily: Newsreader
    fontSize: 1.75rem
    fontWeight: '400'
    lineHeight: 2.25rem
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Newsreader
    fontSize: 2rem
    fontWeight: '500'
    lineHeight: 2.5rem
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Newsreader
    fontSize: 1.375rem
    fontWeight: '500'
    lineHeight: 1.75rem
  title-md:
    fontFamily: Manrope
    fontSize: 1.125rem
    fontWeight: '600'
    lineHeight: 1.625rem
  body-lg:
    fontFamily: Manrope
    fontSize: 1rem
    fontWeight: '400'
    lineHeight: 1.6rem
  body-md:
    fontFamily: Manrope
    fontSize: 0.875rem
    fontWeight: '400'
    lineHeight: 1.45rem
  label-lg:
    fontFamily: Manrope
    fontSize: 0.875rem
    fontWeight: '600'
    lineHeight: 1.25rem
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Manrope
    fontSize: 0.75rem
    fontWeight: '700'
    lineHeight: 1rem
    letterSpacing: 0.04em
  code-sm:
    fontFamily: Manrope
    fontSize: 0.8125rem
    fontWeight: '500'
    lineHeight: 1.2rem
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1.5rem
  gutter-mobile: 1rem
  margin: 2rem
  margin-mobile: 1rem
  margin-desktop: 3rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style

The design system projects academic prestige, administrative competence, and modern institutional velocity. It serves university administrators, campus facility managers, academic deans, and students through an interface that balances classical scholarly authority with precision operational agility. 

The aesthetic marries an elite editorial sensibility with high-performance enterprise ergonomics. Deep midnight indigos anchor the cognitive environment, communicating longevity, structural security, and seriousness. The typography creates an intentional tension: authoritative, intellectual editorial serif headlines command major thematic nodes, while hyper-legible, calibrated sans-serif text delivers high-density operational data, work orders, and analytics without visual fatigue. The interface is crisp, airy, and meticulously balanced, evoking the calm focus of an archival research library outfitted with real-time operational instrumentation.

## Colors

The palette establishes an intellectual, high-contrast operational hierarchy across daylight canvas surfaces.

- **Primary (`#1E1B4B`):** Deep royal indigo serves as the foundational structural tone. It establishes authority in mastheads, active enterprise navigation, prominent typography, and primary interactive buttons.
- **Secondary (`#2563EB`):** Vibrant electric campus blue brings operational vitality, serving as interactive focus rings, active tab indicators, links, and system-level actions that demand immediate engagement.
- **Tertiary (`#059669`):** Institutional emerald represents facility health, scheduled resolution, verified audits, and pristine operational status.
- **Warning (`#F59E0B`):** Warm burnished amber handles time-sensitive notices, pending maintenance dispatches, and urgent resource alerts without panic styling.
- **Canvas & Neutrals (`#F8FAFC`, `#FFFFFF`, `#E2E8F0`):** Crisp, multi-tiered slate neutrals preserve expansive white space, isolate dense tabular data, and prevent visual weight from encroaching on reading rhythms.

### Application Rules
- Use primary `#1E1B4B` for display titles, card headers, and critical decision CTAs.
- Secondary `#2563EB` is strictly reserved for interactive affordances and progression states; never use it as a passive background wash.
- Alert and resolution colors (`#059669`, `#F59E0B`) must always be paired with high-contrast slate text or enclosed in tinted badge containers to guarantee AA/AAA compliance on slate backgrounds.

## Typography

The typographic architecture establishes an institutional dialogue between classical academic editorial craft and precise modern execution.

- **Headlines (Newsreader):** Used exclusively for high-level section titles, dashboard overviews, academic milestones, and facility reports. Newsreader lends historic gravitas and unhurried intellectual clarity. Its optical weights soften clinical operational tooling.
- **Body and Labels (Manrope):** Handles operational metrics, tabular data, form controls, microcopy, and body copy. Manrope provides geometric precision with human open counters, ensuring high legibility in dense campus telemetry dashboards.

### Styling Standards
- Set all `display-lg` and `headline-xl` titles with soft tracking (`-0.02em` to `-0.015em`) to consolidate ink density.
- Set operational labels (`label-sm`) in uppercase with positive tracking (`+0.04em`) when designating state indicators, work-order IDs, or room classifications.
- Maintain an editorial vertical rhythm: paragraph content must never exceed 68 characters per line to preserve reading ease during incident investigations.

## Layout & Spacing

The layout is grounded in a 12-column fluid grid system on desktop, reflowing to an 8-column layout on tablet, and a 4-column stack on mobile viewports. Layouts prioritize strict horizontal alignment with expansive vertical breathing room.

- **Breakpoints:** Mobile (0–639px), Tablet (640–1023px), Desktop (1024px–1440px), and Large Console (1441px+).
- **Margins & Gutters:** Desktop containers utilize a fixed outer margin of `3rem` with `1.5rem` gutters. Tablet adjusts to `2rem` margins, and mobile collapses to `1rem` margins and gutters.
- **Spatial Rhythm:** Elements adhere to a base-4 grid system. Internal component padding follows `space-sm` (8px) for compact table cells, `space-md` (16px) for standard cards, and `space-xl` (40px) for editorial section breaks.
- **Reflow Rules:** Analytical widgets span 4 columns on desktop, collapse to 4 columns (half-width) on tablet, and take the full 4 columns on mobile. Structural action drawers preserve fixed maximum widths of 480px on desktop and stretch to 100vw on mobile.

## Elevation & Depth

Visual hierarchy uses subtle atmospheric translucency, calibrated surface tiers, and tinted ambient shadows to keep views clean and low-glare.

- **Surface Tiers:** The root canvas is `#F8FAFC`. Floating modules and primary content cards sit on pure white (`#FFFFFF`). Higher-order panels (dialogs, priority slide-overs) employ subtle micro-translucency (`rgba(255, 255, 255, 0.88)` with a 16px backdrop blur).
- **Micro-Borders:** Crisp, low-contrast structural boundaries are required. Cards and containers use a 1px solid border colored with `#E2E8F0` or `#CBD5E1`.
- **Shadow Signature:** Shadows are never pure gray. They are tinted with midnight indigo (`#1E1B4B`) to complement the brand's primary structure:
  - *Level 1 (Card / Resting):* `0 1px 3px 0 rgba(30, 27, 75, 0.04), 0 1px 2px -1px rgba(30, 27, 75, 0.02)`
  - *Level 2 (Hover / Active Element):* `0 4px 6px -1px rgba(30, 27, 75, 0.06), 0 2px 4px -2px rgba(30, 27, 75, 0.04)`
  - *Level 3 (Floating Menus / Flyouts):* `0 10px 15px -3px rgba(30, 27, 75, 0.08), 0 4px 6px -4px rgba(30, 27, 75, 0.03)`
  - *Level 4 (Modal Windows / Critical Alerts):* `0 20px 25px -5px rgba(30, 27, 75, 0.12), 0 8px 10px -6px rgba(30, 27, 75, 0.04)`

## Shapes

The design system employs a geometric radius scale governed by `roundedness: 2`. This creates tailored, structural corners that remain architectural and dignified without feeling toy-like.

- **Base Radius (`0.5rem` / 8px):** Standard interactive controls, form inputs, buttons, status chips, and dropdown lists.
- **Large Radius (`1rem` / 16px):** Primary content modules, facility telemetry cards, table wrappers, and interactive panels.
- **Extra Large Radius (`1.5rem` / 24px):** Major dashboard hero sections, modal window containers, and high-level analytical group views.
- **Pill (`9999px`):** Reserved exclusively for numeric notifications, urgency status pills, and user avatar silhouettes.

## Components

### Buttons
- **Primary:** Background `#1E1B4B`, text `#FFFFFF`, border 1px solid transparent, corner radius `0.5rem`. On hover: `#2E2875` with subtle elevation. Focus: outline 2px solid `#2563EB` with a 2px offset.
- **Secondary:** Background `#FFFFFF`, text `#1E1B4B`, border 1px solid `#E2E8F0`, corner radius `0.5rem`. On hover: `#F8FAFC` with border `#CBD5E1`.
- **Operational / Action:** Background `#2563EB`, text `#FFFFFF`. Used for active tasks (e.g., "Dispatch Crew", "Confirm Booking").

### Cards & Panels
- **Standard Card:** Pure `#FFFFFF` fill, 1px solid `#E2E8F0` boundary, radius `1rem`, Level 1 indigo-tinted shadow. Headers within cards feature Newsreader medium titles (`headline-sm`) accompanied by a bottom border separator in `#F1F5F9`.
- **Interactive Metric Card:** Incorporates a 3px accent line along the top border (using `#2563EB` for active pipelines, `#059669` for cleared states, or `#F59E0B` for attention items).

### Chips & Badges
- Constructed with a pill radius (`9999px`), `space-xs` vertical padding, and `space-sm` horizontal padding with `label-sm` bold tracking.
- **Operational Health (Resolved/Safe):** Background `#ECFDF5`, text `#065F46`, border 1px solid `#A7F3D0`.
- **Urgency/Maintenance:** Background `#FFFBEB`, text `#92400E`, border 1px solid `#FDE68A`.
- **Institutional Category:** Background `#EEF2FF`, text `#1E1B4B`, border 1px solid `#C7D2FE`.

### Input Fields & Controls
- **Form Inputs:** 40px height, background `#FFFFFF`, border 1px solid `#CBD5E1`, text `#0F172A`, font `body-md`, radius `0.5rem`. Focus: border `#2563EB`, outer glow box-shadow `0 0 0 3px rgba(37, 99, 235, 0.15)`.
- **Checkboxes & Radios:** 18px dimensions, border 1.5px solid `#94A3B8`. When selected: fill `#1E1B4B`, checkmark/dot white `#FFFFFF`.

### Facility Status Lists
- Zebra or bordered row divisions using `#F1F5F9`. Rows feature a gentle hover transition to `#F8FAFC` with a left highlight indicator (2px solid `#2563EB`) on selected or focused work orders.