/// Create a palette to store colors for a bitmap.
///
/// You could regard a palette as an array of colors. The indexes of colors start
/// from 0.
///
/// To create a palette and stores colors, you could initialize an empty palette
/// and then add colors.
///
/// ```swift
/// // Create an empty palette.
/// let palette0 = Palette()
/// // Add a new color to the palette.
/// palette0.append(Color.white)
/// ```
///
/// You could also create a palette with the specified amount colors. By default,
/// they are all black. Then replace the colors.
///
/// ```swift
/// // Create a palette with 1 color.
/// let palette1 = Palette(count: 1)
/// // Replace the first color with white.
/// palette1[0] = Color.white
/// ```
///
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

    /// Initialize a palette to store colors. All colors will be black by default.
    /// - Parameter count: the possible amount of colors in the palette after initialization. By default, it has no color.
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

    /// Get the color at a specified index in the palette.
    /// - Parameter index: the index of color in the palette.
    /// - Returns: a UInt32 color value.
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
    /// Add a new color to the end of the palette.
    /// - Parameter color: a color value in UInt32.
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

    /// Replace the specified color in the palette with a new one.
    /// - Parameters:
    ///   - color: the new color in UInt32.
    ///   - index: the index of the color to be changed in the palette. It
    ///   shouldn't exceed the maximum (total count-1).
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

    /// Access the color in the palette using its index.
    public subscript(index: Int) -> UInt32 {
        set {
            setColor(newValue, at: index)
        }
        get {
            return getColor(at: index)
        }
    }

    /// Make the transparent color opaque.
    ///
    /// The color has just two states: transparent or opaque, you couldn’t change
    /// its opacity.
    /// - Parameter index: the index of color.
    public func makeOpaque(_ index: Int) {
        colorFormats[index].transparent = false 
        needsRefresh = true
    }

    /// Make the specified color transparent, thus the covered element under
    /// the area will appear.
    /// - Parameter index: the index of color.
    public func makeTransparent(_ index: Int) {
        colorFormats[index].transparent = true
        needsRefresh = true
    }


    func finishRefresh() {
        needsRefresh = false
    }

}
