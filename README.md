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
<x-button value="Primary"></x-button>
```

###Show Password

```html
<x-secret placeholder="Enter your Password"></x-secret>
```

###Loading Indicator

```html
<x-loading></x-loading>
```

###Popover

```html
<x-popover>
    <span class="launch-area">Launch Popover</span>
    <div class="body">This is a Popover</div>
</x-popover>
```

###Overlay

```html
<span on-click="query('.q-example-overlay').xtag.show()" on-touch-start="query('.q-example-overlay').xtag.show()">Launch Overlay</span>
<x-overlay width="600px" class="q-example-overlay">
    <h2>Bee</h2>
    <p>Bee is a collection of lightweight interaction elements for modern web applications. It is built on top of Dart's Web UI package. It contains frequently used components like Buttons, Popovers, Overlays, Input Fields and more.</p>
</x-overlay>
```

## Nexted Example

A button which opens an overlay on click. The overlay contains a popover.
Note: Pressing 'ESC' closes popovers as well as overlays but only closes the youngest (last shown) component.

```html
<x-button type="button" on-click="query('.q-example-nested').xtag.show()" on-touch-start="query('.q-example-nested').xtag.show()">Launch Overlay</x-button>
<x-overlay width="600px" class="q-example-nested">
    <h2>Bee</h2>
    <p>Bee is a collection of lightweight interaction elements for modern web applications. It is built on top of Dart's Web UI package. It contains frequently used components like Buttons, Popovers, Overlays, Input Fields and more.</p>
    <x-popover>
        <x-button type="button" class="launch-area">Launch Popover inside Overlay</x-button>
        <div class="body">This is a Popover</div>
    </x-popover>
    <p>Bee is a collection of lightweight interaction elements for modern web applications. It is built on top of Dart's Web UI package. It contains frequently used components like Buttons, Popovers, Overlays, Input Fields and more.</p>
</x-overlay>
```

##Coming Soon …

This is just the initial release and we'll add a bunch of additional components, examples, documentation and polish going forward :)

* Tests, Tests, Tests
* Component: Tooltip
* Component: Date Picker
