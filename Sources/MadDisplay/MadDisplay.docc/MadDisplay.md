# ``MadDisplay``

Display graphics on tiny screens and organize each element for display.

## Overview

The MadDisplay library aims to display shapes, text, and images on tiny screens in an easy way. It provides four core concepts: ``Bitmap``, ``Palette``, ``Tile``, and ``Group`` to organize all graphics. 

* A Bitmap stores indexed colors for all its pixel. 
* The true colors are stored in order in a Palette. The index of colors matches the pixel of a bitmap.
* A Bitmap and a Palette can get a Tile. So a Tile is a color graphic and serves as a minimum unit for display. 
* A Group is like container - different tiles or even other groups can be added to it in order. 

Here is a simple example:

```swift
// Create a palette with two colors.
let palette = Palette()
palette.append(Color.black)
palette.append(Color.white)

// Create a 200* 200 bitmap. It can have two possible colors.
let bitmap = Bitmap(width: 240, height: 240, bitCount: 1)

// Set the pixels on the middle to the second color in the palette, that is, white.
for x in 60...180 {
    for y in 60...180 {
        bitmap.setPixel(x:x, y:y, 1)
    }
}

// Create a tile with the given bitmap and palette.
let tile = Tile(bitmap: bitmap, palette: palette)

// Create a group and append the tile into it.
let group = Group()
group.append(tile)
```

After all layers are organized, the group is ready for display. The class ``MadDisplay`` is used.

```swift
// Create an screen instance.
let screen = ...

// Initialize the display using the screen instance.
let display = MadDisplay(screen: screen)

// Display the group.
display.update(group)
```

Other classes provide additional functionalities (shapes, texts and image) based on the concepts above. 

## Topics

### Core

- ``Bitmap``
- ``Palette``
- ``Tile``
- ``Group``

### Display

- ``MadDisplay/MadDisplay``

### Shapes

- ``Line``
- ``Rect``
- ``RoundRect``
- ``Circle``
- ``Triangle``
- ``Polygon``

### Text

- ``Lable``
- ``PCFFont``


### Image

- ``BMP``
