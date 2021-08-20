public final class Palette {
    struct ColorFormats {
        var rgb888: UInt32 = 0
        var rgb565: UInt16 = 0
        var luma: UInt8 = 0
        var hue: UInt8 = 0
        var chroma: UInt8 = 0
        var transparent: Bool = false
    }

    var colorFormats: [ColorFormats]
    var needsRefresh = true

    public init(count: Int = 0) {
        colorFormats = [ColorFormats]()

        if count != 0 {
            colorFormats = [ColorFormats](repeating: ColorFormats(), count: count)
        }
    }
}

extension Palette {
    var count: Int {
        colorFormats.count
    }

    public func getColor(at index: Int) -> UInt32 {
        guard index < count else {
            return 0
        }

        return colorFormats[index].rgb888
    }

    public func getColor(colorSpace: ColorSpace, at index: Int) -> UInt32? {
        guard index < count else {
            return nil
        }

        if colorFormats[index].transparent {
            return nil
        }

        if colorSpace.tricolor {
            let luma = colorFormats[index].luma
            var ret = UInt32(luma >> (8 - colorSpace.depth))

            if colorFormats[index].chroma <= 16 {
                if !colorSpace.grayscale {
                    ret = 0
                }
            } else {
                let hue = colorFormats[index].hue
                ColorConverter.computeTricolor(colorSpace: colorSpace, hue: hue, luma: luma, color: &ret)
            }
            return ret
        } else if colorSpace.grayscale {
            return UInt32(colorFormats[index].luma >> (8 - colorSpace.depth))
        } else {
            let packed = colorFormats[index].rgb565
            if colorSpace.reverseBytesInWord {
                return UInt32(packed.byteSwapped)
            } else {
                return UInt32(packed)
            }
        }
    }
}

extension Palette {
    public func append(_ color: UInt32) {
        var newColor = ColorFormats()

        newColor.rgb888 = color
        newColor.luma = ColorConverter.computeLuma(color)
        newColor.rgb565 = ColorConverter.computeRgb565(color)
        newColor.chroma = ColorConverter.computeChroma(color)
        newColor.hue = ColorConverter.computeHue(color)

        colorFormats.append(newColor)

        needsRefresh = true
    }

    public func setColor(_ color: UInt32, at index: Int) {
        guard index < count else {
            return
        }
        var newColor = ColorFormats()

        newColor.rgb888 = color
        newColor.luma = ColorConverter.computeLuma(color)
        newColor.rgb565 = ColorConverter.computeRgb565(color)
        newColor.chroma = ColorConverter.computeChroma(color)
        newColor.hue = ColorConverter.computeHue(color)

        colorFormats[index] = newColor

        needsRefresh = true
    }

    public subscript(index: Int) -> UInt32 {
        set {
            setColor(newValue, at: index)
        }
        get {
            return getColor(at: index)
        }
    }

    public func makeOpaque(_ index: Int) {
        colorFormats[index].transparent = false 
        needsRefresh = true
    }

    public func makeTransparent(_ index: Int) {
        colorFormats[index].transparent = true
        needsRefresh = true
    }


    func finishRefresh() {
        needsRefresh = false
    }

}