/// Create lines. A line is also a tile and needed to be added to a group for display.
public final class Line: Polygon {
    /// Create a line by setting two points.
    /// - Parameters:
    ///   - x0: x coordinate of one point.
    ///   - y0: y coordinate of one point.
    ///   - x1: x coordinate of the other point.
    ///   - y1: y coordinate of the other point.
    ///   - color: a UInt32 color value for the line.
    public init(x0: Int, y0: Int, x1: Int, y1: Int, color: UInt32?) {
        super.init([(x0, y0), (x1, y1)], outline: color)
    }
}
