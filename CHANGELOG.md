## 0.0.3

* Added **dotted border** (`dotted`, `dotWidth`, `dotHeight`, `dotSpacing`).
  * Circular dots when `dotWidth == dotHeight` (or `dotHeight` is null).
  * Rectangular dots aligned to the border path when `dotWidth != dotHeight`.
  * Works on all three shapes: rectangle, circle, stadium.
* Added **per-corner radius shortcuts**: `radiusTL`, `radiusTR`, `radiusBL`, `radiusBR`.
  * Any unspecified corner falls back to `radius`.
  * Priority: `borderRadius` > individual corners > `radius`.
* Dashed border now tested and confirmed working on all shapes (rectangle with any radius, circle, stadium).
* Added comprehensive README with full API reference, code examples for every feature.
* 39 widget tests — full coverage for every shape × border-style combination.

## 0.0.2

* Upgraded to a feature-rich, production-ready widget.
* Added support for shapes: circle, stadium, rectangle.
* Added dashed border support with customizable `dashLength` / `gapLength`.
* Added animation support via `animated: true`.
* Added loading state with built-in shimmer overlay.
* Added Material ripple effect option.
* Added precise padding/margin shorthands (`pt`, `pb`, `pl`, `pr`, `mt`, `mb`, `ml`, `mr`).
* Added size constraints (`minW`, `maxW`, `minH`, `maxH`).
* Added `disabled` and `safeArea` properties.
* Added gradient, image background, box shadow, blend mode.
* Added `Widget.quick()` extension.

## 0.0.1

* Initial release.
