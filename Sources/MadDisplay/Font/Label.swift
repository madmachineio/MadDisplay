public final class Label: Group {

    let localGroup: Group
    var font: Font
    var text: String?
    var paddingTop: Int = 0
    var paddingBottom: Int = 0
    var paddingLeft: Int = 0
    var paddingRight: Int = 0
    var lineSpacing: Double = 1.25
    var backgroundTight: Bool = false
    var color: UInt32
    var backgroundColor: UInt32? = nil
    var addedBackgroundTilegrid = false
    
    var scaleValue: Int

    var height: Int
    var maxCharAscent: Int
    var maxCharDescent: Int

    let palette = Palette(count: 2)
    let backgroundPalette = Palette(count: 1)

    var anchorPoint: Point?
    var anchorPosition: Point?
    var boundingBox: (Int, Int, Int, Int) = (0, 0, 0, 0)


    public init(x: Int = 0, y: Int = 0, scale: Int = 1, text: String? = nil, color: UInt32 = Color.white, font: Font = RobotRegular16()) {
        localGroup = Group(scale: scale)

        scaleValue = scale
        self.font = font
        self.color = color

        palette[0] = 0
        palette.makeTransparent(0)
        palette[1] = color

        height = font.fontHeight
        maxCharAscent = font.maxCharAscent
        maxCharDescent = font.maxCharDescent

        super.init()
        self.x = x
        self.y = y


        self.append(localGroup)

        if let text = text {
            updateText(text)
        }
    }

    func creatBackgroundBox(lines: Int, yOffset: Int) -> TileGrid {
        let left = boundingBox.0
        
        var boxWidth = 0
        var boxHeight = 0
        var xBoxOffset = 0
        var yBoxOffset = 0


        if backgroundTight {
            boxWidth = boundingBox.2
            boxHeight = boundingBox.3
            xBoxOffset = 0
            yBoxOffset = boundingBox.1
        } else {
            boxWidth = boundingBox.2 + paddingLeft + paddingRight
            xBoxOffset = -paddingLeft
            boxHeight = height
                        + Int(Double((lines - 1) * height) * lineSpacing)
                        + paddingTop
                        + paddingBottom
            yBoxOffset = -maxCharAscent + yOffset - paddingTop
        }
        boxWidth = max(0, boxWidth)
        boxHeight = max(0, boxHeight)

        let backgroundBitmap = Bitmap(width: boxWidth, height: height, bitCount: 1)
        let backTilegrid = TileGrid(bitmap: backgroundBitmap,
                                    palette: backgroundPalette,
                                    x: left + xBoxOffset,
                                    y: yBoxOffset)
        
        return backTilegrid
    }

    public func updateBackgroundColor(_ newColor: UInt32? = nil) {
        if let opaqueColor = newColor {
            backgroundPalette.makeOpaque(0)
            backgroundPalette[0] = opaqueColor
            backgroundColor = opaqueColor
        } else {
            backgroundPalette.makeTransparent(0)
            if addedBackgroundTilegrid {
                localGroup.remove(at: 0)
                addedBackgroundTilegrid = false
            }
        }

        let yOffset = height / 2

        if let text = text {
            let lines = text.filter {$0 == "\n"}.count

            if addedBackgroundTilegrid {
                if text.count > 0 &&
                    boundingBox.2 + paddingLeft + paddingRight > 0 &&
                    boundingBox.3 + paddingTop + paddingBottom > 0 {
                        localGroup.insert(creatBackgroundBox(lines: lines, yOffset: yOffset), at: 0)
                } else {
                    localGroup.remove(at: 0)
                    addedBackgroundTilegrid = false
                }
            } else {
                if text.count > 0 &&
                    boundingBox.2 + paddingLeft + paddingRight > 0 &&
                    boundingBox.3 + paddingTop + paddingBottom > 0 {
                        if localGroup.size > 0 {
                            localGroup.insert(creatBackgroundBox(lines: lines, yOffset: yOffset), at: 0)
                        } else {
                            localGroup.append(creatBackgroundBox(lines: lines, yOffset: yOffset))
                        }
                        addedBackgroundTilegrid = true
                }
            }
        }
    }

    public func updateText(_ newText: String) {
        var x = 0, y = 0, i = 0

        if addedBackgroundTilegrid {
            i = 1
        }
        var tileGridCount = i

        let yOffset = height / 2

        var right = 0, top = 0, bottom = 0
        var left = Int.max

        let utf16Chars = Array<UInt16>(newText.utf16)

        for char in utf16Chars {
            //if char == "\n" {
            if char == 0x0A {
                y += Int(Double(height) * lineSpacing)
                x = 0
                continue
            }
            //let glyph = font.getGlyph(char.utf16.first!)
            let glyph = font.getGlyph(char)
            right = max(right, x + glyph.shiftX, x + glyph.width + glyph.dx)
            if x == 0 {
                left = min(left, glyph.dx)
            }
            if y == 0 {
                top = min(top, -glyph.height - glyph.dy + yOffset)
            }

            bottom = max(bottom, y - glyph.dy + yOffset)
            let positionY = y - glyph.height - glyph.dy + yOffset
            let positionX = x + glyph.dx

            if glyph.width > 0 && glyph.height > 0 {
                let face = TileGrid(bitmap: glyph.bitmap!,
                                    palette: palette,
                                    x: positionX,
                                    y: positionY)
                if tileGridCount < localGroup.size {
                    localGroup.insert(face, at: tileGridCount)
                } else {
                    localGroup.append(face)
                }
                tileGridCount += 1               
            }

            x += glyph.shiftX
            i += 1
        }

        if left == Int.max {
            left = 0
        }

        while localGroup.size > tileGridCount {
            localGroup.pop()
        }

        text = newText
        boundingBox = (left, top, right - left, bottom - top)

        if backgroundColor != nil {
            updateBackgroundColor(backgroundColor)
        }

    }
}