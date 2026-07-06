---
version: alpha
name: AgriLink-Vietnam-design
description: A clean, trustworthy agricultural marketplace anchored on Forest Green (#2D6A4F) as the single brand voltage. Inspired by Airbnb's generous whitespace and photography-first layout, adapted for Vietnamese farmers and agri-buyers. Warm earth tones (amber harvest, clay orange) complement the green, evoking organic farming and land. Pill-shaped search, softly rounded cards, and generous whitespace signal approachability for rural users unfamiliar with digital platforms. Typography stays modest — Inter at 500–600 weight — because product photography and map visuals carry hierarchy, not typographic muscle.

colors:
  primary: "#2D6A4F"
  primary-active: "#1B4332"
  primary-disabled: "#B7DEC9"
  primary-light: "#52B788"
  primary-ultra-light: "#D8F3DC"
  accent: "#F4A261"
  accent-active: "#E76F51"
  harvest: "#FFB703"
  ink: "#1A1A1A"
  body: "#3D3D3D"
  muted: "#6B7280"
  muted-soft: "#9CA3AF"
  hairline: "#E5E7EB"
  hairline-soft: "#F3F4F6"
  border-strong: "#D1D5DB"
  canvas: "#FFFFFF"
  surface-soft: "#F9FBF9"
  surface-card: "#FFFFFF"
  surface-green: "#F0FFF4"
  surface-strong: "#E9F5EE"
  on-primary: "#FFFFFF"
  on-dark: "#FFFFFF"
  success: "#2D6A4F"
  warning: "#FFB703"
  error: "#DC2626"
  error-hover: "#B91C1C"
  info: "#2563EB"
  legal-link: "#2563EB"
  star-rating: "#F59E0B"
  scrim: "#000000"
  badge-organic: "#2D6A4F"
  badge-vietgap: "#1D4ED8"
  badge-traditional: "#92400E"

typography:
  display-xl:
    fontFamily: "'Inter', -apple-system, system-ui, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif"
    fontSize: 32px
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: -0.5px
  display-lg:
    fontFamily: "'Inter', sans-serif"
    fontSize: 24px
    fontWeight: 600
    lineHeight: 1.33
    letterSpacing: -0.3px
  display-md:
    fontFamily: "'Inter', sans-serif"
    fontSize: 20px
    fontWeight: 600
    lineHeight: 1.4
    letterSpacing: -0.2px
  display-sm:
    fontFamily: "'Inter', sans-serif"
    fontSize: 18px
    fontWeight: 600
    lineHeight: 1.44
    letterSpacing: -0.1px
  title-md:
    fontFamily: "'Inter', sans-serif"
    fontSize: 16px
    fontWeight: 600
    lineHeight: 1.5
    letterSpacing: 0
  title-sm:
    fontFamily: "'Inter', sans-serif"
    fontSize: 14px
    fontWeight: 600
    lineHeight: 1.43
    letterSpacing: 0
  body-md:
    fontFamily: "'Inter', sans-serif"
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.6
    letterSpacing: 0
  body-sm:
    fontFamily: "'Inter', sans-serif"
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.57
    letterSpacing: 0
  caption:
    fontFamily: "'Inter', sans-serif"
    fontSize: 13px
    fontWeight: 500
    lineHeight: 1.38
    letterSpacing: 0
  caption-sm:
    fontFamily: "'Inter', sans-serif"
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.33
    letterSpacing: 0
  badge:
    fontFamily: "'Inter', sans-serif"
    fontSize: 11px
    fontWeight: 600
    lineHeight: 1.18
    letterSpacing: 0.2px
  micro-label:
    fontFamily: "'Inter', sans-serif"
    fontSize: 12px
    fontWeight: 700
    lineHeight: 1.33
    letterSpacing: 0.1px
  uppercase-tag:
    fontFamily: "'Inter', sans-serif"
    fontSize: 10px
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: 0.8px
    textTransform: uppercase
  button-md:
    fontFamily: "'Inter', sans-serif"
    fontSize: 16px
    fontWeight: 600
    lineHeight: 1.25
    letterSpacing: 0
  button-sm:
    fontFamily: "'Inter', sans-serif"
    fontSize: 14px
    fontWeight: 500
    lineHeight: 1.29
    letterSpacing: 0
  link:
    fontFamily: "'Inter', sans-serif"
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.43
    letterSpacing: 0
  nav-link:
    fontFamily: "'Inter', sans-serif"
    fontSize: 15px
    fontWeight: 600
    lineHeight: 1.33
    letterSpacing: 0
  stat-display:
    fontFamily: "'Inter', sans-serif"
    fontSize: 48px
    fontWeight: 700
    lineHeight: 1.0
    letterSpacing: -1px

rounded:
  none: 0px
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  xxl: 32px
  full: 9999px

spacing:
  xxs: 2px
  xs: 4px
  sm: 8px
  md: 12px
  base: 16px
  lg: 24px
  xl: 32px
  xxl: 48px
  section: 80px

components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.button-md}"
    rounded: "{rounded.sm}"
    padding: 12px 24px
    height: 48px
  button-primary-active:
    backgroundColor: "{colors.primary-active}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.sm}"
  button-primary-disabled:
    backgroundColor: "{colors.primary-disabled}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.sm}"
  button-secondary:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.primary}"
    border: "1.5px solid {colors.primary}"
    typography: "{typography.button-md}"
    rounded: "{rounded.sm}"
    padding: 11px 23px
    height: 48px
  button-accent:
    backgroundColor: "{colors.accent}"
    textColor: "{colors.on-primary}"
    typography: "{typography.button-md}"
    rounded: "{rounded.sm}"
    padding: 12px 24px
    height: 48px
  button-tertiary-text:
    backgroundColor: transparent
    textColor: "{colors.primary}"
    typography: "{typography.button-md}"
  button-pill-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.button-sm}"
    rounded: "{rounded.full}"
    padding: 8px 20px
  button-pill-outline:
    backgroundColor: transparent
    textColor: "{colors.primary}"
    border: "1.5px solid {colors.primary}"
    typography: "{typography.button-sm}"
    rounded: "{rounded.full}"
    padding: 7px 19px
  search-orb:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.full}"
    height: 48px
    width: 48px
  icon-button-circle:
    backgroundColor: "{colors.surface-strong}"
    textColor: "{colors.ink}"
    rounded: "{rounded.full}"
    height: 36px
  top-nav:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.nav-link}"
    height: 72px
    borderBottom: "1px solid {colors.hairline}"
  sidebar-nav:
    backgroundColor: "{colors.surface-soft}"
    textColor: "{colors.ink}"
    typography: "{typography.nav-link}"
    width: 260px
    borderRight: "1px solid {colors.hairline}"
  sidebar-item-active:
    backgroundColor: "{colors.primary-ultra-light}"
    textColor: "{colors.primary}"
    typography: "{typography.nav-link}"
    rounded: "{rounded.sm}"
  sidebar-item-inactive:
    backgroundColor: transparent
    textColor: "{colors.muted}"
    typography: "{typography.nav-link}"
  search-bar-pill:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.body-sm}"
    rounded: "{rounded.full}"
    padding: 12px 24px
    height: 56px
    border: "1px solid {colors.hairline}"
  search-field-segment:
    backgroundColor: transparent
    textColor: "{colors.ink}"
    typography: "{typography.caption}"
    padding: 8px 20px
  category-strip:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.muted}"
    typography: "{typography.button-sm}"
    borderBottom: "1px solid {colors.hairline}"
  category-tab-active:
    backgroundColor: transparent
    textColor: "{colors.primary}"
    typography: "{typography.button-sm}"
    borderBottom: "2px solid {colors.primary}"
  product-card:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.body-sm}"
    rounded: "{rounded.md}"
    border: "1px solid {colors.hairline}"
  product-card-photo:
    rounded: "{rounded.md}"
    aspectRatio: "4/3"
  bulk-listing-card:
    backgroundColor: "{colors.surface-green}"
    textColor: "{colors.ink}"
    typography: "{typography.body-sm}"
    rounded: "{rounded.md}"
    border: "1px solid {colors.primary-light}"
  map-marker-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.full}"
  map-marker-cluster:
    backgroundColor: "{colors.accent}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.full}"
  stat-card:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    border: "1px solid {colors.hairline}"
    padding: 24px
  trust-badge:
    backgroundColor: "{colors.primary-ultra-light}"
    textColor: "{colors.primary}"
    typography: "{typography.badge}"
    rounded: "{rounded.full}"
    padding: 4px 12px
  farming-type-badge-organic:
    backgroundColor: "#DCFCE7"
    textColor: "{colors.badge-organic}"
    typography: "{typography.badge}"
    rounded: "{rounded.xs}"
    padding: 2px 8px
  farming-type-badge-vietgap:
    backgroundColor: "#DBEAFE"
    textColor: "{colors.badge-vietgap}"
    typography: "{typography.badge}"
    rounded: "{rounded.xs}"
    padding: 2px 8px
  farming-type-badge-traditional:
    backgroundColor: "#FEF3C7"
    textColor: "{colors.badge-traditional}"
    typography: "{typography.badge}"
    rounded: "{rounded.xs}"
    padding: 2px 8px
  order-status-pending:
    backgroundColor: "#FEF9C3"
    textColor: "#854D0E"
    typography: "{typography.badge}"
    rounded: "{rounded.full}"
    padding: 4px 10px
  order-status-confirmed:
    backgroundColor: "#D1FAE5"
    textColor: "#065F46"
    typography: "{typography.badge}"
    rounded: "{rounded.full}"
    padding: 4px 10px
  order-status-shipping:
    backgroundColor: "#DBEAFE"
    textColor: "#1E40AF"
    typography: "{typography.badge}"
    rounded: "{rounded.full}"
    padding: 4px 10px
  order-status-done:
    backgroundColor: "{colors.primary-ultra-light}"
    textColor: "{colors.primary}"
    typography: "{typography.badge}"
    rounded: "{rounded.full}"
    padding: 4px 10px
  qr-trace-card:
    backgroundColor: "{colors.surface-green}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    border: "2px solid {colors.primary-light}"
    padding: 24px
  reservation-card:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.body-md}"
    rounded: "{rounded.md}"
    border: "1px solid {colors.hairline}"
    padding: 24px
  price-display:
    typography: "{typography.stat-display}"
    textColor: "{colors.primary}"
  price-chart-line:
    color: "{colors.primary}"
    width: 2px
  price-alert-badge:
    backgroundColor: "#FFF7ED"
    textColor: "{colors.accent-active}"
    typography: "{typography.badge}"
    rounded: "{rounded.full}"
    padding: 4px 10px
  text-input:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.body-md}"
    rounded: "{rounded.sm}"
    border: "1px solid {colors.border-strong}"
    padding: 12px 14px
    height: 48px
  text-input-focus:
    border: "2px solid {colors.primary}"
  select-input:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.body-md}"
    rounded: "{rounded.sm}"
    border: "1px solid {colors.border-strong}"
    height: 48px
  file-upload:
    backgroundColor: "{colors.surface-soft}"
    textColor: "{colors.muted}"
    border: "2px dashed {colors.hairline}"
    rounded: "{rounded.md}"
    padding: 32px
  date-picker-day:
    backgroundColor: transparent
    textColor: "{colors.ink}"
    typography: "{typography.body-sm}"
    rounded: "{rounded.full}"
    size: 40px
  date-picker-day-selected:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.full}"
  footer-light:
    backgroundColor: "{colors.surface-soft}"
    textColor: "{colors.ink}"
    typography: "{typography.body-sm}"
    borderTop: "1px solid {colors.hairline}"
    padding: 48px 80px
  legal-band:
    backgroundColor: "{colors.surface-soft}"
    textColor: "{colors.muted}"
    typography: "{typography.caption-sm}"
    borderTop: "1px solid {colors.hairline}"
  hero-section:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    backgroundOverlay: "linear-gradient(135deg, #1B4332 0%, #2D6A4F 50%, #52B788 100%)"
  hero-wave:
    fill: "{colors.canvas}"
  notification-dot:
    backgroundColor: "#EF4444"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.full}"
    size: 8px
  avatar:
    backgroundColor: "{colors.primary-light}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.full}"
  data-table:
    headerBg: "{colors.surface-soft}"
    headerText: "{colors.muted}"
    rowBorder: "{colors.hairline-soft}"
    hoverBg: "{colors.surface-green}"
  tab-active:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.sm}"
    padding: 8px 20px
  tab-inactive:
    backgroundColor: transparent
    textColor: "{colors.muted}"
    rounded: "{rounded.sm}"
    padding: 8px 20px
  empty-state:
    illustration: "leaf/plant icon in {colors.primary-ultra-light}"
    textColor: "{colors.muted}"
---

## Overview

AgriLink Vietnam adapts Airbnb's generous, photography-first marketplace aesthetic for Vietnamese agriculture. The base canvas is **pure white** (`{colors.canvas}`) with deep near-black ink (`{colors.ink}` — #1A1A1A) for copy, and a single voltage of **Forest Green** (`{colors.primary}` — #2D6A4F) carrying every primary CTA, the search orb, active nav states, and trust badges. Warm **amber harvest** (`{colors.harvest}` — #FFB703) and **clay orange** (`{colors.accent}` — #F4A261) serve as secondary accents for price alerts, CTAs targeting buyers, and harvest-season highlights.

Type runs **Inter** — the closest open-source equivalent to Airbnb Cereal. Display weights sit at 600–700, body at 400. Modest weight is intentional: farm photography, map visuals, and product images carry hierarchy, not typographic muscle.

Shape language mirrors Airbnb: **soft everywhere**. Buttons at 8px radius, product cards at 12px, search bar fully pill-shaped, dashboards use 12–16px rounded panels. No hard corners except data tables and grid lines.

**Key Characteristics:**
- Single brand color: `{colors.primary}` (#2D6A4F — Forest Green) on every primary CTA, active nav, trust badges, and the search orb.
- Warm accent: `{colors.accent}` (#F4A261 — Clay Orange) for buyer-facing CTAs, price highlights, and escrow states.
- Harvest gold: `{colors.harvest}` (#FFB703) for star ratings, alerts, and yield/price stat highlights.
- 7-role RBAC means each dashboard has distinct sidebar nav — same design language, different navigation structure.
- Farming-type badges (Organic, VietGAP, Traditional) are color-coded and pill-shaped for instant scan.
- QR traceability card uses a Forest Green border + mint background to signal trust and verification.
- Offline-first consideration: skeleton states for all data-heavy components; no layout shift on slow connections.
- Vietnamese-first: all UI copy in Vietnamese; placeholder text assumes rural users with basic smartphone literacy.

## Colors

### Brand & Accent
- **Forest Green** (`{colors.primary}` — #2D6A4F): Single brand voltage. All primary CTAs, search orb, active sidebar items, active tab indicators, trust badges, and the logo wordmark.
- **Forest Green Active** (`{colors.primary-active}` — #1B4332): Press/hover state — deeper forest. Same role as Airbnb's Rausch Active.
- **Forest Green Disabled** (`{colors.primary-disabled}` — #B7DEC9): Pale mint for disabled primary buttons.
- **Leaf Green** (`{colors.primary-light}` — #52B788): Secondary green for hover highlights, chip backgrounds, and avatar fallbacks.
- **Mint** (`{colors.primary-ultra-light}` — #D8F3DC): Lightest green tint — sidebar active item bg, organic badge bg, QR card accent surface.
- **Clay Orange** (`{colors.accent}` — #F4A261): Buyer-facing CTAs ("Đặt mua ngay"), escrow state highlights, price band accents.
- **Clay Orange Active** (`{colors.accent-active}` — #E76F51): Press state for accent buttons.
- **Harvest Gold** (`{colors.harvest}` — #FFB703): Star ratings, price-alert badges, yield stat highlights — the "ripe harvest" signal.

### Surface
- **Canvas** (`{colors.canvas}` — #FFFFFF): Default page floor.
- **Surface Soft** (`{colors.surface-soft}` — #F9FBF9): Sidebar background, footer background, disabled inputs — a very faint green-white.
- **Surface Green** (`{colors.surface-green}` — #F0FFF4): Dashboard stat panels, QR traceability card backgrounds, HTX bulk listing cards.
- **Surface Strong** (`{colors.surface-strong}` — #E9F5EE): Icon-button backgrounds, breadcrumb back-arrow.

### Text
- **Ink** (`{colors.ink}` — #1A1A1A): All headlines, primary body text. Near-black, not pure black.
- **Body** (`{colors.body}` — #3D3D3D): Long-form running text in product descriptions, traceability records.
- **Muted** (`{colors.muted}` — #6B7280): Sub-labels, inactive nav items, table column headers.
- **Muted Soft** (`{colors.muted-soft}` — #9CA3AF): Placeholder text, disabled labels.
- **Star Rating** (`{colors.star-rating}` — #F59E0B): AgriLink uses amber stars (unlike Airbnb's ink stars) — agricultural trust cues align with warm harvest colors.

### Semantic
- **Success** = primary green. No separate success token — trust in agri context is expressed through the brand color.
- **Warning** (`{colors.warning}` — #FFB703): Price alerts, pending verification states.
- **Error** (`{colors.error}` — #DC2626): Form validation, dispute alerts.
- **Info** (`{colors.info}` — #2563EB): Informational banners, legal links.

## Typography

**Font:** Inter (Google Fonts, open-source). No licensing cost — important for a student startup.

Fallbacks: `-apple-system, system-ui, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif`.

Scale is slightly larger than Airbnb at display sizes (32px vs 28px h1) because AgriLink pages must work on small-screen Android phones common in rural Vietnam — generous size aids legibility on low-res screens.

| Token | Size | Weight | Use |
|---|---|---|---|
| `display-xl` | 32px / 700 | Hero headlines ("Kết nối nông dân Việt Nam") |
| `display-lg` | 24px / 600 | Page titles, product detail h1 |
| `display-md` | 20px / 600 | Section heads in dashboard |
| `display-sm` | 18px / 600 | Card titles, modal heads |
| `title-md` | 16px / 600 | Product names in cards |
| `title-sm` | 14px / 600 | Table column heads, stat labels |
| `body-md` | 16px / 400 | Running copy, form labels |
| `body-sm` | 14px / 400 | Card meta, dates, prices |
| `caption` | 13px / 500 | Search segment labels, tooltips |
| `badge` | 11px / 600 | Farming type badges, order status pills |
| `stat-display` | 48px / 700 | Dashboard KPI numbers (trust signal) |

## Layout

### Spacing
Base unit 4px. Tokens from `xxs` (2px) to `section` (80px). Section padding at 80px (slightly larger than Airbnb's 64px) for better breathing room on content-dense agri data pages.

### Grid
- **Landing / Marketplace:** Max 1280px centered, 4-column product grid at desktop → 2-col tablet → 1-col mobile.
- **Dashboard layout:** Fixed 260px sidebar + main content area. Sidebar collapses to icon-only at tablet, hamburger sheet at mobile.
- **Product detail:** 2-col — product info left (60%) + order/contact card right (36%), sticky on scroll.
- **Map page:** Full-bleed map (100vh) with a collapsible filter panel on the left (320px) and a results list drawer on the right.

### Sidebar (Dashboard)
Each role has a distinct sidebar with role-appropriate nav items. Same visual treatment: `{component.sidebar-nav}` with `{component.sidebar-item-active}` for current route and `{component.sidebar-item-inactive}` for others. Role badge (e.g. "Nông dân", "HTX") shown below avatar in sidebar header.

## Elevation

One shadow tier (identical strategy to Airbnb):
- **Flat:** All editorial sections, hero, footer.
- **Card hover:** `box-shadow: 0 0 0 1px rgba(0,0,0,0.02), 0 2px 6px rgba(0,0,0,0.05), 0 4px 12px rgba(0,0,0,0.08)` — product cards on hover, search bar at rest, dropdown menus.
- **Modal scrim:** `{colors.scrim}` at 40% opacity (slightly lighter than Airbnb's 50% — suits the lighter, more approachable brand feel).

## Pages & Roles

### Public Pages
1. **Landing Page** — Hero (forest green gradient), category strip, featured products, stats, map preview, footer
2. **Marketplace** — Search pill, category filter strip, product grid, map toggle
3. **Product Detail** — Photo gallery, traceability QR section, seller profile, order card
4. **QR Trace Public** — Standalone page consumers scan QR to see — no auth required
5. **Login / Register / OTP** — Auth flow

### Role Dashboards (post-login)
6. **Farmer Dashboard** — Stats, my products, orders, farm profile, join cooperative
7. **HTX Dashboard** — Member list, bulk listings, harvest schedules, revenue report
8. **Trader / Enterprise Dashboard** — Source search, purchase orders, supplier ratings
9. **Supplier Dashboard** — Product listings, ad campaigns, analytics
10. **State Agency Dashboard** — Approval queues (HTX, certs), compliance reports, dispute management
11. **Logistics Dashboard** — Order pickup list, delivery status updates, route map
12. **Admin Panel** — User management, product moderation, system config, ad approval

### Shared Pages
13. **Map / GIS** — 34-province map with filter panel
14. **Market Price** — Price charts, AI forecast, alert settings
15. **Profile & Settings** — Personal info, documents, notifications, security

## Responsive

| Breakpoint | Width | Changes |
|---|---|---|
| Mobile | < 640px | Stack all; sidebar → hamburger; product grid 1-col; order card → sticky bottom bar |
| Tablet | 640–1024px | Sidebar icon-only (collapsed); product grid 2-col; search bar single row |
| Desktop | 1024–1440px | Full sidebar 260px; 4-col grid; full search pill; 2-col detail |
| Wide | > 1440px | Cap at 1440px, gutters absorb extra |

## AgriLink-specific Patterns

### Farming Type Badges
Three badge variants always shown on product cards: Organic (green), VietGAP (blue), Traditional (amber). Never omitted — trust signal for buyers.

### Trust Score
Displayed as a 5-star amber row + numeric score + "đã bán X lô" meta line on seller cards. Analog of Airbnb's rating display — the single loudest trust signal on the platform.

### Escrow Flow Visual
Order status progresses through colored pills: Chờ xác nhận (yellow) → Đã xác nhận (green) → Đang giao (blue) → Hoàn thành (forest green) → Tranh chấp (red). Always visible in order tracking views.

### QR Traceability Card
Forest green border, mint background, QR code left + data points right. "Quét để xem" CTA in primary button. On public scan: full-width card stack showing farm → harvest → transport → quality test chain.

### Price Chart
Line chart using primary green (#2D6A4F) for farmer-received price, amber (#F4A261) for retail price. The gap between the two lines is the "khoảng cách giá" — visualized with a shaded area fill.

### Offline-first Skeleton
All data-heavy components (product grids, price charts, order lists) render skeleton placeholders in `{colors.surface-strong}` with a shimmer animation. No blank white screens on slow rural connections.
