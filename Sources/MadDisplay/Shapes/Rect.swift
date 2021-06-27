public final class Rect: Tile {
    public init(x: Int, y: Int, width: Int, height: Int, fill: UInt32! = nil, outline: UInt32! = nil, stroke: Int = 1) {
        let bitmap = Bitmap(width: width, height: height, bitCount: 2)
        let palette = Palette(count: 2)

        if outline != nil {
            palette[1] = outline
            for w in 0..<width {
                for line in 0..<stroke {
                    bitmap[w, line] = 1
                    bitmap[w, height - 1 - line] = 1
                }
            }

            for h in 0..<height {
                for line in 0..<stroke {
                    bitmap[line, h] = 1
                    bitmap[width - 1 - line, h] = 1
                }
            }
        } else {
            palette[1] = 0
            palette.makeTransparent(1)
        }

        if fill != nil {
            palette[0] = fill
        } else {
            palette[0] = 0
            palette.makeTransparent(0)
        }

        super.init(x: x, y: y, bitmap: bitmap, palette: palette)
    }

    public func setOutline(color: UInt32!) {
        if color != nil {
            palette[1] = color
            palette.makeOpaque(1)
        } else {
            palette[1] = 0
            palette.makeTransparent(1)
        }
    }

    public func fill(color: UInt32!) {
        if color != nil {
            palette[0] = color
            palette.makeOpaque(0)
        } else {
            palette[0] = 0
            palette.makeTransparent(0)
        }
    }
}