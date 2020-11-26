import SwiftIO

public final class PCFFont: Font {
    struct TocEntry {
        let format: UInt32
        let size: Int32
        let offset: Int32
    }

    enum TableType: UInt32 {
        case properties         = 0b1
        case accelerators       = 0b10
        case metrics            = 0b100
        case bitmaps            = 0b1000
        case intMetrics         = 0b10000
        case bdfEncodings       = 0b100000
        case swidths            = 0b1000000
        case glyphNames         = 0b10000000
        case bdfAccelerators    = 0b100000000
    }

    struct Format: OptionSet {
        let rawValue: UInt32
        
        static let defaultFormat  = Format(rawValue: 0x0000_0000)
        static let inkbounds      = Format(rawValue: 0x0000_0200)
        static let acclWInkbounds = Format(rawValue: 0x0000_0100)
        static let commpressedMetrics = Format(rawValue: 0x0000_0100)

        static let glyphPadMask   = Format(rawValue: 3 << 0)
        static let byteMask       = Format(rawValue: 1 << 2)
        static let bitMask        = Format(rawValue: 1 << 3)
        static let scanUnitMask   = Format(rawValue: 3 << 4)
    }


    struct MetricsData {
        var leftBearing: UInt8 = 0
        var rightBearing: UInt8 = 0
        var charWidth: UInt8 = 0
        var charAscent: UInt8 = 0
        var charDescent: UInt8 = 0
    }

    struct UncompressedMetricsData {
        var leftBearing: Int16 = 0
        var rightBearing: Int16 = 0
        var charWidth: Int16 = 0
        var charAscent: Int16 = 0
        var charDescent: Int16 = 0
        var charAttr: UInt16 = 0
    }

    struct EncodingTableHead {
        var format: UInt32 = 0
        var minByte2: UInt16 = 0
        var maxByte2: UInt16 = 0
        var minByte1: UInt16 = 0
        var maxByte1: UInt16 = 0
        var defaultChar: UInt16 = 0
    }

    struct MetricsTableHead {
        var format: UInt32 = 0
        var metricsCount: UInt16 = 0
    }

    struct BitmapTableHead {
        var format: UInt32 = 0
        var glyphCount: Int32 = 0
    }

    let file: FileDescriptor
    let header = UInt32(0x70636601)

    var tables = [TableType: TocEntry]()
    public var glyphCache = [UInt16: Glyph]()


    var encodingTableHead = EncodingTableHead()
    var msbEncoding = false
    var encodingDataOffset: Int = 0

    var metricsTableHead = MetricsTableHead()
    var metricsDataOffset: Int = 0

    var bitmapTableHead = BitmapTableHead()
    var msbBitmapOffset = false
    var bitmapIndexOffset: Int = 0
    var bitmapDataOffset: Int = 0

    public var fontHeight: Int = 0

    public var maxCharAscent: Int = 0
    public var maxCharDescent: Int = 0

    public init(path: String) {
        file = FileDescriptor.open(path)

        var _header = UInt32(0)
        _ = withUnsafeMutableBytes(of: &_header) { buffer in
            file.read(fromAbsoluteOffest: 0, into: buffer)
        }

        if _header != header {
            fatalError("Not PCF file!")
        }

        var tableCount = Int32(0)
        _ = withUnsafeMutableBytes(of: &tableCount) { buffer in
            file.read(into: buffer)
        }


        var rawTables = [(type: UInt32, format: UInt32, size: Int32, offset: Int32)](repeating: (0, 0, 0, 0), count: Int(tableCount))
        rawTables.withUnsafeMutableBytes { buffer in
            file.read(into: buffer)
        }

        for rawTable in rawTables {
            let type = TableType(rawValue: rawTable.type)!
            let tocEntry = TocEntry(format: rawTable.format,
                                    size: rawTable.size,
                                    offset: rawTable.offset)
            tables[type] = tocEntry

            //print(type)
            //print(tocEntry)
            //print(" ")
        }
        updateEncodingInfo()
        updateMetricsInfo()
        updateBitmapInfo()
        updateFontInfo() 


        //print("encoding info:")
        //print(encodingTableHead)
        //print(encodingDataOffset)
        //print(" ")

        //print("metrics info:")
        //print(metricsTableHead)
        //print(metricsDataOffset)
        //print(" ")

        //print("bitmap info:")
        //print(bitmapTableHead)
        //print(bitmapIndexOffset)
        //print(bitmapDataOffset)
        //print(" ")


    }

    func exchangeEndian<T>(_ value: inout T) where T: BinaryInteger {
        let temp = value
        _ = withUnsafeMutableBytes(of: &value) { dst in
            let byteCount = dst.count
            if byteCount > 1 {
                withUnsafeBytes(of: temp) { src in
                    for i in 0..<byteCount {
                        dst[i] = src[byteCount - i - 1]
                    }
                }
            }
        }
    }

    func updateEncodingInfo() {
        var msb = false
        let bdfEncodings = tables[.bdfEncodings]!
        let format = Format(rawValue: bdfEncodings.format)
        if format.contains(.byteMask) {
            msb = true
            msbEncoding = true
        }
        _ = withUnsafeMutableBytes(of: &encodingTableHead) { buffer in
            file.read(fromAbsoluteOffest: Int(bdfEncodings.offset), into: buffer)
        }
        if msb {
            exchangeEndian(&encodingTableHead.minByte2)
            exchangeEndian(&encodingTableHead.maxByte2)
            exchangeEndian(&encodingTableHead.minByte1)
            exchangeEndian(&encodingTableHead.maxByte1)
            exchangeEndian(&encodingTableHead.defaultChar)
        }

        encodingDataOffset = file.tell()
    }

    func updateMetricsInfo() {
        var msb = false
        let metrics = tables[.metrics]!
        let format = Format(rawValue: metrics.format)
        if !format.contains(.commpressedMetrics) {
            fatalError("Uncommpressed Metrics is not supported yet")
        }
        if format.contains(.byteMask) {
            msb = true
        }

        _ = withUnsafeMutableBytes(of: &metricsTableHead) { buffer in
            file.read(fromAbsoluteOffest: Int(metrics.offset), into: buffer)
        }
        if msb {
            exchangeEndian(&metricsTableHead.metricsCount)
        }

        metricsDataOffset = file.tell()
    }

    func updateBitmapInfo() {
        var msb = false
        let bitmaps = tables[.bitmaps]!
        let format = Format(rawValue: bitmaps.format)
        if format.contains(.byteMask) {
            msb = true
            msbBitmapOffset = true
        }

        _ = withUnsafeMutableBytes(of: &bitmapTableHead) { buffer in
            file.read(fromAbsoluteOffest: Int(bitmaps.offset), into: buffer)
        }
        if msb {
            exchangeEndian(&bitmapTableHead.glyphCount)
        }

        bitmapIndexOffset = file.tell()
        bitmapDataOffset = bitmapIndexOffset + Int(bitmapTableHead.glyphCount) * 4 + 4 * 4
    }

    func updateFontInfo() {
        var msb = false
        let bdfAccel = tables[.bdfAccelerators]!
        let format = Format(rawValue: bdfAccel.format)
        if format.contains(.byteMask) {
            msb = true
        }

        var maxBounds = UncompressedMetricsData()
        _ = withUnsafeMutableBytes(of: &maxBounds) { buffer in
            file.read(fromAbsoluteOffest: Int(bdfAccel.offset + 24) + MemoryLayout<UncompressedMetricsData>.size, into: buffer)
        }
        if msb {
            exchangeEndian(&maxBounds.leftBearing)
            exchangeEndian(&maxBounds.rightBearing)
            exchangeEndian(&maxBounds.charWidth)
            exchangeEndian(&maxBounds.charAscent)
            exchangeEndian(&maxBounds.charDescent)
            exchangeEndian(&maxBounds.charAttr)
        }
        print(maxBounds)

        maxCharAscent = Int(maxBounds.charAscent)
        maxCharDescent = Int(maxBounds.charDescent)
        fontHeight = maxCharAscent + maxCharDescent
    }

    func getGlyphIndex(_ encoding: UInt16) -> Int {
        let enc1 = encoding >> 8
        let enc2 = encoding & 0xFF

        if enc1 < encodingTableHead.minByte1 || enc2 < encodingTableHead.minByte2 {
            return 0xFFFF
        }

        let index = (enc1 - encodingTableHead.minByte1) *
                    (encodingTableHead.maxByte2 - encodingTableHead.minByte2 + 1) +
                    enc2 - encodingTableHead.minByte2

        var value = UInt16(0)
        _ = withUnsafeMutableBytes(of: &value) { buffer in
            file.read(fromAbsoluteOffest: encodingDataOffset + Int(index) * MemoryLayout<UInt16>.size, into: buffer)
        }

        if msbEncoding {
            exchangeEndian(&value)
        }

        return Int(value)
    }

    func getBitmapDataPos(_ index: Int) -> Int {
        var offset = Int32(0)

        _ = withUnsafeMutableBytes(of: &offset) { buffer in
            file.read(fromAbsoluteOffest: bitmapIndexOffset + Int(index) * MemoryLayout<Int32>.size, into: buffer)
        }

        if msbBitmapOffset {
            exchangeEndian(&offset)
        }

        return Int(offset) + bitmapDataOffset
    }

    func _getGlyph(_ index: Int) -> Glyph {
        var data = MetricsData()
        //print("index = \(index)")
        //print("offset = \(metricsDataOffset + Int(index) * MemoryLayout<MetricsData>.size)")
        _ = withUnsafeMutableBytes(of: &data) { buffer in
            file.read(fromAbsoluteOffest: metricsDataOffset + Int(index) * MemoryLayout<MetricsData>.size, into: buffer)
        }

        let leftBearing = Int(data.leftBearing) - 0x80
        let rightBearing = Int(data.rightBearing) - 0x80
        let charWidth = Int(data.charWidth) - 0x80
        let charAscent = Int(data.charAscent) - 0x80
        let charDescent = Int(data.charDescent) - 0x80

        //print("rightBearing = \(rightBearing)")
        //print("leftBearing = \(leftBearing)")
        //print("charWidth = \(charWidth)")
        //print("charAscent = \(charAscent)")
        //print("charDescent = \(charDescent)")

        let width = rightBearing - leftBearing
        let height = charAscent + charDescent
        let dx = leftBearing
        let dy = -charDescent
        let shiftX = charWidth
        let shiftY = 0
        var glyph: Glyph


        if width > 0 && height > 0 {
            let bitmap = Bitmap(width: width, height: height, bitCount: 1)
            var bitmapData = [UInt32](repeating: 0, count: bitmap.data.count)

            let bitmapOffset = getBitmapDataPos(index)
            //print("bitmapOffset = \(bitmapOffset)")
            bitmapData.withUnsafeMutableBytes { buffer in
                file.read(fromAbsoluteOffest: bitmapOffset, into: buffer)
            }

            bitmap.MSBMemoryCopy(bitmapData)

            glyph = Glyph(bitmap: bitmap,
                            width: width,
                            height: height,
                            dx: dx,
                            dy: dy,
                            shiftX: shiftX,
                            shiftY: shiftY)
        } else {
            glyph = Glyph(
                            width: width,
                            height: height,
                            dx: dx,
                            dy: dy,
                            shiftX: shiftX,
                            shiftY: shiftY)
        }
        //print("Bitmap(width: \(width), height: \(height), bitCount: 1)")

        return glyph
    }

    public func getGlyph(_ encoding: UInt16) -> Glyph {

        if let glyph = glyphCache[encoding] {
            return glyph
        } 

        var index = getGlyphIndex(encoding)
        //print("index = \(index)")
        if index == 0xFFFF {
            index = getGlyphIndex(0x003F)
        }

        let glyph = _getGlyph(index)
        glyphCache[encoding] = glyph
        return glyph
    }

    public func printASCIIGlyphs() {
        for encoding in 0...UInt16(128) {
            let index = getGlyphIndex(encoding)
            if index == 0xFFFF {
                continue
            }
            let glyph = _getGlyph(index)
            print(encoding)
            //print(glyph)
            //print("Bitmap(width: \(glyph.bitmap!.width), height: \(glyph.bitmap!.height), bitCount: 1)")
            //print(glyph.bitmap!.data)
        }

        for encoding in 0...UInt16(128) {
            let index = getGlyphIndex(encoding)
            if index == 0xFFFF {
                continue
            }
            let glyph = _getGlyph(index)
            //print(encoding)
            print(glyph)
            //print("Bitmap(width: \(glyph.bitmap!.width), height: \(glyph.bitmap!.height), bitCount: 1)")
            //print(glyph.bitmap!.data)
        }

        for encoding in 0...UInt16(128) {
            let index = getGlyphIndex(encoding)
            if index == 0xFFFF {
                continue
            }
            let glyph = _getGlyph(index)
            //print(encoding)
            //print(glyph)
            print("Bitmap(width: \(glyph.bitmap!.width), height: \(glyph.bitmap!.height), bitCount: 1)")
            //print(glyph.bitmap!.data)
        }

        for encoding in 0...UInt16(128) {
            let index = getGlyphIndex(encoding)
            if index == 0xFFFF {
                continue
            }
            let glyph = _getGlyph(index)
            //print(encoding)
            //print(glyph)
            //print("Bitmap(width: \(glyph.bitmap!.width), height: \(glyph.bitmap!.height), bitCount: 1)")
            print(glyph.bitmap!.data)
        }

    }

}
