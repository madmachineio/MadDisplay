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

let group = Group()

let line1 = Line(x0: 0, y0: 119, x1: 239, y1: 119, color: Color.magenta)
let line2 = Line(x0: 119, y0: 0, x1: 119, y1: 239, color: Color.magenta)
group.append(line1)
group.append(line2)

let rect = Rect(x: 20, y: 20, width: 60, height: 60, fill: Color.orange)
group.append(rect)

let circle = Circle(x: 175, y: 50, radius: 35, fill: Color.cyan)
group.append(circle)

let roundRect = RoundRect(x: 0, y: 130, width: 60, height: 30, radius: 5, fill: Color.yellow)
group.append(roundRect)

let triangle = Triangle(x0: 130, y0: 200, x1: 160, y1: 140, x2: 200, y2: 180, fill: Color.lime, outline: Color.yellow)
group.append(triangle)
