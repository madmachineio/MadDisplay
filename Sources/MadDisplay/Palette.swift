public final class Palette {
    struct Colors {
        var rgb888: UInt32 = 0
        var rgb565: UInt16 = 0
        var luma: UInt8 = 0
        var hue: UInt8 = 0
        var chroma: UInt8 = 0
        var transparent: Bool = false
    }

    var colors: [Colors]
    var needsRefresh = true

    public init(count: Int = 0) {
        colors = [Colors]()

        if count != 0 {
            colors = [Colors](repeating: Colors(), count: count)
        }
    }

    func reserveCapacity(_ value: Int) {
        if count == 0 {
            colors = [Colors](repeating: Colors(), count: count)
        } else if value > count {
            let newColors = [Colors](repeating: Colors(), count: value - count)
            colors.append(contentsOf: newColors)
        }
    }
}

extension Palette {
    var count: Int {
        colors.count
    }

    public func getColor(at index: Int) -> UInt32 {
        guard index < count else {
            return 0
        }

        return colors[index].rgb888
    }

    public func getColor(colorSpace: ColorSpace, at index: Int) -> UInt32? {
        guard index < count else {
            return nil
        }

        if colors[index].transparent {
            return nil
        }

        if colorSpace.tricolor {
            let luma = colors[index].luma
            var ret = UInt32(luma >> (8 - colorSpace.depth))

            if colors[index].chroma <= 16 {
                if !colorSpace.grayscale {
                    ret = 0
                }
            } else {
                let hue = colors[index].hue
                ColorConverter.computeTricolor(colorSpace: colorSpace, hue: hue, luma: luma, color: &ret)
            }
            return ret
        } else if colorSpace.grayscale {
            return UInt32(colors[index].luma >> (8 - colorSpace.depth))
        } else {
            var packed = colors[index].rgb565
            if colorSpace.reverseBytesInWord {
                packed = (packed << 8) | (packed >> 8)
            }
            return UInt32(packed)
        }
    }
}

extension Palette {
    public func append(color: UInt32) {
        var newColor = Colors()

        newColor.rgb888 = color
        newColor.luma = ColorConverter.computeLuma(color)
        newColor.rgb565 = ColorConverter.computeRgb565(color)
        newColor.chroma = ColorConverter.computeChroma(color)
        newColor.hue = ColorConverter.computeHue(color)

        colors.append(newColor)

        needsRefresh = true
    }

    public func setColor(_ color: UInt32, at index: Int) {
        guard index < count else {
            return
        }
        var newColor = Colors()

        newColor.rgb888 = color
        newColor.luma = ColorConverter.computeLuma(color)
        newColor.rgb565 = ColorConverter.computeRgb565(color)
        newColor.chroma = ColorConverter.computeChroma(color)
        newColor.hue = ColorConverter.computeHue(color)

        colors[index] = newColor

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
        colors[index].transparent = false 
    }

    public func makeTransparent(_ index: Int) {
        colors[index].transparent = true
    }


    func finishRefresh() {
        needsRefresh = false
    }

}