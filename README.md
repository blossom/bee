# Bee

Bee is a collection of lightweight interaction elements for modern web applications. It is built on top of [Dart's Web UI](http://www.dartlang.org/articles/web-ui/) package. It contains frequently used components like Buttons, Popovers, Overlays, Input Fields and more.

## Install

Bee is a [Pub Package](http://pub.dartlang.org/packages/bee). To install Bee you can add it to your pubspec.yaml.

```yaml
name: my-app
dependencies:
  bee: any
```

## Getting started

To use a component you need to import it via a link tag.

```html
<link rel="import" href="package:bee/components/button.html">
```

Add the custom Bee element inside the same file where you imported the component.

```html
<b-button>Primary</b-button>
```

You might want to check out the [example](https://github.com/blossom/bee/tree/master/example).

## Components

### Button

```html
<link rel="import" href="package:bee/components/button.html">
```

```html
<b-button>Primary</b-button>
```

### Show Password

```html
<link rel="import" href="package:bee/components/secret.html">
```

```html
<b-secret placeholder="Enter your Password"></b-secret>
```

### Loading Indicator

```html
<link rel="import" href="package:bee/components/loading.html">
```

```html
<b-loading></b-loading>
```

### Popover

```html
<link rel="import" href="package:bee/components/popover.html">
```

```html
<b-popover>
    <span class="launch-area">Launch Popover</span>
    <div class="body">This is a Popover</div>
</b-popover>
```

### Overlay

```html
<link rel="import" href="package:bee/components/overlay.html">
```

```html
<span on-click="query('.q-example-overlay').xtag.show()" on-touch-start="query('.q-example-overlay').xtag.show()">Launch Overlay</span>
<b-overlay width="600px" class="q-example-overlay">
    <h2>Bee</h2>
    <p>Bee is a collection of lightweight interaction elements for modern web applications. It is built on top of Dart's Web UI package. It contains frequently used components like Buttons, Popovers, Overlays, Input Fields and more.</p>
</b-overlay>
```

### Tooltip

```html
<link rel="import" href="package:bee/components/tooltip.html">
```

```html
<b-tooltip></b-tooltip>
```

### Textarea (growable)

```html
<link rel="import" href="package:bee/components/tooltip.html">
```

```html
<b-textarea value="Edit me!"></b-textarea>
```

## Nexted Example

A button which opens an overlay on click. The overlay contains a popover.
Note: Pressing 'ESC' closes popovers as well as overlays but only closes the youngest (last shown) component.

```html
<b-button type="button" on-click="query('.q-example-nested').xtag.show()" on-touch-start="query('.q-example-nested').xtag.show()">Launch Overlay</b-button>
<b-overlay width="600px" class="q-example-nested">
    <h2>Bee</h2>
    <p>Bee is a collection of lightweight interaction elements for modern web applications. It is built on top of Dart's Web UI package. It contains frequently used components like Buttons, Popovers, Overlays, Input Fields and more.</p>
    <b-popover>
        <b-button type="button" class="launch-area">Launch Popover inside Overlay</b-button>
        <div class="body">This is a Popover</div>
    </b-popover>
    <p>Bee is a collection of lightweight interaction elements for modern web applications. It is built on top of Dart's Web UI package. It contains frequently used components like Buttons, Popovers, Overlays, Input Fields and more.</p>
</b-overlay>
```

## Coming Soon

This is just the initial release and we'll add a bunch of additional components, examples, documentation and polish going forward :)

* Convert to Polymer.dart
* Tests, Tests, Tests
* Component: Date Picker
