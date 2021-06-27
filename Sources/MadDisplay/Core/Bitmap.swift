public final class Bitmap {

    let width: Int
    let height: Int

    private let bitsPerPixel: Int

    private let uint32Bytes: Int
    private let alignBits: Int
    private let rowStride: Int

    private let xShift: Int

    private let xMask: UInt32
    private let bitMask: UInt32

    private let bitmapArea: Area
    private var dirtyArea: Area?

    private var readOnly: Bool = false

    public var data: [UInt32]

    public init(width: Int, height: Int, bitCount: Int) {
        guard width > 0 && height > 0 else {
            fatalError("Bitmap width and height must greater than 0!")
        }

        guard bitCount == 1 || bitCount == 2 || bitCount == 4 || bitCount == 8 || bitCount == 16 || bitCount == 32 else {
            fatalError("Invalid bitCount per pixel: \(bitCount)")
        }

        self.width = width
        self.height = height
        self.bitsPerPixel = bitCount

        uint32Bytes = MemoryLayout<UInt32>.size
        alignBits = 8 * uint32Bytes

        let rowBits = width * bitsPerPixel
        if rowBits % alignBits != 0 {
            rowStride = rowBits / alignBits + 1
        } else {
            rowStride = rowBits / alignBits
        }

        data = [UInt32](repeating: 0, count: rowStride * height)

        var _xShift = 0
        var powerOfTwo = 1
        while powerOfTwo < alignBits / bitsPerPixel {
            _xShift += 1
            powerOfTwo <<= 1
        }

        xShift = _xShift
        xMask = (UInt32(1) << xShift) &- 1
        bitMask = (UInt32(1) << bitsPerPixel) &- 1

        bitmapArea = Area(x1: 0, y1: 0, width: width, height: height)
        dirtyArea = bitmapArea
    }
}


extension Bitmap {

    func getPixel(x: Int, y: Int) -> UInt32 {
        if x < 0 || x >= width || y < 0 || y >= height {
            return 0
        }
        let rowStart = y * rowStride

        if bitsPerPixel < 8 {
            let word = data[rowStart + (x >> xShift)]
            let shift = alignBits - Int(UInt32(x) & xMask + 1) * bitsPerPixel
            return (word >> shift) & bitMask
        } else {
            let byteOffset = rowStart * uint32Bytes
            return data.withUnsafeBytes { pixelPtr in
                let word: UInt32
                if bitsPerPixel == 8 {
                    word = UInt32(pixelPtr.load(fromByteOffset: byteOffset + x, as: UInt8.self))
                } else if bitsPerPixel == 16 {
                    word = UInt32(pixelPtr.load(fromByteOffset: byteOffset + x * 2, as: UInt16.self))
                } else {
                    word = UInt32(pixelPtr.load(fromByteOffset: byteOffset + x * 4, as: UInt32.self))
                }
                return word
            }
        }
    }
}

extension Bitmap {

    func setDirtyArea(_ newArea: Area) {
        if let oldArea = dirtyArea {
            dirtyArea = oldArea.union(newArea)
        } else {
            dirtyArea = newArea
        }
        dirtyArea = dirtyArea?.intersection(bitmapArea)
    }

    func getRefreshArea() -> Area? {
        return dirtyArea
    }

    func fill(_ value: UInt32) {
        guard !readOnly else {
            return
        }

        setDirtyArea(bitmapArea)

        var word: UInt32 = 0
        
        for i in 0..<(32 / bitsPerPixel) {
            word |= (value & bitMask) << (alignBits - ((i + 1) * bitsPerPixel))
        } 

        for i in 0..<(rowStride * height) {
            data[i] = word
        }
    }

    func memoryCopy(_ value: [UInt32]) {
        guard !readOnly && value.count == data.count else {
            print("Bitmap data length not equal to source array!!!")
            return
        }

        setDirtyArea(bitmapArea)

        data = value
    }

    func MSBMemoryCopy(_ value: [UInt32]) {
        guard !readOnly && value.count == data.count else {
            print("Bitmap data length not equal to source array!!!")
            return
        }

        setDirtyArea(bitmapArea)

        data = value.map {
            $0.byteSwapped
        }
    }

    public func finishRefresh() {
        dirtyArea = nil
    }

    public func setPixel(x: Int, y: Int, _ value: UInt32) {
        guard !readOnly else {
            return
        }

        setDirtyArea(Area(x1: x, y1: y, x2: x, y2: y))

        let rowStart = y * rowStride
        if bitsPerPixel < 8 {
            let bitPosition = alignBits - Int((UInt32(x) & xMask) + 1) * bitsPerPixel
            let index = rowStart + (x >> xShift)
            var word = data[index]
            word &= ~(bitMask << bitPosition)
            word |= (value & bitMask) << bitPosition
            data[index] = word
        } else {
            let byteOffset = rowStart * uint32Bytes
            data.withUnsafeMutableBytes { pixelPtr in
                if bitsPerPixel == 8 {
                    pixelPtr.storeBytes(of: UInt8(value & bitMask), toByteOffset: byteOffset + x, as: UInt8.self)
                } else if bitsPerPixel == 16 {
                    pixelPtr.storeBytes(of: UInt16(value & bitMask), toByteOffset: byteOffset + x * 2, as: UInt16.self)
                } else {
                    pixelPtr.storeBytes(of: UInt32(value), toByteOffset: byteOffset + x * 4, as: UInt32.self)
                }
            }
        }
    }

    subscript(x: Int, y: Int) -> UInt32 {
        get {
            getPixel(x: x, y: y)
        }
        set {
            setPixel(x: x, y: y, newValue)
        }
    }
}