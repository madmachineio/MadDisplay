public final class Bitmap {

    let width: Int
    let height: Int

    let bitsPerPixel: Int
    let bytesPerPixel: Int
    let rowStride: Int
    let alignBits: Int
    let uintSize: Int

    let xShift: Int

    let xMask: UInt32
    let bitMask: UInt32

    var dirtyArea: Area!

    var data: [UInt32]
    var readOnly: Bool = false

    public init(width: Int, height: Int, bitCount: Int) {
        guard bitCount == 1 || bitCount == 2 || bitCount == 4 || bitCount == 8 || bitCount == 16 || bitCount == 32 else {
            fatalError("Invalid bitCount per pixel: \(bitCount)")
        }

        self.width = width
        self.height = height
        bitsPerPixel = bitCount
        bytesPerPixel = bitsPerPixel / 8

        let rowBits = width * bitsPerPixel
        uintSize = MemoryLayout<UInt32>.size
        alignBits = 8 * uintSize

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
        xMask = (1 << xShift) &- 1
        bitMask = (1 << bitsPerPixel) &- 1

        //print("rowBits = \(rowBits)")
        //print("rowStride = \(rowStride)")
        //print("xShift = \(xShift)")
        //print("xMask = \(xMask)")
        //print("bitMask = \(bitMask)")

        dirtyArea = Area(x1: 0, y1: 0, width: width, height: height)
        //refreshAreas = [dirtyArea]
    }
}


extension Bitmap {

    func getPixel(x: Int, y: Int) -> UInt32 {
        if x < 0 || x >= width || y < 0 || y >= height {
            return 0
        }
        let rowStart = y * rowStride

        if bytesPerPixel < 1 {
            let value = data[rowStart + (x >> xShift)]
            let shift = alignBits - Int(UInt32(x) & xMask + 1) * bitsPerPixel
            /*if x == 0 && y == 0 {
                print("value = \(value)")
                print("shift = \(shift)")
                print("bitMask = \(bitMask)")
            }*/
            return (value >> shift) & bitMask
        } else {
            let offset = rowStart * uintSize
            return data.withUnsafeBytes { pixelPtr in
                var value: UInt32
                if bytesPerPixel == 1 {
                    value = UInt32(pixelPtr.load(fromByteOffset: offset + x, as: UInt8.self))
                } else if bytesPerPixel == 2 {
                    value = UInt32(pixelPtr.load(fromByteOffset: offset + x * 2, as: UInt16.self))
                } else {
                    value = UInt32(pixelPtr.load(fromByteOffset: offset + x * 4, as: UInt32.self))
                }
                return value
            }
        }
    }
}

extension Bitmap {

    /*func getRefreshAreas(_ tail: Area?) -> Area? {
        if dirtyArea.x1 == dirtyArea.x2 {
            return tail
        }

        dirtyArea.next = tail

        return dirtyArea
    }*/

    func getRefreshAreas(_ tail: Area?) -> Area? {
        if dirtyArea == nil {
            return tail
        }

        dirtyArea.next = tail
        return dirtyArea
    }

    func fill(_ value: UInt32) {
        guard !readOnly else {
            return
        }

        if dirtyArea == nil {
            dirtyArea = Area(x1: 0, y1: 0, width: width, height: height)
        } else {
            dirtyArea.x1 = 0
            dirtyArea.x2 = width - 1
            dirtyArea.y1 = 0
            dirtyArea.y2 = height - 1
        }


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
            return
        }

        if dirtyArea == nil {
            dirtyArea = Area(x1: 0, y1: 0, width: width, height: height)
        } else {
            dirtyArea.x1 = 0
            dirtyArea.x2 = width - 1
            dirtyArea.y1 = 0
            dirtyArea.y2 = height - 1
        }

        data = value
    }

    func MSBMemoryCopy(_ value: [UInt32]) {
        guard !readOnly && value.count == data.count else {
            print("Bitmap data length not equal to source array!!!")
            return
        }

        if dirtyArea == nil {
            dirtyArea = Area(x1: 0, y1: 0, width: width, height: height)
        } else {
            dirtyArea.x1 = 0
            dirtyArea.x2 = width - 1
            dirtyArea.y1 = 0
            dirtyArea.y2 = height - 1
        }

        let count = data.count
        data.withUnsafeMutableBytes { dest in
            value.withUnsafeBytes { src in
                for i in 0..<count {
                    let index = i * 4
                    dest[index] = src[index + 3]
                    dest[index + 1] = src[index + 2]
                    dest[index + 2] = src[index + 1]
                    dest[index + 3] = src[index]
                }
            }
        }
    }

    func finishRefresh() {
        dirtyArea = nil
    }

    func setPixel(x: Int, y: Int, _ value: UInt32) {
        guard !readOnly else {
            return
        }

        if dirtyArea == nil {
            dirtyArea = Area(x1: x, y1: y, x2: x, y2: y)
        } else {
            if x < dirtyArea.x1 {
                dirtyArea.x1 = x
            } else if x >= dirtyArea.x2 {
                dirtyArea.x2 = x
            }

            if y < dirtyArea.y1 {
                dirtyArea.y1 = y
            } else if y >= dirtyArea.y2 {
                dirtyArea.y2 = y
            }
        }

        let rowStart = y * rowStride
        if bytesPerPixel < 1 {
            let bitPosition = alignBits - Int((UInt32(x) & xMask) + 1) * bitsPerPixel
            let index = rowStart + (x >> xShift)
            var word = data[index]

            word &= ~(bitMask << bitPosition)
            word |= (value & bitMask) << bitPosition
            
            data[index] = word
        } else {
            let offset = rowStart * uintSize
            data.withUnsafeMutableBytes { pixelPtr in
                if bytesPerPixel == 1 {
                    pixelPtr.storeBytes(of: UInt8(value & bitMask), toByteOffset: offset + x, as: UInt8.self)
                } else if bytesPerPixel == 2 {
                    pixelPtr.storeBytes(of: UInt16(value & bitMask), toByteOffset: offset + x * 2, as: UInt16.self)
                } else {
                    pixelPtr.storeBytes(of: UInt32(value), toByteOffset: offset + x * 4, as: UInt32.self)
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