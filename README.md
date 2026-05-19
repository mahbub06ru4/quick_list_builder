# quick_list_builder

A supercharged, production-ready `Container` replacement for Flutter.
One widget — shapes, gradients, dashed/dotted borders, per-corner radius, animations, loading shimmer, ripple, and concise padding/margin shorthands.

---

## Features

- **3 shapes** — rectangle, circle, stadium (capsule)
- **Per-corner radius shortcuts** — `radiusTL`, `radiusTR`, `radiusBL`, `radiusBR`
- **Dashed border** — custom dash length & gap, works on all shapes
- **Dotted border** — circular or rectangular dots, custom size & spacing, works on all shapes
- **Gradient & image backgrounds**
- **Box shadows** — quick toggle or full custom list
- **Tap interactions** — `onTap`, `onLongPress`, Material ripple
- **Animated** — `AnimatedContainer` transitions with one flag
- **Loading shimmer** — pulsing overlay, blocks interaction automatically
- **Disabled state** — 50 % opacity, no tap
- **Padding/Margin shorthands** — `p`, `px`, `py`, `pt`, `pb`, `pl`, `pr` and same for margin
- **Size constraints** — `w`, `h`, `minW`, `minH`, `maxW`, `maxH`
- **Safe area** support
- **Widget extension** — `.quick()` wraps any widget instantly
- Zero extra dependencies

---

## Installation

```yaml
dependencies:
  quick_list_builder: ^0.0.3
```

```dart
import 'package:quick_list_builder/quick_list_builder.dart';
```

---

## Quick start

```dart
QuickContainer(
  p: 16,
  radius: 12,
  color: Colors.white,
  shadow: true,
  onTap: () {},
  child: Text('Hello, QuickContainer!'),
)
```

---

## Shapes

### Rectangle (default)

```dart
QuickContainer(
  p: 16,
  radius: 12,          // uniform corner radius
  color: Colors.white,
  child: Text('Rectangle'),
)
```

### Circle

```dart
QuickContainer(
  w: 80,
  h: 80,
  shape: QuickContainerShape.circle,
  color: Colors.deepPurple,
  child: Icon(Icons.star, color: Colors.white),
)
```

### Stadium (capsule)

```dart
QuickContainer(
  px: 24,
  py: 12,
  shape: QuickContainerShape.stadium,
  color: Colors.teal,
  child: Text('Capsule Button', style: TextStyle(color: Colors.white)),
)
```

---

## Per-corner radius

Use `radiusTL`, `radiusTR`, `radiusBL`, `radiusBR` instead of building a full `BorderRadius` object.
Any corner not specified falls back to `radius` (default `0`).

```dart
// Top-left + bottom-right only
QuickContainer(
  p: 16,
  radiusTL: 24,
  radiusBR: 24,
  color: Colors.orange.shade50,
  child: Text('TL + BR rounded'),
)

// Top-right + bottom-left only
QuickContainer(
  p: 16,
  radiusTR: 28,
  radiusBL: 28,
  color: Colors.purple.shade50,
  child: Text('TR + BL rounded'),
)

// All four corners — different values
QuickContainer(
  p: 16,
  radiusTL: 4,
  radiusTR: 20,
  radiusBL: 20,
  radiusBR: 4,
  color: Colors.teal.shade50,
  child: Text('All corners independent'),
)

// Base radius + one override
QuickContainer(
  p: 16,
  radius: 16,    // applies to all corners
  radiusTL: 0,   // override: sharp top-left only
  color: Colors.blue.shade50,
  child: Text('radius:16 · radiusTL:0'),
)
```

**Priority order** (highest wins):
1. `borderRadius` — full `BorderRadius` object
2. `radiusTL / radiusTR / radiusBL / radiusBR` — per-corner shortcuts
3. `radius` — uniform fallback

---

## Padding & Margin shorthands

| Param | Applies to |
|---|---|
| `p` | all four sides |
| `px` | left + right |
| `py` | top + bottom |
| `pt` | top only |
| `pb` | bottom only |
| `pl` | left only |
| `pr` | right only |

Same set with `m` prefix for margin: `m`, `mx`, `my`, `mt`, `mb`, `ml`, `mr`.

**Priority** (specific > axis > all):
`pl` overrides `px` overrides `p` for the left side.

```dart
QuickContainer(
  p: 8,      // fallback for all
  px: 20,    // overrides horizontal
  pt: 12,    // overrides top only
  child: Text('Custom padding'),
)
```

---

## Background

### Solid color

```dart
QuickContainer(
  p: 16,
  color: Colors.indigo,
  child: Text('Solid color'),
)
```

### Gradient

```dart
QuickContainer(
  p: 20,
  py: 28,
  radius: 16,
  gradient: LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
  ),
  child: Text('Gradient', style: TextStyle(color: Colors.white)),
)
```

### Image

```dart
QuickContainer(
  h: 200,
  radius: 16,
  clipBehavior: Clip.antiAlias,
  image: DecorationImage(
    image: NetworkImage('https://example.com/photo.jpg'),
    fit: BoxFit.cover,
  ),
)
```

---

## Border

### Solid border

```dart
QuickContainer(
  p: 16,
  radius: 12,
  color: Colors.white,
  borderColor: Colors.indigo,
  borderWidth: 2,
  child: Text('Solid border'),
)
```

Or pass a full `BoxBorder`:

```dart
QuickContainer(
  p: 16,
  border: Border.all(color: Colors.red, width: 1.5),
  child: Text('Custom border'),
)
```

---

## Dashed border

Works on **all three shapes** and all radius variants.

```dart
// Rectangle — no radius
QuickContainer(
  p: 16,
  dashed: true,
  borderColor: Colors.indigo,
  borderWidth: 2,
  child: Text('Dashed · plain rect'),
)

// Rectangle — uniform radius
QuickContainer(
  p: 16,
  radius: 16,
  dashed: true,
  borderColor: Colors.indigo,
  borderWidth: 2,
  child: Text('Dashed · radius:16'),
)

// Rectangle — per-corner radius
QuickContainer(
  p: 16,
  radiusTL: 24,
  radiusBR: 24,
  dashed: true,
  borderColor: Colors.indigo,
  borderWidth: 2,
  child: Text('Dashed · TL+BR rounded'),
)

// Rectangle — BorderRadius.only
QuickContainer(
  p: 16,
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(28),
    bottomRight: Radius.circular(28),
  ),
  dashed: true,
  borderColor: Colors.indigo,
  borderWidth: 2,
  child: Text('Dashed · BorderRadius.only'),
)

// Circle shape
QuickContainer(
  w: 90,
  h: 90,
  shape: QuickContainerShape.circle,
  dashed: true,
  borderColor: Colors.indigo,
  borderWidth: 2,
  child: Icon(Icons.favorite, color: Colors.indigo),
)

// Stadium shape
QuickContainer(
  px: 32,
  py: 14,
  shape: QuickContainerShape.stadium,
  dashed: true,
  borderColor: Colors.indigo,
  borderWidth: 2,
  child: Text('Dashed · stadium'),
)

// Custom dash & gap lengths
QuickContainer(
  p: 16,
  radius: 12,
  dashed: true,
  borderColor: Colors.deepPurple,
  borderWidth: 2,
  dashLength: 12,   // length of each dash segment
  gapLength: 8,     // gap between segments
  child: Text('dashLength:12  gapLength:8'),
)
```

---

## Dotted border

Works on **all three shapes** and all radius variants.
Two dot styles: **circular** (default) and **rectangular**.

### Circular dots

```dart
// Rectangle
QuickContainer(
  p: 16,
  radius: 16,
  dotted: true,
  borderColor: Colors.red,
  dotWidth: 4,       // dot diameter
  dotSpacing: 6,     // gap between dots
  child: Text('Circular dots'),
)

// Circle shape
QuickContainer(
  w: 90,
  h: 90,
  shape: QuickContainerShape.circle,
  dotted: true,
  borderColor: Colors.amber,
  dotWidth: 5,
  dotSpacing: 7,
)

// Stadium shape
QuickContainer(
  px: 32,
  py: 14,
  shape: QuickContainerShape.stadium,
  dotted: true,
  borderColor: Colors.deepOrange,
  dotWidth: 4,
  dotSpacing: 5,
  child: Text('Dotted stadium'),
)
```

### Rectangular dots

Set `dotHeight` different from `dotWidth` — each dot becomes a filled rectangle aligned to the border path.

```dart
// Rectangle
QuickContainer(
  p: 16,
  radius: 16,
  dotted: true,
  borderColor: Colors.green,
  dotWidth: 8,      // rectangle width
  dotHeight: 3,     // rectangle height  (≠ dotWidth → rectangular)
  dotSpacing: 5,
  child: Text('Rect dots 8×3'),
)

// Circle shape
QuickContainer(
  w: 90,
  h: 90,
  shape: QuickContainerShape.circle,
  dotted: true,
  borderColor: Colors.green,
  dotWidth: 8,
  dotHeight: 3,
  dotSpacing: 6,
)

// Stadium shape
QuickContainer(
  px: 32,
  py: 14,
  shape: QuickContainerShape.stadium,
  dotted: true,
  borderColor: Colors.teal,
  dotWidth: 6,
  dotHeight: 2,
  dotSpacing: 5,
  child: Text('Stadium · rect dots'),
)
```

### Combined with per-corner radius

```dart
QuickContainer(
  p: 16,
  radiusTL: 24,
  radiusBR: 24,
  dotted: true,
  borderColor: Colors.deepOrange,
  dotWidth: 3,
  dotSpacing: 2,   // very dense
  child: Text('Dense dots + asymmetric corners'),
)
```

> **Note:** `dashed` takes priority over `dotted` when both are `true`.

---

## Shadow

```dart
// Default soft shadow
QuickContainer(
  p: 16,
  radius: 12,
  color: Colors.white,
  shadow: true,
  child: Text('Default shadow'),
)

// Custom shadows
QuickContainer(
  p: 16,
  radius: 12,
  color: Colors.white,
  shadows: [
    BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
    BoxShadow(color: Colors.blue.withValues(alpha: 0.1), blurRadius: 12),
  ],
  child: Text('Custom shadows'),
)
```

---

## Tap interactions

```dart
// Simple tap
QuickContainer(
  p: 16,
  radius: 12,
  color: Colors.white,
  onTap: () => print('tapped'),
  child: Text('Tap me'),
)

// Long press
QuickContainer(
  p: 16,
  radius: 12,
  color: Colors.white,
  onTap: () {},
  onLongPress: () => print('long pressed'),
  child: Text('Long press me'),
)

// Material ripple effect
QuickContainer(
  p: 16,
  radius: 12,
  color: Colors.white,
  onTap: () {},
  ripple: true,            // Material InkWell ripple
  child: Text('Ripple tap'),
)
```

---

## Animation

Set `animated: true` — any change to `color`, `radius`, `w`, `h`, or `decoration` animates automatically.

```dart
QuickContainer(
  p: 20,
  radius: isExpanded ? 32 : 8,
  color: isExpanded ? Colors.deepPurple : Colors.white,
  animated: true,
  duration: Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  child: Text('Tap to morph'),
)
```

---

## Loading state

Shows a pulsing shimmer overlay and blocks all interaction automatically.

```dart
QuickContainer(
  p: 20,
  radius: 12,
  color: Colors.white,
  loading: isLoading,
  onTap: () {},        // blocked while loading
  child: Text('Content'),
)
```

---

## Disabled state

Reduces opacity to 50 % and blocks all interaction.

```dart
QuickContainer(
  p: 16,
  radius: 12,
  color: Colors.teal,
  disabled: true,
  onTap: () {},   // blocked
  child: Text('Disabled', style: TextStyle(color: Colors.white)),
)
```

---

## Size & constraints

```dart
QuickContainer(
  w: 200,         // explicit width
  h: 80,          // explicit height
  minW: 100,      // minimum width
  maxW: 300,      // maximum width
  minH: 48,
  maxH: 200,
  p: 16,
  radius: 12,
  color: Colors.white,
  child: Text('Constrained'),
)
```

---

## Safe area

```dart
QuickContainer(
  safeArea: true,
  color: Colors.white,
  child: Text('Respects device notch/home bar'),
)
```

---

## Widget extension `.quick()`

Wrap any existing widget without nesting a separate `QuickContainer`:

```dart
// Basic
Text('Hello')
  .quick(p: 16, radius: 12, color: Colors.white, shadow: true)

// With gradient
Icon(Icons.star, color: Colors.white)
  .quick(
    w: 56, h: 56,
    shape: QuickContainerShape.circle,
    gradient: RadialGradient(colors: [Colors.amber, Colors.orange]),
  )

// With dotted border + per-corner radius
Text('Dotted label')
  .quick(
    p: 12,
    radiusTL: 16,
    radiusBR: 16,
    dotted: true,
    borderColor: Colors.deepOrange,
    dotWidth: 3,
  )
```

---

## Full API reference

### Size

| Param | Type | Description |
|---|---|---|
| `w` | `double?` | Explicit width |
| `h` | `double?` | Explicit height |
| `minW` | `double?` | Minimum width constraint |
| `minH` | `double?` | Minimum height constraint |
| `maxW` | `double?` | Maximum width constraint |
| `maxH` | `double?` | Maximum height constraint |

### Padding

| Param | Covers |
|---|---|
| `p` | all sides (fallback) |
| `px` | left + right |
| `py` | top + bottom |
| `pt` | top |
| `pb` | bottom |
| `pl` | left |
| `pr` | right |

### Margin

Same as padding but prefixed with `m`: `m`, `mx`, `my`, `mt`, `mb`, `ml`, `mr`.

### Background

| Param | Type | Description |
|---|---|---|
| `color` | `Color?` | Solid background. Ignored when `gradient` is set |
| `gradient` | `Gradient?` | Gradient background. Overrides `color` |
| `image` | `DecorationImage?` | Background image |
| `blendMode` | `BlendMode?` | Blend mode for the background |

### Shape

| Param | Type | Description |
|---|---|---|
| `shape` | `QuickContainerShape` | `rectangle` (default), `circle`, `stadium` |
| `radius` | `double?` | Uniform corner radius. Fallback for per-corner shortcuts |
| `radiusTL` | `double?` | Top-left corner radius |
| `radiusTR` | `double?` | Top-right corner radius |
| `radiusBL` | `double?` | Bottom-left corner radius |
| `radiusBR` | `double?` | Bottom-right corner radius |
| `borderRadius` | `BorderRadius?` | Full explicit `BorderRadius` — highest priority |

### Border

| Param | Type | Default | Description |
|---|---|---|---|
| `border` | `BoxBorder?` | — | Full custom border (overrides `borderColor`/`borderWidth`) |
| `borderColor` | `Color?` | — | Border color |
| `borderWidth` | `double?` | `1.5` | Border / stroke width |
| `dashed` | `bool` | `false` | Dashed border (takes priority over `dotted`) |
| `dashLength` | `double` | `8.0` | Dash segment length |
| `gapLength` | `double` | `5.0` | Gap between dashes |
| `dotted` | `bool` | `false` | Dotted border |
| `dotWidth` | `double` | `3.0` | Dot width / diameter |
| `dotHeight` | `double?` | — | Dot height. When `null` or `== dotWidth` → circular dot; otherwise → rectangular dot |
| `dotSpacing` | `double` | `5.0` | Gap between dots |

### Shadow

| Param | Type | Description |
|---|---|---|
| `shadow` | `bool` | Enable default soft shadow |
| `shadows` | `List<BoxShadow>?` | Custom shadow list. Overrides `shadow` |

### Interaction

| Param | Type | Description |
|---|---|---|
| `onTap` | `VoidCallback?` | Tap handler |
| `onLongPress` | `VoidCallback?` | Long-press handler |
| `ripple` | `bool` | Use Material `InkWell` ripple instead of `GestureDetector` |
| `disabled` | `bool` | 50 % opacity, all interaction blocked |

### Animation

| Param | Type | Default | Description |
|---|---|---|---|
| `animated` | `bool` | `false` | Use `AnimatedContainer` for smooth transitions |
| `duration` | `Duration` | `300 ms` | Animation duration |
| `curve` | `Curve` | `easeInOut` | Animation curve |

### Misc

| Param | Type | Default | Description |
|---|---|---|---|
| `alignment` | `AlignmentGeometry?` | — | Child alignment within the container |
| `clipBehavior` | `Clip` | `antiAlias` | Clipping mode for rounded/shaped containers |
| `safeArea` | `bool` | `false` | Wrap with `SafeArea` |
| `loading` | `bool` | `false` | Show pulsing shimmer overlay, block interaction |
| `child` | `Widget?` | — | Child widget |

---

## Scroll compatibility

`QuickContainer` is safe to use inside any scrollable widget:

```dart
ListView.builder(
  itemBuilder: (context, i) => QuickContainer(
    m: 8,
    p: 16,
    radius: 12,
    color: Colors.white,
    shadow: true,
    child: Text('Item $i'),
  ),
)
```

---

## License

MIT
