/// Create circles.
///
/// It is derived from ``MadDisplay/RoundRect``. Its height and width happen to
/// be twice the radius. The x and y coordinates decide the center of the circle.
/// The radius decides its size. A circle is also a tile and needed to be added
/// to a group for display. For example:
/// ```swift
/// let circle = Circle(x: 20, y: 20, radius: 10, fill: Color.lime)
///
/// // Add the circle to a group for display.
/// let group = Group()
/// group.append(circle)
/// ```
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
