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

let bitmap = Bitmap(width: 240, height: 240, bitCount: 1)

for x in 60...180 {
    for y in 60...180 {
        bitmap.setPixel(x:x, y:y, 1)
    }
}

let tile = Tile(bitmap: bitmap, palette: palette)

