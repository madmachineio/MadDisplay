public final class Triangle: Polygon {
    public init(x0: Int, y0: Int, x1: Int, y1: Int, x2: Int, y2: Int, fill: UInt32?, outline: UInt32?) {
        print("t0")
        var x0 = x0, y0 = y0, x1 = x1, y1 = y1, x2 = x2, y2 = y2
        
        if y0 > y1 {
            swap(&y0, &y1)
        }

        if y1 > y2 {
            swap(&y1, &y2)
        }

        if y0 > y2 {
            swap(&y0, &y2)
        }

        print("t1")
        let xs = [x0, x1, x2]
        let points: [Point] = [(x0, y0), (x1, y1), (x2, y2)]

        print("t2")
        super.init(points)

        print("t3")
        let minX = xs.min()!
        print("t4")
        if let fill = fill {
            print("t4---0")
            palette[2] = fill
            print("t4---1")
            drawFilled(x0: x0 - minX,
                       y0: 0,
                       x1: x1 - minX,
                       y1: y1 - y0,
                       x2: x2 - minX,
                       y2: y2 - y0)
            print("t4---2")
        }

        print("t5")
        if let outline = outline {
            palette[1] = outline
            for index in 0..<points.count {
                let pointA = points[index]
                let pointB: Point
                if index != points.count - 1 {
                    pointB = points[index + 1]
                } else {
                    pointB = points[0]
                }
                line(x0: pointA.x - minX,
                     y0: pointA.y - y0,
                     x1: pointB.x - minX,
                     y1: pointB.y - y0,
                     color: 1)
            }
        }
        print("t6")
        
    }

    func drawFilled(x0: Int, y0: Int, x1: Int, y1: Int, x2: Int, y2: Int) {
        print("draw0")
        var a, b: Int

        if y0 == y2 {
            var a = x0
            var b = x0

            print("draw0-0")
            if x1 < a {
                a = x1
            } else if x1 > b {
                b = x1
            }
            print("draw0-1")

            if x2 < a {
                a = x2
            } else if x2 > b {
                b = x2
            }
            print("draw0-2")

            line(x0: a, y0: y0, x1: b, y1: y0, color: 2)
            print("draw0-3")
            return
        }

        print("draw1")
        let last: Int
        if y1 == y2 {
            last = y1
        } else {
            last = y1 - 1
        }

        print("draw2")
        print("y0 = \(y0), last = \(last)")
        for y in y0..<(last + 1) {
            print("draw20")
            a = x0 + (x1 - x0) * (y - y0) / (y1 - y0)
            print("draw21")
            b = x0 + (x2 - x0) * (y - y0) / (y2 - y0)
            print("draw22")
            if a > b {
                swap(&a, &b)
            }
            print("draw2 if")
            line(x0: a, y0: y, x1: b, y1: y, color: 2)
            print("draw2 line")
        }
        print("draw3")

        for y in (last + 1)..<(y2 + 1) {
            a = x1 + (x2 - x1) * (y - y1) / (y2 - y1)
            b = x0 + (x2 - x0) * (y - y0) / (y2 - y0)

            if a > b {
                swap(&a, &b)
            }
            line(x0: a, y0: y, x1: b, y1: y, color: 2)
        }
        print("draw4")
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

}