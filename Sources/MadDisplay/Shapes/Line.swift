/// Create lines.
///
/// Two points are needed to draw a line.
/// A line is also a tile and needed to be added to a group for display.
/// Here is an example:
/// ```swift
/// let line = Line(x0: 20, y0: 20, x1: 200, y1: 200, color: Color.red)
///
/// // Add the line to a group for display.
/// let group = Group()
/// group.append(line)
/// ```
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
