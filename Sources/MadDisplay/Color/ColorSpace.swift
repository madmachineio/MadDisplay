public struct ColorSpace {
    public var depth: UInt8
    public var bytesPerCell: UInt8
    public var tricolorHue: UInt8
    public var tricolorLuma: UInt8
    public var tricolor: Bool
    public var grayscale: Bool
    public var pixelsInByteShareRow: Bool
    public var reversePixelsInByte: Bool
    public var reverseBytesInWord: Bool
    public var dither: Bool

    public init(depth: UInt8 = 16,
                bytesPerCell: UInt8 = 1,
                tricolorHue: UInt8 = 0,
                tricolorLuma: UInt8 = 0,
                tricolor: Bool = false,
                grayscale: Bool = false,
                pixelsInByteShareRow: Bool = false,
                reversePixelsInByte: Bool = false,
                reverseBytesInWord: Bool = true,
                dither: Bool = false) {
                    self.depth = depth
                    self.bytesPerCell = bytesPerCell
                    self.tricolorHue = tricolorHue
                    self.tricolorLuma = tricolorLuma
                    self.tricolor = tricolor
                    self.grayscale = grayscale
                    self.pixelsInByteShareRow = pixelsInByteShareRow
                    self.reversePixelsInByte = reversePixelsInByte
                    self.reverseBytesInWord = reverseBytesInWord
                    self.dither = dither
                }
}