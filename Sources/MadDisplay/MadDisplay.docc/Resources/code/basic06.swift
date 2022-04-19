import SwiftIO
import MadBoard
import ST7789
import MadDisplay

let spi = SPI(Id.SPI0, speed: 30_000_000)
let cs = DigitalOut(Id.D9)
let dc = DigitalOut(Id.D10)
let rst = DigitalOut(Id.D14)
let bl = DigitalOut(Id.D2)

let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

let display = MadDisplay(screen: screen)

let palette = Palette()
palette.append(Color.white)
palette.append(Color.yellow)

// Create a bitmap by setting its size and color count.
let bitmap = Bitmap(width: 240, height: 240, bitCount: 1)

// Set the pixels (50,50) to (150,150) with fourth color in the palette.
for x in 60...180 {
    for y in 60...180 {
        bitmap.setPixel(x:x, y:y, 1)
    }
}

// Create a tile with the given bitmap and palette and set its location.
let tile = Tile(bitmap: bitmap, palette: palette)

// Create a group and append the tile into it.
let group = Group()
group.append(tile)

// Display the group on the screen.
display.update(group)

while true {
    sleep(ms: 1000)
}