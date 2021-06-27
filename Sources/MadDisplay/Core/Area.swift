struct Area {

    var x1: Int
    var y1: Int
    var x2: Int
    var y2: Int

    init () {
        x1 = -1
        y1 = -1
        x2 = -1
        y2 = -1
    }

    init(x1: Int, y1: Int, x2: Int, y2: Int) {
        guard x2 >= x1 && y2 >= y1 else {
            fatalError("x2, y2 must >= x1, y1")
        }

        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
    }

    init(x1: Int, y1: Int, width: Int, height: Int) {
        guard width > 0 && height > 0 else {
            fatalError("width and height must > 1")
        }

        self.x1 = x1
        self.y1 = y1
        self.x2 = x1 + width - 1
        self.y2 = y1 + height - 1
    }
}

extension Area: Equatable {
    static func == (lhs: Area, rhs: Area) -> Bool {
        return
            lhs.x1 == rhs.x1 &&
            lhs.y1 == rhs.y1 &&
            lhs.x2 == rhs.x2 &&
            lhs.y2 == rhs.y2
    }

    static func != (lhs: Area, rhs: Area) -> Bool {
        return
            lhs.x1 != rhs.x1 ||
            lhs.y1 != rhs.y1 ||
            lhs.x2 != rhs.x2 ||
            lhs.y2 != rhs.y2
    }
}

extension Area {

    var width: Int {
        x2 - x1 + 1
    }

    var height: Int {
        y2 - y1 + 1
    }

    var size: Int {
        width * height
    }

    func intersection(_ b: Area) -> Area? {
        let ix1 = x1 > b.x1 ? x1 : b.x1
        let iy1 = y1 > b.y1 ? y1 : b.y1
        let ix2 = x2 < b.x2 ? x2 : b.x2
        let iy2 = y2 < b.y2 ? y2 : b.y2

        if ix1 > ix2 || iy1 > iy2 {
            return nil
        } else {
            return Area(x1: ix1, y1: iy1, x2: ix2, y2: iy2)
        }
    }

    func union(_ b: Area) -> Area {
        let ux1 = x1 < b.x1 ? x1 : b.x1
        let uy1 = y1 < b.y1 ? y1 : b.y1
        let ux2 = x2 > b.x2 ? x2 : b.x2
        let uy2 = y2 > b.y2 ? y2 : b.y2

        return Area(x1: ux1, y1: uy1, x2: ux2, y2: uy2)
    }

    func transformWithin(mirrorX: Bool, mirrorY: Bool, transposeXY: Bool, _ whole: Area) -> Area {
        var transformed = Area()

        if mirrorX {
            transformed.x1 = whole.x1 + (whole.x2 - x2)
            transformed.x2 = whole.x2 - (x1 - whole.x1)
        } else {
            transformed.x1 = x1
            transformed.x2 = x2
        }

        if mirrorY {
            transformed.y1 = whole.y1 + (whole.y2 - y2)
            transformed.y2 = whole.y2 - (y1 - whole.y1)
        } else {
            transformed.y1 = y1
            transformed.y2 = y2
        }

        if transposeXY {
            let y1 = transformed.y1
            let y2 = transformed.y2
            transformed.y1 = whole.y1 + (transformed.x1 - whole.x1)
            transformed.y2 = whole.y1 + (transformed.x2 - whole.x1)
            transformed.x2 = whole.x1 + (y2 - whole.y1)
            transformed.x1 = whole.x1 + (y1 - whole.y1)
        }

        return transformed
    }

    func isSubset(of b: Area) -> Bool {
        if x1 <= b.x2 &&
            x2 >= b.x1 &&
            y1 <= b.y2 &&
            y2 >= b.y1 {
                return true
            } else {
                return false
            }
    }

    func isSuperset(of b: Area) -> Bool {
        if x1 >= b.x2 &&
            x2 <= b.x1 &&
            y1 >= b.y2 &&
            y2 <= b.y1 {
                return true
            } else {
                return false
            }
    }
}

extension Area {

    mutating func shift(dx: Int, dy: Int) {
        x1 += dx
        x2 += dx
        y1 += dy
        y2 += dy
    }

    mutating func moveTo(x: Int, y: Int) {
        let w = width
        let h = height

        x1 = x
        y1 = y
        x2 = x + w
        y2 = y + h
    }
}