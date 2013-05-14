# Bee

Bee is a collection of lightweight interaction elements for modern web applications. It is built on top of [Dart's Web UI](http://www.dartlang.org/articles/web-ui/) package. It contains frequently used components like Buttons, Popovers, Overlays, Input Fields and more.

##Install

Bee is a pub package. To install it you can add it to pubspec.yaml. For example:

```yaml
name: my-app
dependencies:
  bee: any
```

##Components

###Button

```html
<div is="x-button-submit" value="Primary"></div>
```

####Show Password

```html
<div is="x-input-password" placeholder="Enter your Password"></div>
```

####Loading Indicator

```html
<span is="x-ellipsis"></span>
```

####Popover

```html
<div is="x-popover">
    <span class="launch-area">Launch Popover</span>
    <div class="body">This is a Popover</div>
</div>
```

####Overlay

```html
<span on-click="query('.q-example-overlay').xtag.show()" on-touch-start="query('.q-example-overlay').xtag.show()">Launch Overlay</span>
<x-overlay width="600px" class="q-example-overlay">
    <h2>Bee</h2>
    <p>Bee is a collection of lightweight interaction elements for modern web applications. It is built on top of Dart's Web UI package. It contains frequently used components like Buttons, Popovers, Overlays, Input Fields and more.</p>
</x-overlay>
```

**Coming Soon …**

* Tests, Tests, Tests
* Component: Tooltip
* Component: Date Picker
* Component: Gravatar
