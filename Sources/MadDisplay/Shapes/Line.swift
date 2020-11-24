public final class Line: Polygon {
    public init(x0: Int, y0: Int, x1: Int, y1: Int, color: UInt32?) {
        super.init([(x0, y0), (x1, y1)], outline: color)
    }
}