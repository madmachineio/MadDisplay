public class RoundRect: TileGrid {
    public init(x: Int, y: Int, width: Int, height: Int, radius r: Int, fill: UInt32! = nil, outline: UInt32! = nil, stroke: Int = 1) {
        let _bitmap = Bitmap(width: width, height: height, bitCount: 4)
        let _palette = Palette(count: 3)

        super.init(bitmap: _bitmap, palette: _palette, x: x, y: y)

        palette.makeTransparent(0)

        for i in 0..<width {
            for j in r..<(height - r) {
                bitmap[i, j] = 2
            }
        }

        helper(r, r, r, color: 2, xOffset: width - 2 * r - 1, yOffset: height - 2 * r - 1, fill: true)

        if let value = fill {
            palette[2] = value
        } else {
            palette[2] = 0
            palette.makeTransparent(2)
        }

        if let outline = outline {
            palette[1] = outline

            for w in r..<(width - r) {
                for line in 0..<stroke {
                    bitmap[w, line] = 1
                    bitmap[w, height - line - 1] = 1
                }
            }
            for h in r..<(height - r) {
                for line in 0..<stroke {
                    bitmap[line, h] = 1
                    bitmap[width - line - 1, h] = 1
                }
            }
            helper(r, r, r, color: 1, xOffset: width - 2 * r - 1, yOffset: height - 2 * r - 1, stroke: stroke)
        }

    }


    func helper(_ x0: Int, _ y0: Int, _ r: Int, color: UInt32, xOffset: Int = 0, yOffset: Int = 0, stroke: Int = 1, cornerFlag: UInt8 = 0x0F, fill: Bool = false) {
        var f = 1 - r
        var ddFX = 1
        var ddFY = -2 * r
        var x = 0
        var y = r

        while x < y {
            if f >= 0 {
                y -= 1
                ddFY += 2
                f += ddFY
            }
            x += 1
            ddFX += 2
            f += ddFX

            if (cornerFlag & 0x08) != 0 {
                if fill {
                    for w in (x0 - y)..<(x0 + y + xOffset) {
                        bitmap[w, y0 + x + yOffset] = color
                    }
                    for w in (x0 - x)..<(x0 + x + xOffset) {
                        bitmap[w, y0 + y + yOffset] = color
                    }
                } else {
                    for line in 0..<stroke {
                        bitmap[x0 - y + line, y0 + x + yOffset] = color
                        bitmap[x0 - x, y0 + y + yOffset - line] = color
                    }
                }
            } 

            if (cornerFlag & 0x01) != 0 {
                if fill {
                    for w in (x0 - y)..<(x0 + y + xOffset) {
                        bitmap[w, y0 - x] = color
                    }
                    for w in (x0 - x)..<(x0 + x + xOffset) {
                        bitmap[w, y0 - y] = color
                    }
                } else {
                    for line in 0..<stroke {
                        bitmap[x0 - y + line, y0 - x] = color
                        bitmap[x0 - x, y0 - y + line] = color
                    }
                }
            }

            if (cornerFlag & 0x04) != 0 {
                for line in 0..<stroke {
                    bitmap[x0 + x + xOffset, y0 + y + yOffset - line] = color
                    bitmap[x0 + y + xOffset - line, y0 + x + yOffset] = color
                }
            }

            if (cornerFlag & 0x02) != 0 {
                for line in 0..<stroke {
                    bitmap[x0 + x + xOffset, y0 - y + line] = color
                    bitmap[x0 + y + xOffset - line, y0 - x] = color
                }
            }
        }
    }

    public func fill(color: UInt32?) {
        if let color = color {
            palette[2] = color
            palette.makeOpaque(2)
        } else {
            palette[2] = 0
            palette.makeTransparent(2)
        }
    }

    public func outline(color: UInt32?) {
        if let color = color {
            palette[1] = color
            palette.makeOpaque(1)
        } else {
            palette[1] = 0
            palette.makeTransparent(1)
        }
    }

}