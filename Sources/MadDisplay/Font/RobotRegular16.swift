public final class RobotRegular16: Font {
    public var glyphCache: [UInt16: Glyph]
    public let fontHeight = 22
    public let maxCharAscent = 18
    public let maxCharDescent = 4
    
    public func getGlyph(_ encoding: UInt16) -> Glyph {
        if let glyph = glyphCache[encoding] {
            return glyph
        } 
        return glyphCache[0x3F]!
    }

    public init() {
        glyphCache = RobotRegular16.glyphData

        for key in glyphCache.keys {
            glyphCache[key]!.bitmap!.data = RobotRegular16.bitmapData[key]!
        }
    }

    static let glyphData: [UInt16: Glyph] = [
        0 :  Glyph(bitmap: Bitmap(width: 1, height: 1, bitCount: 1), width: 1, height: 1, dx: 0, dy: 0, shiftX: 0, shiftY: 0),
        2 :  Glyph(bitmap: Bitmap(width: 1, height: 1, bitCount: 1), width: 1, height: 1, dx: 0, dy: 0, shiftX: 0, shiftY: 0),
        13 :  Glyph(bitmap: Bitmap(width: 1, height: 1, bitCount: 1), width: 1, height: 1, dx: 0, dy: 0, shiftX: 4, shiftY: 0),
        32 :  Glyph(bitmap: Bitmap(width: 1, height: 1, bitCount: 1), width: 1, height: 1, dx: 0, dy: 0, shiftX: 4, shiftY: 0),
        33 :  Glyph(bitmap: Bitmap(width: 2, height: 12, bitCount: 1), width: 2, height: 12, dx: 1, dy: 0, shiftX: 4, shiftY: 0),
        34 :  Glyph(bitmap: Bitmap(width: 3, height: 4, bitCount: 1), width: 3, height: 4, dx: 1, dy: 8, shiftX: 5, shiftY: 0),
        35 :  Glyph(bitmap: Bitmap(width: 9, height: 12, bitCount: 1), width: 9, height: 12, dx: 1, dy: 0, shiftX: 10, shiftY: 0),
        36 :  Glyph(bitmap: Bitmap(width: 7, height: 15, bitCount: 1), width: 7, height: 15, dx: 1, dy: -1, shiftX: 9, shiftY: 0),
        37 :  Glyph(bitmap: Bitmap(width: 10, height: 12, bitCount: 1), width: 10, height: 12, dx: 1, dy: 0, shiftX: 12, shiftY: 0),
        38 :  Glyph(bitmap: Bitmap(width: 9, height: 12, bitCount: 1), width: 9, height: 12, dx: 1, dy: 0, shiftX: 10, shiftY: 0),
        39 :  Glyph(bitmap: Bitmap(width: 1, height: 4, bitCount: 1), width: 1, height: 4, dx: 1, dy: 8, shiftX: 3, shiftY: 0),
        40 :  Glyph(bitmap: Bitmap(width: 4, height: 17, bitCount: 1), width: 4, height: 17, dx: 1, dy: -4, shiftX: 5, shiftY: 0),
        41 :  Glyph(bitmap: Bitmap(width: 4, height: 17, bitCount: 1), width: 4, height: 17, dx: 0, dy: -4, shiftX: 6, shiftY: 0),
        42 :  Glyph(bitmap: Bitmap(width: 7, height: 6, bitCount: 1), width: 7, height: 6, dx: 0, dy: 6, shiftX: 7, shiftY: 0),
        43 :  Glyph(bitmap: Bitmap(width: 7, height: 8, bitCount: 1), width: 7, height: 8, dx: 1, dy: 1, shiftX: 9, shiftY: 0),
        44 :  Glyph(bitmap: Bitmap(width: 2, height: 4, bitCount: 1), width: 2, height: 4, dx: 0, dy: -2, shiftX: 3, shiftY: 0),
        45 :  Glyph(bitmap: Bitmap(width: 4, height: 1, bitCount: 1), width: 4, height: 1, dx: 0, dy: 4, shiftX: 4, shiftY: 0),
        46 :  Glyph(bitmap: Bitmap(width: 2, height: 2, bitCount: 1), width: 2, height: 2, dx: 1, dy: 0, shiftX: 4, shiftY: 0),
        47 :  Glyph(bitmap: Bitmap(width: 6, height: 13, bitCount: 1), width: 6, height: 13, dx: 0, dy: -1, shiftX: 7, shiftY: 0),
        48 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        49 :  Glyph(bitmap: Bitmap(width: 5, height: 12, bitCount: 1), width: 5, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        50 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        51 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        52 :  Glyph(bitmap: Bitmap(width: 9, height: 12, bitCount: 1), width: 9, height: 12, dx: 0, dy: 0, shiftX: 9, shiftY: 0),
        53 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        54 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        55 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        56 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        57 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        58 :  Glyph(bitmap: Bitmap(width: 2, height: 9, bitCount: 1), width: 2, height: 9, dx: 1, dy: 0, shiftX: 4, shiftY: 0),
        59 :  Glyph(bitmap: Bitmap(width: 3, height: 11, bitCount: 1), width: 3, height: 11, dx: 0, dy: -2, shiftX: 3, shiftY: 0),
        60 :  Glyph(bitmap: Bitmap(width: 6, height: 7, bitCount: 1), width: 6, height: 7, dx: 1, dy: 2, shiftX: 8, shiftY: 0),
        61 :  Glyph(bitmap: Bitmap(width: 7, height: 4, bitCount: 1), width: 7, height: 4, dx: 1, dy: 3, shiftX: 9, shiftY: 0),
        62 :  Glyph(bitmap: Bitmap(width: 7, height: 7, bitCount: 1), width: 7, height: 7, dx: 1, dy: 2, shiftX: 8, shiftY: 0),
        63 :  Glyph(bitmap: Bitmap(width: 6, height: 12, bitCount: 1), width: 6, height: 12, dx: 1, dy: 0, shiftX: 8, shiftY: 0),
        64 :  Glyph(bitmap: Bitmap(width: 13, height: 14, bitCount: 1), width: 13, height: 14, dx: 1, dy: -3, shiftX: 14, shiftY: 0),
        65 :  Glyph(bitmap: Bitmap(width: 10, height: 12, bitCount: 1), width: 10, height: 12, dx: 0, dy: 0, shiftX: 10, shiftY: 0),
        66 :  Glyph(bitmap: Bitmap(width: 8, height: 12, bitCount: 1), width: 8, height: 12, dx: 1, dy: 0, shiftX: 10, shiftY: 0),
        67 :  Glyph(bitmap: Bitmap(width: 9, height: 12, bitCount: 1), width: 9, height: 12, dx: 1, dy: 0, shiftX: 10, shiftY: 0),
        68 :  Glyph(bitmap: Bitmap(width: 9, height: 12, bitCount: 1), width: 9, height: 12, dx: 1, dy: 0, shiftX: 11, shiftY: 0),
        69 :  Glyph(bitmap: Bitmap(width: 8, height: 12, bitCount: 1), width: 8, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        70 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        71 :  Glyph(bitmap: Bitmap(width: 9, height: 12, bitCount: 1), width: 9, height: 12, dx: 1, dy: 0, shiftX: 11, shiftY: 0),
        72 :  Glyph(bitmap: Bitmap(width: 9, height: 12, bitCount: 1), width: 9, height: 12, dx: 1, dy: 0, shiftX: 11, shiftY: 0),
        73 :  Glyph(bitmap: Bitmap(width: 2, height: 12, bitCount: 1), width: 2, height: 12, dx: 1, dy: 0, shiftX: 4, shiftY: 0),
        74 :  Glyph(bitmap: Bitmap(width: 8, height: 12, bitCount: 1), width: 8, height: 12, dx: 0, dy: 0, shiftX: 9, shiftY: 0),
        75 :  Glyph(bitmap: Bitmap(width: 9, height: 12, bitCount: 1), width: 9, height: 12, dx: 1, dy: 0, shiftX: 10, shiftY: 0),
        76 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        77 :  Glyph(bitmap: Bitmap(width: 12, height: 12, bitCount: 1), width: 12, height: 12, dx: 1, dy: 0, shiftX: 14, shiftY: 0),
        78 :  Glyph(bitmap: Bitmap(width: 9, height: 12, bitCount: 1), width: 9, height: 12, dx: 1, dy: 0, shiftX: 11, shiftY: 0),
        79 :  Glyph(bitmap: Bitmap(width: 9, height: 12, bitCount: 1), width: 9, height: 12, dx: 1, dy: 0, shiftX: 11, shiftY: 0),
        80 :  Glyph(bitmap: Bitmap(width: 8, height: 12, bitCount: 1), width: 8, height: 12, dx: 1, dy: 0, shiftX: 10, shiftY: 0),
        81 :  Glyph(bitmap: Bitmap(width: 9, height: 14, bitCount: 1), width: 9, height: 14, dx: 1, dy: -2, shiftX: 11, shiftY: 0),
        82 :  Glyph(bitmap: Bitmap(width: 9, height: 12, bitCount: 1), width: 9, height: 12, dx: 1, dy: 0, shiftX: 10, shiftY: 0),
        83 :  Glyph(bitmap: Bitmap(width: 8, height: 12, bitCount: 1), width: 8, height: 12, dx: 1, dy: 0, shiftX: 10, shiftY: 0),
        84 :  Glyph(bitmap: Bitmap(width: 9, height: 12, bitCount: 1), width: 9, height: 12, dx: 0, dy: 0, shiftX: 10, shiftY: 0),
        85 :  Glyph(bitmap: Bitmap(width: 8, height: 12, bitCount: 1), width: 8, height: 12, dx: 1, dy: 0, shiftX: 10, shiftY: 0),
        86 :  Glyph(bitmap: Bitmap(width: 10, height: 12, bitCount: 1), width: 10, height: 12, dx: 0, dy: 0, shiftX: 10, shiftY: 0),
        87 :  Glyph(bitmap: Bitmap(width: 14, height: 12, bitCount: 1), width: 14, height: 12, dx: 0, dy: 0, shiftX: 14, shiftY: 0),
        88 :  Glyph(bitmap: Bitmap(width: 10, height: 12, bitCount: 1), width: 10, height: 12, dx: 0, dy: 0, shiftX: 10, shiftY: 0),
        89 :  Glyph(bitmap: Bitmap(width: 9, height: 12, bitCount: 1), width: 9, height: 12, dx: 0, dy: 0, shiftX: 10, shiftY: 0),
        90 :  Glyph(bitmap: Bitmap(width: 8, height: 12, bitCount: 1), width: 8, height: 12, dx: 1, dy: 0, shiftX: 10, shiftY: 0),
        91 :  Glyph(bitmap: Bitmap(width: 3, height: 15, bitCount: 1), width: 3, height: 15, dx: 1, dy: -2, shiftX: 4, shiftY: 0),
        92 :  Glyph(bitmap: Bitmap(width: 6, height: 13, bitCount: 1), width: 6, height: 13, dx: 0, dy: -1, shiftX: 7, shiftY: 0),
        93 :  Glyph(bitmap: Bitmap(width: 3, height: 15, bitCount: 1), width: 3, height: 15, dx: 0, dy: -2, shiftX: 4, shiftY: 0),
        94 :  Glyph(bitmap: Bitmap(width: 5, height: 6, bitCount: 1), width: 5, height: 6, dx: 1, dy: 6, shiftX: 7, shiftY: 0),
        95 :  Glyph(bitmap: Bitmap(width: 7, height: 1, bitCount: 1), width: 7, height: 1, dx: 0, dy: -1, shiftX: 7, shiftY: 0),
        96 :  Glyph(bitmap: Bitmap(width: 4, height: 2, bitCount: 1), width: 4, height: 2, dx: 0, dy: 10, shiftX: 5, shiftY: 0),
        97 :  Glyph(bitmap: Bitmap(width: 7, height: 9, bitCount: 1), width: 7, height: 9, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        98 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        99 :  Glyph(bitmap: Bitmap(width: 7, height: 9, bitCount: 1), width: 7, height: 9, dx: 1, dy: 0, shiftX: 8, shiftY: 0),
        100 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        101 :  Glyph(bitmap: Bitmap(width: 8, height: 9, bitCount: 1), width: 8, height: 9, dx: 0, dy: 0, shiftX: 8, shiftY: 0),
        102 :  Glyph(bitmap: Bitmap(width: 5, height: 12, bitCount: 1), width: 5, height: 12, dx: 1, dy: 0, shiftX: 6, shiftY: 0),
        103 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: -3, shiftX: 9, shiftY: 0),
        104 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        105 :  Glyph(bitmap: Bitmap(width: 2, height: 12, bitCount: 1), width: 2, height: 12, dx: 1, dy: 0, shiftX: 4, shiftY: 0),
        106 :  Glyph(bitmap: Bitmap(width: 3, height: 15, bitCount: 1), width: 3, height: 15, dx: 0, dy: -3, shiftX: 4, shiftY: 0),
        107 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: 0, shiftX: 8, shiftY: 0),
        108 :  Glyph(bitmap: Bitmap(width: 2, height: 12, bitCount: 1), width: 2, height: 12, dx: 1, dy: 0, shiftX: 4, shiftY: 0),
        109 :  Glyph(bitmap: Bitmap(width: 12, height: 9, bitCount: 1), width: 12, height: 9, dx: 1, dy: 0, shiftX: 14, shiftY: 0),
        110 :  Glyph(bitmap: Bitmap(width: 7, height: 9, bitCount: 1), width: 7, height: 9, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        111 :  Glyph(bitmap: Bitmap(width: 7, height: 9, bitCount: 1), width: 7, height: 9, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        112 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: -3, shiftX: 9, shiftY: 0),
        113 :  Glyph(bitmap: Bitmap(width: 7, height: 12, bitCount: 1), width: 7, height: 12, dx: 1, dy: -3, shiftX: 9, shiftY: 0),
        114 :  Glyph(bitmap: Bitmap(width: 4, height: 9, bitCount: 1), width: 4, height: 9, dx: 1, dy: 0, shiftX: 5, shiftY: 0),
        115 :  Glyph(bitmap: Bitmap(width: 6, height: 9, bitCount: 1), width: 6, height: 9, dx: 1, dy: 0, shiftX: 8, shiftY: 0),
        116 :  Glyph(bitmap: Bitmap(width: 5, height: 11, bitCount: 1), width: 5, height: 11, dx: 0, dy: 0, shiftX: 5, shiftY: 0),
        117 :  Glyph(bitmap: Bitmap(width: 7, height: 9, bitCount: 1), width: 7, height: 9, dx: 1, dy: 0, shiftX: 9, shiftY: 0),
        118 :  Glyph(bitmap: Bitmap(width: 8, height: 9, bitCount: 1), width: 8, height: 9, dx: 0, dy: 0, shiftX: 8, shiftY: 0),
        119 :  Glyph(bitmap: Bitmap(width: 12, height: 9, bitCount: 1), width: 12, height: 9, dx: 0, dy: 0, shiftX: 12, shiftY: 0),
        120 :  Glyph(bitmap: Bitmap(width: 8, height: 9, bitCount: 1), width: 8, height: 9, dx: 0, dy: 0, shiftX: 8, shiftY: 0),
        121 :  Glyph(bitmap: Bitmap(width: 8, height: 12, bitCount: 1), width: 8, height: 12, dx: 0, dy: -3, shiftX: 8, shiftY: 0),
        122 :  Glyph(bitmap: Bitmap(width: 6, height: 9, bitCount: 1), width: 6, height: 9, dx: 1, dy: 0, shiftX: 8, shiftY: 0),
        123 :  Glyph(bitmap: Bitmap(width: 5, height: 15, bitCount: 1), width: 5, height: 15, dx: 0, dy: -3, shiftX: 5, shiftY: 0),
        124 :  Glyph(bitmap: Bitmap(width: 2, height: 14, bitCount: 1), width: 2, height: 14, dx: 1, dy: -2, shiftX: 4, shiftY: 0),
        125 :  Glyph(bitmap: Bitmap(width: 5, height: 15, bitCount: 1), width: 5, height: 15, dx: 0, dy: -3, shiftX: 5, shiftY: 0),
        126 :  Glyph(bitmap: Bitmap(width: 9, height: 3, bitCount: 1), width: 9, height: 3, dx: 1, dy: 3, shiftX: 11, shiftY: 0)
    ]

    static let bitmapData: [UInt16: [UInt32]] = [
        0 : [0],
        2 : [0],
        13 : [0],
        32 : [0],
        33 : [3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 0, 0, 3221225472, 3221225472],
        34 : [2684354560, 2684354560, 2684354560, 2684354560],
        35 : [452984832, 301989888, 301989888, 2139095040, 838860800, 637534208, 603979776, 4278190080, 603979776, 603979776, 1677721600, 1275068416],
        36 : [268435456, 268435456, 1006632960, 1174405120, 3321888768, 3254779904, 1073741824, 1879048192, 469762048, 100663296, 33554432, 2181038080, 3321888768, 2080374784, 268435456],
        37 : [1879048192, 2432696320, 2449473536, 2449473536, 1946157056, 67108864, 134217728, 461373440, 373293056, 608174080, 641728512, 58720256],
        38 : [939524096, 1677721600, 1140850688, 1140850688, 2013265920, 805306368, 2030043136, 3372220416, 2365587456, 2264924160, 3338665984, 2105540608],
        39 : [2147483648, 2147483648, 2147483648, 2147483648],
        40 : [268435456, 805306368, 536870912, 1073741824, 1073741824, 3221225472, 3221225472, 3221225472, 2147483648, 3221225472, 3221225472, 3221225472, 1073741824, 1073741824, 536870912, 805306368, 268435456],
        41 : [2147483648, 1073741824, 536870912, 536870912, 805306368, 268435456, 268435456, 268435456, 268435456, 268435456, 268435456, 268435456, 805306368, 536870912, 536870912, 1073741824, 2147483648],
        42 : [268435456, 268435456, 4261412864, 268435456, 671088640, 1275068416],
        43 : [268435456, 268435456, 268435456, 4261412864, 268435456, 268435456, 268435456, 268435456],
        44 : [1073741824, 1073741824, 1073741824, 3221225472],
        45 : [4026531840],
        46 : [3221225472, 3221225472],
        47 : [67108864, 201326592, 134217728, 134217728, 268435456, 268435456, 268435456, 536870912, 536870912, 1610612736, 1073741824, 1073741824, 3221225472],
        48 : [939524096, 1140850688, 3321888768, 2181038080, 2181038080, 2181038080, 2181038080, 2181038080, 2181038080, 3321888768, 1140850688, 939524096],
        49 : [402653184, 2013265920, 3623878656, 402653184, 402653184, 402653184, 402653184, 402653184, 402653184, 402653184, 402653184, 402653184],
        50 : [2013265920, 3288334336, 2248146944, 2248146944, 100663296, 67108864, 201326592, 402653184, 805306368, 1610612736, 3221225472, 4261412864],
        51 : [2013265920, 3288334336, 2248146944, 100663296, 67108864, 939524096, 67108864, 100663296, 100663296, 2248146944, 3288334336, 2013265920],
        52 : [100663296, 100663296, 167772160, 436207616, 301989888, 838860800, 570425344, 1107296256, 4286578688, 33554432, 33554432, 33554432],
        53 : [2113929216, 1073741824, 1073741824, 1073741824, 2080374784, 1174405120, 33554432, 33554432, 33554432, 3254779904, 1174405120, 1006632960],
        54 : [469762048, 536870912, 1073741824, 3221225472, 4227858432, 3321888768, 3254779904, 2181038080, 3254779904, 3254779904, 1711276032, 1006632960],
        55 : [4261412864, 33554432, 100663296, 67108864, 201326592, 134217728, 402653184, 268435456, 268435456, 805306368, 536870912, 1610612736],
        56 : [2013265920, 1140850688, 3321888768, 3321888768, 1140850688, 939524096, 1140850688, 2181038080, 2181038080, 2181038080, 3321888768, 2080374784],
        57 : [2013265920, 3422552064, 2248146944, 2248146944, 2248146944, 2248146944, 3321888768, 2113929216, 100663296, 67108864, 201326592, 1879048192],
        58 : [3221225472, 3221225472, 0, 0, 0, 0, 0, 3221225472, 3221225472],
        59 : [1610612736, 1610612736, 0, 0, 0, 0, 0, 1610612736, 1073741824, 1073741824, 3221225472],
        60 : [67108864, 469762048, 1879048192, 2147483648, 1879048192, 469762048, 67108864],
        61 : [4261412864, 0, 0, 4261412864],
        62 : [2147483648, 3758096384, 469762048, 100663296, 469762048, 3758096384, 2147483648],
        63 : [2013265920, 3422552064, 2348810240, 201326592, 201326592, 402653184, 805306368, 536870912, 0, 0, 536870912, 536870912],
        64 : [260046848, 811597824, 1613758464, 1192230912, 3431989248, 2290614272, 2559049728, 2575826944, 2576351232, 2576351232, 3470786560, 1073741824, 813694976, 520093696],
        65 : [201326592, 201326592, 503316480, 503316480, 301989888, 855638016, 855638016, 553648128, 2139095040, 1082130432, 1082130432, 3233808384],
        66 : [4227858432, 3254779904, 3271557120, 3271557120, 3254779904, 4227858432, 3271557120, 3271557120, 3238002688, 3271557120, 3271557120, 4227858432],
        67 : [1040187392, 1660944384, 1090519040, 3246391296, 2147483648, 2147483648, 2147483648, 2147483648, 3246391296, 1090519040, 1660944384, 1040187392],
        68 : [4227858432, 3321888768, 3271557120, 3238002688, 3238002688, 3246391296, 3246391296, 3238002688, 3238002688, 3271557120, 3321888768, 4227858432],
        69 : [4261412864, 3221225472, 3221225472, 3221225472, 3221225472, 4261412864, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 4278190080],
        70 : [4261412864, 3221225472, 3221225472, 3221225472, 3221225472, 4261412864, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472],
        71 : [1040187392, 1660944384, 1090519040, 3246391296, 3221225472, 2147483648, 2273312768, 3246391296, 3246391296, 1098907648, 1635778560, 503316480],
        72 : [3229614080, 3229614080, 3229614080, 3229614080, 3229614080, 3229614080, 4286578688, 3229614080, 3229614080, 3229614080, 3229614080, 3229614080],
        73 : [3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472],
        74 : [50331648, 50331648, 50331648, 50331648, 50331648, 50331648, 50331648, 50331648, 50331648, 3254779904, 1711276032, 1006632960],
        75 : [3279945728, 3254779904, 3321888768, 3422552064, 3623878656, 4026531840, 3892314112, 3422552064, 3321888768, 3254779904, 3271557120, 3246391296],
        76 : [3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 4261412864],
        77 : [3224371200, 3765436416, 3765436416, 4042260480, 3501195264, 3501195264, 3652190208, 3375366144, 3408920576, 3476029440, 3325034496, 3325034496],
        78 : [3246391296, 3246391296, 3783262208, 4051697664, 3514826752, 3649044480, 3447717888, 3447717888, 3347054592, 3279945728, 3279945728, 3246391296],
        79 : [1040187392, 1660944384, 1090519040, 3246391296, 2155872256, 2155872256, 2155872256, 2155872256, 3246391296, 1090519040, 1660944384, 1040187392],
        80 : [4261412864, 3271557120, 3238002688, 3238002688, 3238002688, 3271557120, 4261412864, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472],
        81 : [1040187392, 1660944384, 1090519040, 3246391296, 2172649472, 2155872256, 2155872256, 2172649472, 3246391296, 3238002688, 1660944384, 1040187392, 58720256, 16777216],
        82 : [4261412864, 3271557120, 3271557120, 3238002688, 3271557120, 3271557120, 4227858432, 3288334336, 3321888768, 3254779904, 3271557120, 3246391296],
        83 : [1006632960, 1107296256, 3271557120, 3221225472, 1073741824, 1879048192, 469762048, 50331648, 16777216, 3238002688, 1124073472, 1040187392],
        84 : [4286578688, 201326592, 201326592, 201326592, 201326592, 201326592, 201326592, 201326592, 201326592, 201326592, 201326592, 201326592],
        85 : [2164260864, 2164260864, 2164260864, 2164260864, 2164260864, 2164260864, 2164260864, 2164260864, 2164260864, 3271557120, 1107296256, 1006632960],
        86 : [3233808384, 1082130432, 1635778560, 1635778560, 553648128, 855638016, 855638016, 301989888, 503316480, 503316480, 201326592, 201326592],
        87 : [3272343552, 1124859904, 1661468672, 1669857280, 647495680, 613941248, 617611264, 877658112, 1011875840, 409993216, 408944640, 404750336],
        88 : [1639972864, 1635778560, 855638016, 301989888, 503316480, 201326592, 201326592, 503316480, 301989888, 855638016, 1635778560, 3770679296],
        89 : [3229614080, 1635778560, 1627389952, 855638016, 838860800, 503316480, 201326592, 201326592, 201326592, 201326592, 201326592, 201326592],
        90 : [4278190080, 33554432, 100663296, 201326592, 134217728, 402653184, 268435456, 805306368, 1610612736, 1073741824, 3221225472, 4278190080],
        91 : [3758096384, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3758096384],
        92 : [3221225472, 1073741824, 1610612736, 536870912, 536870912, 805306368, 268435456, 268435456, 402653184, 134217728, 201326592, 67108864, 67108864],
        93 : [3758096384, 536870912, 536870912, 536870912, 536870912, 536870912, 536870912, 536870912, 536870912, 536870912, 536870912, 536870912, 536870912, 536870912, 3758096384],
        94 : [536870912, 1879048192, 1342177280, 1342177280, 3623878656, 2281701376],
        95 : [4261412864],
        96 : [3758096384, 805306368],
        97 : [939524096, 1140850688, 3321888768, 100663296, 2113929216, 3321888768, 2248146944, 3321888768, 2113929216],
        98 : [3221225472, 3221225472, 3221225472, 4227858432, 3321888768, 3254779904, 3254779904, 3254779904, 3254779904, 3254779904, 3321888768, 3154116608],
        99 : [2013265920, 3288334336, 2248146944, 2147483648, 2147483648, 2147483648, 2248146944, 3288334336, 2013265920],
        100 : [100663296, 100663296, 100663296, 2113929216, 3321888768, 2248146944, 2248146944, 2248146944, 2248146944, 2248146944, 3321888768, 2046820352],
        101 : [1006632960, 1711276032, 1107296256, 1124073472, 4278190080, 1073741824, 1073741824, 1660944384, 1006632960],
        102 : [939524096, 1610612736, 1610612736, 4026531840, 1610612736, 1610612736, 1610612736, 1610612736, 1610612736, 1610612736, 1610612736, 1610612736],
        103 : [2046820352, 3321888768, 3321888768, 2248146944, 2248146944, 2248146944, 2248146944, 3321888768, 2113929216, 100663296, 3288334336, 2013265920],
        104 : [3221225472, 3221225472, 3221225472, 4227858432, 3321888768, 3321888768, 3321888768, 3321888768, 3321888768, 3321888768, 3321888768, 3321888768],
        105 : [3221225472, 3221225472, 0, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472],
        106 : [1610612736, 1610612736, 0, 1610612736, 1610612736, 1610612736, 1610612736, 1610612736, 1610612736, 1610612736, 1610612736, 1610612736, 1610612736, 1610612736, 3221225472],
        107 : [3221225472, 3221225472, 3221225472, 3321888768, 3355443200, 3623878656, 4026531840, 4026531840, 3623878656, 3355443200, 3422552064, 3321888768],
        108 : [3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472],
        109 : [3185573888, 3325034496, 3325034496, 3325034496, 3325034496, 3325034496, 3325034496, 3325034496, 3325034496],
        110 : [4227858432, 3321888768, 3321888768, 3321888768, 3321888768, 3321888768, 3321888768, 3321888768, 3321888768],
        111 : [939524096, 1140850688, 2181038080, 2181038080, 2181038080, 2181038080, 2181038080, 1174405120, 939524096],
        112 : [3154116608, 3321888768, 3321888768, 3254779904, 3254779904, 3254779904, 3321888768, 3321888768, 4227858432, 3221225472, 3221225472, 3221225472],
        113 : [2113929216, 3321888768, 2248146944, 2248146944, 2248146944, 2248146944, 2248146944, 3321888768, 2113929216, 100663296, 100663296, 100663296],
        114 : [2952790016, 3221225472, 2147483648, 2147483648, 2147483648, 2147483648, 2147483648, 2147483648, 2147483648],
        115 : [2013265920, 3422552064, 2214592512, 3221225472, 2013265920, 201326592, 2214592512, 3288334336, 2013265920],
        116 : [1610612736, 1610612736, 4160749568, 1610612736, 1610612736, 1610612736, 1610612736, 1610612736, 1610612736, 536870912, 939524096],
        117 : [3321888768, 3321888768, 3321888768, 3321888768, 3321888768, 3321888768, 3321888768, 3321888768, 2113929216],
        118 : [3271557120, 1107296256, 1711276032, 603979776, 603979776, 1006632960, 402653184, 402653184, 402653184],
        119 : [3325034496, 1176502272, 1176502272, 1868562432, 692060160, 692060160, 960495616, 817889280, 276824064],
        120 : [3271557120, 1711276032, 738197504, 402653184, 402653184, 402653184, 738197504, 1711276032, 3271557120],
        121 : [3271557120, 1107296256, 1711276032, 603979776, 603979776, 1006632960, 402653184, 402653184, 402653184, 268435456, 268435456, 1610612736],
        122 : [4227858432, 201326592, 402653184, 268435456, 805306368, 1610612736, 1073741824, 3221225472, 4227858432],
        123 : [134217728, 268435456, 805306368, 536870912, 536870912, 536870912, 536870912, 3221225472, 536870912, 536870912, 536870912, 536870912, 805306368, 268435456, 134217728],
        124 : [3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472, 3221225472],
        125 : [2147483648, 1073741824, 1610612736, 536870912, 536870912, 536870912, 536870912, 402653184, 536870912, 536870912, 536870912, 536870912, 1610612736, 1073741824, 2147483648],
        126 : [1887436800, 3380609024, 2264924160]
    ]

}