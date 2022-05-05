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

let text0 = Label(text: "Hello!", color: Color.red)
group.append(text0)

let font = PCFFont(path: "/SD:/NotoSansSC-Regular-16.pcf")
let text1 = Label(y: 40, text: "你好", font: font)
group.append(text1)

let text2 = Label(x: 100, y: 100, scale: 2, text: "10", color: Color.lime)
group.append(text2)

display.update(group)

for i in (0...9).reversed() {
    sleep(ms: 1000)
    text2.updateText(String(i))
    display.update(group)
}

while true {
    sleep(ms: 1000)
}
