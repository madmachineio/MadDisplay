public struct ColorSpace {
    public var depth: UInt8 = 16
    public var bytesPerCell: UInt8 = 1
    public var tricolorHue: UInt8 = 0
    public var tricolorLuma: UInt8 = 0
    public var tricolor: Bool = false
    public var grayscale: Bool = false
    public var pixelsInByteShareRow: Bool = false
    public var reversePixelsInByte: Bool = false
    public var reverseBytesInWord: Bool = true
    public var dither: Bool = false

    public init() {}
}