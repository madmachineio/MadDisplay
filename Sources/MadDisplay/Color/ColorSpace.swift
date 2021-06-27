public struct ColorSpace {
    public let depth: UInt8
    public let bytesPerCell: UInt8
    public let tricolorHue: UInt8
    public let tricolorLuma: UInt8
    public let tricolor: Bool
    public let grayscale: Bool
    public let pixelsInByteShareRow: Bool
    public let reversePixelsInByte: Bool
    public let reverseBytesInWord: Bool
    public let dither: Bool

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