/// Create rectangles.
///
/// The upper left vertex decides its position. The width and height decide its
/// size. A rectangle is also a tile and needed to be added to a group for display.
public final class Rect: Tile {
    /// Create a rectangle.
    ///
    /// Its size is determined only by width and height. The outline takes up
    /// its internal area and will not influence shape’s overall area.
    /// - Parameters:
    ///   - x: the x coordinate of the upper left vertex.
    ///   - y: the y coordinate of the upper left vertex.
    ///   - width: the width of the rectangle.
    ///   - height: the height of the rectangle.
    ///   - fill: the color used to fill the rectangle, nil by default.
    ///   - outline: the color of the outline, nil by default.
    ///   - stroke: the width of the outline, 1 pixel by default.
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

    /// Set the color of outline.
    /// - Parameter color: a UInt32 color value.
    public func setOutline(color: UInt32!) {
        if color != nil {
            palette[1] = color
            palette.makeOpaque(1)
        } else {
            palette[1] = 0
            palette.makeTransparent(1)
        }
    }

    /// Fill the rectangle with a specified color.
    /// - Parameter color: a UInt32 color value.
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
