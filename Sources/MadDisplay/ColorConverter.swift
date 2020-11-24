struct InputPixel {
    var pixel: UInt32 = 0
    var x: Int = 0
    var y: Int = 0
    var tile: Int = 0
    var tileX: Int = 0
    var tileY: Int = 0
}

struct OutputPixel {
    var pixel: UInt32 = 0
    var opaque: Bool = true
}

struct ColorConverter {
    static var dither: Bool = false

    static func ditherNoise1(_ n: UInt32) -> UInt32 {
        let n = (n >> 13) ^ n
        let nn = (n &* (n &* n &* 60493 &+ 19990303) &+ 1376312589) & 0x7FFFFFFF
        return UInt32(Float(nn) / (1073741824.0 * 2) * 255)
    }

    static func ditherNoise2(x: Int, y: Int) -> UInt32 {
        return ditherNoise1(UInt32(x + y * 0xFFFF))
    }

    static func computeRgb565(_ color: UInt32) -> UInt16 {
        let r5: UInt32 = (color >> 19) & 0x1F
        let g6: UInt32 = (color >> 10) & 0x3F
        let b5: UInt32 = (color >> 3) & 0x1F

        return UInt16(r5 << 11 | g6 << 5 | b5)
    }

    static func computeLuma(_ color: UInt32) -> UInt8 {
        let r8: UInt32 = (color >> 16) & 0xFF
        let g8: UInt32 = (color >> 8) & 0xFF
        let b8: UInt32 = color & 0xFF
        return UInt8((r8 * 19) / 255 + (g8 * 182) / 255 + (b8 + 54) / 255)
    }

    static func computeChroma(_ color: UInt32) -> UInt8 {
        let r8: UInt32 = (color >> 16) & 0xFF
        let g8: UInt32 = (color >> 8) & 0xFF
        let b8: UInt32 = color & 0xFF
        let maxColor = max(r8, g8, b8)
        let minColor = min(r8, g8, b8)
        return UInt8(maxColor - minColor)
    }

    static func computeHue(_ color: UInt32) -> UInt8 {
        let r8: Int32 = Int32((color >> 16) & 0xFF)
        let g8: Int32 = Int32((color >> 8) & 0xFF)
        let b8: Int32 = Int32(color & 0xFF)
        let maxColor = max(r8, g8, b8)
        let minColor = min(r8, g8, b8)
        let c = maxColor - minColor;
        if (c == 0) {
            return 0
        }

        var hue: Int32 = 0
        if (maxColor == r8) {
            hue = (((g8 - b8) * 40) / c) % 240;
        } else if (maxColor == g8) {
            hue = (((b8 - r8) + (2 * c)) * 40) / c
        } else if (maxColor == b8) {
            hue = (((r8 - g8) + (4 * c)) * 40) / c
        }
        if (hue < 0) {
            hue += 240
        }

        return UInt8(hue)
    }

    static func computeTricolor(colorSpace: ColorSpace, hue: UInt8, luma: UInt8, color: inout UInt32) {
        let hueDiff = Int(colorSpace.tricolorHue) - Int(hue)
        if (-10 <= hueDiff && hueDiff <= 10) || hueDiff <= -220 || hueDiff >= 220 {
            if (colorSpace.grayscale) {
                color = 0
            } else {
                color = 1
            }
        } else if (!colorSpace.grayscale) {
            color = 0
        }
    }

    static func convert(colorSpace: ColorSpace, inputPixel: InputPixel) -> OutputPixel {
        var outputPixel = OutputPixel()
        var pixel = inputPixel.pixel

        if dither {
            let randr = ditherNoise2(x: inputPixel.tileX, y: inputPixel.tileY) & 0xFF
            let randg = ditherNoise2(x: inputPixel.tileX + 33, y: inputPixel.tileY) & 0xFF
            let randb = ditherNoise2(x: inputPixel.tileX, y: inputPixel.tileY + 33) & 0xFF

            var r8 = pixel >> 16
            var g8 = (pixel >> 8) & 0xFF
            var b8 = pixel & 0xFF 

            if colorSpace.depth == 16 {
                b8 = (b8 + randb & 0x07) & 0xFF
                r8 = (r8 + randr & 0x07) & 0xFF
                g8 = (g8 + randg & 0x03) & 0xFF
            } else {
                let bitmask: UInt32 = 0xFF >> colorSpace.depth
                b8 = (b8 + randb & bitmask) & 0xFF
                r8 = (r8 + randr & bitmask) & 0xFF
                g8 = (g8 + randg & bitmask) & 0xFF
            }

            pixel = r8 << 16 | g8 << 8 | b8
        }

        if colorSpace.depth == 16 {
            var packed = computeRgb565(pixel)
            if colorSpace.reverseBytesInWord {
                packed = (packed << 8) | (packed >> 8)
            }
            outputPixel.pixel = UInt32(packed)
            outputPixel.opaque = true
        } else if colorSpace.tricolor {
            let luma = computeLuma(pixel)
            outputPixel.pixel = UInt32(luma >> (8 - colorSpace.depth))
            if computeChroma(pixel) <= 16 {
                if !colorSpace.grayscale {
                    outputPixel.pixel = 0
                }
                outputPixel.opaque = true
                return outputPixel
            }
            let pixelHue = computeHue(pixel)
            computeTricolor(colorSpace: colorSpace, hue: pixelHue, luma: luma, color: &outputPixel.pixel)
        } else if colorSpace.grayscale && colorSpace.depth <= 8 {
            let luma = computeLuma(pixel)
            outputPixel.pixel = UInt32(luma >> (8 - colorSpace.depth))
            outputPixel.opaque = true
        } else {
            outputPixel.opaque = false
        }
        return outputPixel
    }

    static func convert(colorSpace: ColorSpace, inputColor: UInt32) -> UInt32 {
        var inputPixel = InputPixel()
        inputPixel.pixel = inputColor

        let outputPixel = convert(colorSpace: colorSpace, inputPixel: inputPixel)
        return outputPixel.pixel
    }

}