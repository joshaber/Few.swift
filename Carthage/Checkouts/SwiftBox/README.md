# SwiftBox

A Swift wrapper around Facebook's [implementation](https://github.com/facebook/css-layout) of CSS's flexbox.

## Example

```swift
let parent = Node(size: CGSize(width: 300, height: 300),
                  childAlignment: .Center,
                  direction: .Row,
                  children: [
    Node(flex: 75,
         margin: Edges(left: 10, right: 10),
         size: CGSize(width: 0, height: 100)), 
    Node(flex: 15,
         margin: Edges(right: 10),
         size: CGSize(width: 0, height: 50)),
    Node(flex: 10,
         margin: Edges(right: 10),
         size: CGSize(width: 0, height: 180)),
])

let layout = parent.layout()
println(layout)

//{origin={0.0, 0.0}, size={300.0, 300.0}}
//	{origin={10.0, 100.0}, size={195.0, 100.0}}
//	{origin={215.0, 125.0}, size={39.0, 50.0}}
//	{origin={264.0, 60.0}, size={26.0, 180.0}}
```

Alternatively, you could apply the layout to a view hierarchy (after ensuring Auto Layout is off):

```swift
layout.apply(someView)
```

See [SwiftBoxDemo](SwiftBoxDemo/SwiftBoxDemo) for a demo.
