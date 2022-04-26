# ``MadDisplay``

Display graphics on screens and organize all elements for display.

## Overview

The MadDisplay library provides an easy way for graphical display. Four core concepts: 
``Bitmap``, ``Palette``, ``Tile``, and ``Group`` are used to organize all graphics.

* A **Bitmap** stores indexed colors for all its pixel. 
* The true colors are stored in order in a **Palette**. The indexes of colors are 
used for the pixel of a bitmap.
* A Bitmap and a Palette get a **Tile**. So a Tile is a colored graphic and serves 
as a minimum unit for display. 
* A **Group** is like container - different tiles or even other groups are added 
in order. 

![](layers.png)

After all layers are organized, the group is ready for display. The class 
``MadDisplay/MadDisplay`` is used for display on screens.

Here is an example:

```swift
// A screen used for display, ST7789 for example.
let screen = ...
// Create a display.
let display = MadDisplay(screen: screen)

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

display.updata(group)

```

Besides, it provides some additional functionalities to draw basic elements: 
shapes, texts and image. They are also based on the concepts above. 

## Topics

### Learn
- <doc:Basic>

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

- ``Label``
- ``PCFFont``
- ``RobotRegular16``
- ``ASCII8``


### Image

- ``BMP``


### Color

- ``Color``
- ``ColorSpace``
- ``ColorConverter``
