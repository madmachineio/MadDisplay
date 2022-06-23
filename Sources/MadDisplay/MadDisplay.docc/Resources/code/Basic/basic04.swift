import SwiftIO
import MadBoard
import ST7789
import MadDisplay

let spi = SPI(Id.SPI0, speed: 30_000_000)
let cs = DigitalOut(Id.D0)
let dc = DigitalOut(Id.D1)
let rst = DigitalOut(Id.D2)
let bl = DigitalOut(Id.D3)

let screen = ST7789(spi: spi, cs: cs, dc: dc, rst: rst, bl: bl, rotation: .angle90)

let display = MadDisplay(screen: screen)

let palette = Palette()
