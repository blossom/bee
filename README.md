# Bee

Bee is a collection of lightweight interaction elements for modern web applications. It is built on top of [Dart's Web UI](http://www.dartlang.org/articles/web-ui/) package. It contains frequently used components like Buttons, Popovers, Overlays, Input Fields and more.

##Install

Bee is a [Pub Package](http://pub.dartlang.org/packages/bee). To install Bee you can add it to your pubspec.yaml.

```yaml
name: my-app
dependencies:
  bee: any
```

To use a component you need to import it via a link tag.

```html
<link rel="import" href="package:bee/components/button.html">
<link rel="import" href="package:bee/components/secret.html">
<link rel="import" href="package:bee/components/loading.html">
<link rel="import" href="package:bee/components/popover.html">
<link rel="import" href="package:bee/components/overlay.html">
<link rel="import" href="package:bee/components/button.html">
```

##Components

###Button

```html
<b-button>Primary</b-button>
```

###Show Password

```html
<b-secret placeholder="Enter your Password"></b-secret>
```

###Loading Indicator

```html
<b-loading></b-loading>
```

###Popover

```html
<b-popover>
    <span class="launch-area">Launch Popover</span>
    <div class="body">This is a Popover</div>
</b-popover>
```

###Overlay

```html
<span on-click="query('.q-example-overlay').xtag.show()" on-touch-start="query('.q-example-overlay').xtag.show()">Launch Overlay</span>
<b-overlay width="600px" class="q-example-overlay">
    <h2>Bee</h2>
    <p>Bee is a collection of lightweight interaction elements for modern web applications. It is built on top of Dart's Web UI package. It contains frequently used components like Buttons, Popovers, Overlays, Input Fields and more.</p>
</b-overlay>
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

##Coming Soon …

This is just the initial release and we'll add a bunch of additional components, examples, documentation and polish going forward :)

* Tests, Tests, Tests
* Component: Tooltip
* Component: Date Picker
