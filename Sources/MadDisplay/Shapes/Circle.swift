/// Create circles. A circle is also a tile and needed to be added to a group
/// for display.
public final class Circle: RoundRect {
    /// Create a circle.
    ///
    /// Its size is determined only by the radius. The outline takes up its
    /// internal area and will not influence shape’s overall area.
    /// - Parameters:
    ///   - x: x coordinate of the center of the circle.
    ///   - y: y coordinate of the center of the circle.
    ///   - r: the radius of the circle.
    ///   - fill: the color used to fill the circle, nil by default.
    ///   - outline: the color of outline, nil by default.
    ///   - stroke: the width of the outline, 1 pixel by default.
    public init(x: Int, y: Int, radius r: Int, fill: UInt32? = nil, outline: UInt32? = nil, stroke: Int = 1) {
        super.init(x: x - r,
                   y: y - r,
                   width: 2 * r + 1,
                   height: 2 * r + 1,
                   radius: r,
                   fill: fill,
                   outline: outline,
                   stroke: stroke)
    }
}
