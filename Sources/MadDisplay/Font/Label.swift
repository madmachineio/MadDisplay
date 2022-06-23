/// Create labels for text display.
///
/// A label is actually a group that consists of the text and its background.
/// Each character of the text is a tile. The background of a label is also a tile.
/// You can directly display a label on the screen. But it’s better to add it
/// to a main group to manage all elements. For example:
///
///```swift
/// // Set the content of the label. All other parameters are set to default.
/// let text = Label(text: "Hello!")
///
/// // Add the text to a main group for display.
/// let group = Group()
/// group.append(text)
///```
///
/// The font used to display text is **bitmap font**. This type of font stores
/// all pixels for each character. There is a default font (``RobotRegular16``).
/// You could find another font ``ASCII8``, and its size is much smaller.
///
/// ```swift
/// let text1 = Label(text: "Hello!", font: ASCII8)
/// ```
/// Besides, you could use ``PCFFont`` to set customized font.
///
/// If you want to change the text, you need to update the label with new text.
/// And don't forget to use ``MadDisplay/MadDisplay/update(_:)`` to update the display, or the text on the screen won't be changed.
/// ```swift
/// text.updateText("Hi!")
/// ```
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
    var addedBackgroundTile = false
    
    var scaleValue: Int

    var height: Int
    var maxCharAscent: Int
    var maxCharDescent: Int

    let palette = Palette(count: 2)
    let backgroundPalette = Palette(count: 1)

    //var anchorPoint: Point?
    //var anchorPosition: Point?
    var boundingBox: (Int, Int, Int, Int) = (0, 0, 0, 0)


    /// Create a label by setting the text.
    /// - Parameters:
    ///   - x: the x-coordinate of the upper left corner of the label.
    ///   - y: the y-coordinate of the upper left corner of the label.
    ///   - scale: an integer to set the size of the label. It is 1 by default
    ///   so the label keeps its original size.
    ///   - text: the text to display on the screen.
    ///   - color: the color of the text in UInt32, white by default.
    ///   - font: the font of the color. It has a default font ``RobotRegular16``.
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

    func creatBackgroundBox(lines: Int, yOffset: Int) -> Tile {
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
        let backTile = Tile(x: left + xBoxOffset,
                                    y: yBoxOffset,
                                    bitmap: backgroundBitmap,
                                    palette: backgroundPalette)
        
        return backTile
    }

    /// Set the background color for the label.
    /// - Parameter newColor: a UInt32 color value.
    public func updateBackgroundColor(_ newColor: UInt32? = nil) {
        if let opaqueColor = newColor {
            backgroundPalette.makeOpaque(0)
            backgroundPalette[0] = opaqueColor
            backgroundColor = opaqueColor
        } else {
            backgroundPalette.makeTransparent(0)
            if addedBackgroundTile {
                localGroup.remove(at: 0)
                addedBackgroundTile = false
            }
        }

        let yOffset = height / 2

        if let text = text {
            let lines = text.filter {$0 == "\n"}.count

            if addedBackgroundTile {
                if text.count > 0 &&
                    boundingBox.2 + paddingLeft + paddingRight > 0 &&
                    boundingBox.3 + paddingTop + paddingBottom > 0 {
                        localGroup.insert(creatBackgroundBox(lines: lines, yOffset: yOffset), at: 0)
                } else {
                    localGroup.remove(at: 0)
                    addedBackgroundTile = false
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
                        addedBackgroundTile = true
                }
            }
        }
    }

    /// Change the text.
    ///
    /// After you invoke this method, you still need to update the display using
    /// ``MadDisplay/MadDisplay/update(_:)`` to show the new text.
    /// - Parameter newText: the new text.
    public func updateText(_ newText: String) {
        var x = 0, y = 0, i = 0

        if addedBackgroundTile {
            i = 1
        }
        var tileCount = i

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

            //print("top = \(top), left = \(left), bottom = \(bottom)")
            //print("posX = \(positionX), posY = \(positionY)")
            
            //print(glyph.bitmap!.data)

            if glyph.width > 0 && glyph.height > 0 {
                let face = Tile(    x: positionX,
                                    y: positionY,
                                    bitmap: glyph.bitmap!,
                                    palette: palette)
                if tileCount < localGroup.size {
                    localGroup.insert(face, at: tileCount)
                } else {
                    localGroup.append(face)
                }
                tileCount += 1               
            }

            x += glyph.shiftX
            i += 1
        }

        if left == Int.max {
            left = 0
        }

        while localGroup.size > tileCount {
            localGroup.pop()
        }

        text = newText
        boundingBox = (left, top, right - left, bottom - top)

        if backgroundColor != nil {
            updateBackgroundColor(backgroundColor)
        }
    }
}
