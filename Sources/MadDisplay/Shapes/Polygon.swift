public class Polygon: TileGrid {
    public typealias Point = (x: Int, y: Int)

    public init(_ points: [Point], outline: UInt32? = nil) {
        var xs = [Int]()
        var ys = [Int]()

        for point in points {
            xs.append(point.x)
            ys.append(point.y)
        }

        let xOffset = xs.min()!
        let yOffset = ys.min()!

        let width = xs.max()! - xOffset + 1
        let height = ys.max()! - yOffset + 1

        let _palette = Palette(count: 3)
        _palette.makeTransparent(0)

        let _bitmap = Bitmap(width: width, height: height, bitCount: 4)

        super.init(bitmap: _bitmap, palette: _palette, x: xOffset, y: yOffset)

        if let outline = outline {
            palette[1] = outline
            for index in 0..<points.count{
                let pointA = points[index]
                let pointB: Point
                if index != points.count - 1 {
                    pointB = points[index + 1]
                } else {
                    pointB = points[0]
                }
                line(x0: pointA.x, y0: pointA.y, x1: pointB.x, y1: pointB.y, color: 1)
            }
        }
    }

    func line(x0: Int, y0: Int, x1: Int, y1: Int, color: UInt32) {
        var x0 = x0, y0 = y0, x1 = x1, y1 = y1
        if x0 == x1 {
            if y0 > y1 {
                swap(&y0, &y1)
            }
            for h in y0..<(y1 + 1) {
                bitmap[x0, h] = color
            }
        } else if y0 == y1 {
            if x0 > x1 {
                swap(&x0, &x1)
            }
            for w in x0..<(x1 + 1) {
                bitmap[w, y0] = color
            }
        } else {
            let steep = abs(y1 - y0) > abs(x1 - x0)
            if steep {
                swap(&x0, &y0)
                swap(&x1, &y1)
            }

            if x0 > x1 {
                swap(&x0, &x1)
                swap(&y0, &y1)
            }

            let dx = x1 - x0
            let dy = abs(y1 - y0)

            var err = dx / 2
            let yStep: Int

            if y0 < y1 {
                yStep = 1
            } else {
                yStep = -1
            }

            for x in x0..<x1 {
                if steep {
                    bitmap[y0, x] = color
                } else {
                    bitmap[x, y0] = color
                }
                err -= dy
                if err < 0 {
                    y0 += yStep
                    err += dx
                }
            }
        }
    }

    func outline(_ color: UInt32?) {
        if let color = color {
            palette[1] = color
            palette.makeOpaque(1)
        } else {
            palette[1] = 0
            palette.makeTransparent(1)
        }
    }

}