public final class Circle: RoundRect {
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