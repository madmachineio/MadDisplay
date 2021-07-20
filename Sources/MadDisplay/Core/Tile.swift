public class Tile {

    struct TileOptions: OptionSet {
        let rawValue: UInt16

        static let partialChange = TileOptions(rawValue: 1 << 0)
        static let fullChange = TileOptions(rawValue: 1 << 1)
        static let moved = TileOptions(rawValue: 1 << 2)
        static let inlineTiles = TileOptions(rawValue: 1 << 3)
        static let inGroup = TileOptions(rawValue: 1 << 4)
        static let flipX = TileOptions(rawValue: 1 << 5)
        static let flipY = TileOptions(rawValue: 1 << 6)
        static let transposeXY = TileOptions(rawValue: 1 << 7)
        static let hidden = TileOptions(rawValue: 1 << 8)
        static let hiddenByParent = TileOptions(rawValue: 1 << 9)
    }

    var x, y: Int

    var bitmap: Bitmap
    var bitmapWidth, bitmapHeight: Int

    var palette: Palette

    var dirtyArea: Area
    var currentArea: Area
    var previousArea: Area?

    var options: TileOptions
    var absoluteTransform: Transform!

    public init(x: Int = 0, y: Int = 0, bitmap: Bitmap, palette: Palette) {

        self.x = x
        self.y = y

        self.bitmap = bitmap
        self.palette = palette

        bitmapWidth = bitmap.width
        bitmapHeight = bitmap.height

        dirtyArea = Area(x1: x, y1: y, width: bitmapWidth, height: bitmapHeight)
        currentArea = dirtyArea
        previousArea = nil

        options = []
    }


    func getHidden() -> Bool {
        return options.contains(.hidden)
    }

    func setHidden(_ value: Bool) {
        if value {
            options.insert(.hidden)
        } else {
            options.remove(.hidden)
        }
    }

    func setHiddenByParent(_ value: Bool) {
        if value {
            options.insert(.hiddenByParent)
        } else {
            options.remove(.hiddenByParent)
        }
    }

    func getPreviousArea() -> Area? {
        return previousArea
    }


    func updateCurrentX() {
        let width: Int

        if options.contains(.transposeXY) {
            width = bitmapHeight
        } else {
            width = bitmapWidth
        }

        if absoluteTransform.transposeXY {
            currentArea.y1 = absoluteTransform.y + absoluteTransform.dy * x
            currentArea.y2 = absoluteTransform.y + absoluteTransform.dy * (x + width - 1)
            if currentArea.y1 > currentArea.y2 {
                swap(&currentArea.y2, &currentArea.y1)
            }
        } else {
            currentArea.x1 = absoluteTransform.x + absoluteTransform.dx * x
            currentArea.x2 = absoluteTransform.x + absoluteTransform.dx * (x + width - 1)
            if currentArea.x1 > currentArea.x2 {
                swap(&currentArea.x2, &currentArea.x1)
            }
        }
    }

    func updateCurrentY() {
        let height: Int

        if options.contains(.transposeXY) {
            height = bitmapWidth
        } else {
            height = bitmapHeight
        }

        if absoluteTransform.transposeXY {
            currentArea.x1 = absoluteTransform.x + absoluteTransform.dx * y
            currentArea.x2 = absoluteTransform.x + absoluteTransform.dx * (y + height - 1)
            if currentArea.x1 > currentArea.x2 {
                swap(&currentArea.x2, &currentArea.x1)
            }
        } else {
            currentArea.y1 = absoluteTransform.y + absoluteTransform.dy * y
            currentArea.y2 = absoluteTransform.y + absoluteTransform.dy * (y + height - 1)
            if currentArea.y1 > currentArea.y2 {
                swap(&currentArea.y2, &currentArea.y1)
            }
        }
    }


    func updateTransform(_ transform: Transform?) {
        if transform != nil {
            options.insert(.inGroup)
        } else {
            options.remove(.inGroup)
        }

        absoluteTransform = transform
        if transform != nil {
            options.insert(.moved)
            updateCurrentX()
            updateCurrentY()

            //print("Tile.updateTransform(), currentArea = \(currentArea)")
        }
    }

    
    func getX() -> Int {
        return x
    }

    func getY() -> Int {
        return y
    }

    public func setX(_ x: Int) {
        if self.x == x {
            return
        }

        options.insert(.moved)

        self.x = x
        if absoluteTransform != nil {
            updateCurrentX()
        }
    }

    public func setY(_ y: Int) {
        if self.y == y {
            return
        }

        options.insert(.moved)

        self.y = y
        if absoluteTransform != nil {
            updateCurrentY()
        }
    }

    public func setXY(x: Int, y: Int) {
        if self.x == x && self.y == y {
            return
        }

        options.insert(.moved)

        self.x = x
        self.y = y
        if absoluteTransform != nil {
            updateCurrentX()
            updateCurrentY()
        }
    }

    func getPalette() -> Palette {
        return palette
    }

    func setPalette(_ palette: Palette) {
        self.palette = palette
        options.insert(.fullChange)
    }


    func getFlipX() -> Bool {
        return options.contains(.flipX)
    }

    func getFlipY() -> Bool {
        return options.contains(.flipY)
    }

    func setFlipX(_ value: Bool) {
        if options.contains(.flipX) == value {
            return
        } else {
            options.insert([.flipX, .fullChange])
        }
    }

    func setFlipY(_ value: Bool) {
        if options.contains(.flipY) == value {
            return
        } else {
            options.insert([.flipY, .fullChange])
        }
    }

    func getTransposeXY() -> Bool {
        return options.contains(.transposeXY)
    }

    func setTransposeXY(_ value: Bool) {
        if options.contains(.transposeXY) == value {
            return
        }

        if value {
            options.insert(.transposeXY)
        } else {
            options.remove(.transposeXY)
        }

        if bitmapWidth == bitmapHeight {
            options.insert(.fullChange)
            return
        }

        updateCurrentX()
        updateCurrentY()

        options.insert(.moved)
    }


    func fillArea(colorSpace: ColorSpace, area: Area, mask: inout [UInt32], data: inout [UInt8]) -> Bool {
        if options.contains(.hidden) || options.contains(.hiddenByParent) {
            return false
        }

        let _overlap = area.intersection(currentArea)
        if _overlap == nil {
            return false
        }

        let overlap = _overlap!
        //print(overlap)
        var xStride = 1
        var yStride = area.width

        var flipX = options.contains(.flipX)
        var flipY = options.contains(.flipX)

        if options.contains(.transposeXY) != absoluteTransform.transposeXY {
            swap(&flipX, &flipY)
        }

        var start = 0
        if (absoluteTransform.dx < 0) != flipX {
            start += (area.x2 - area.x1 - 1) * xStride
            xStride *= -1
        } 

        if (absoluteTransform.dy < 0) != flipY {
            start += (area.y2 - area.y1 - 1) * yStride
            yStride *= -1
        } 

        var fullCoverage = area == overlap
        let transformed = overlap.transformWithin(  mirrorX: flipX != (absoluteTransform.dx < 0),
                                                    mirrorY: flipY != (absoluteTransform.dy < 0),
                                                    transposeXY: options.contains(.transposeXY) != absoluteTransform.transposeXY,
                                                    currentArea)

        let startX = transformed.x1 - currentArea.x1
        let endX = transformed.x2 - currentArea.x1
        let startY = transformed.y1 - currentArea.y1
        let endY = transformed.y2 - currentArea.y1

        var yShift = 0
        var xShift = 0

        if (absoluteTransform.dx < 0) != flipX {
            xShift = area.x2 - overlap.x2
        } else {
            xShift = overlap.x1 - area.x1
        }

        if (absoluteTransform.dy < 0) != flipY {
            yShift = area.y2 - overlap.y2
        } else {
            yShift = overlap.y1 - area.y1
        }

        if options.contains(.transposeXY) != absoluteTransform.transposeXY {
            swap(&xStride, &yStride)
            swap(&xShift, &yShift)
        }

        let pixelsPerByte = Int(8 / colorSpace.depth)

        var inputPixel = InputPixel()
        var outputPixel = OutputPixel()

        //print("startY = \(startY), endY = \(endY)")
        //print("startX = \(startX), endX = \(endX)")
        //print("start = \(start)")
        //print("xShift = \(xShift), yShift = \(yShift)")
        //print("xStride = \(xStride), yStride = \(yStride)")
        for j in startY...endY {
            inputPixel.y = j
            let rowStart = start + (inputPixel.y - startY + yShift) * yStride
            let localY = inputPixel.y / absoluteTransform.scale
            for i in startX...endX {
                inputPixel.x = i
                ////print("rowStart = \(rowStart), localY = \(localY)")
                var offset = rowStart + (inputPixel.x - startX + xShift) * xStride

                if (mask[offset / 32] & (1 << (offset % 32))) != 0 {
                    continue
                }
                let localX = inputPixel.x / absoluteTransform.scale

                //let tileLocation = (localY / bitmapHeight) + (localX / bitmapWidth)
                //inputPixel.tile = tiles[tileLocation]
                //inputPixel.tileX = inputPixel.tile * bitmapWidth + localX % bitmapWidth
                //inputPixel.tileY = inputPixel.tile * bitmapHeight + localY % bitmapHeight

                inputPixel.tileX = localX % bitmapWidth
                inputPixel.tileY = localY % bitmapHeight

                inputPixel.pixel = bitmap.getPixel(x: inputPixel.tileX, y: inputPixel.tileY)


                if let ret = palette.getColor(colorSpace: colorSpace, at: Int(inputPixel.pixel)) {
                    outputPixel.opaque = true
                    outputPixel.pixel = ret
                } else {
                    outputPixel.opaque = false
                }
                if outputPixel.opaque == false {
                    fullCoverage = false
                } else {
                    mask[offset / 32] |= 1 << (offset % 32)
                    
                    data.withUnsafeMutableBytes { ptr in
                        if colorSpace.depth == 16 {
                            ptr.storeBytes(of: UInt16(outputPixel.pixel & 0xFFFF), toByteOffset: offset * 2, as: UInt16.self)
                        } else if colorSpace.depth == 8 {
                            ptr.storeBytes(of: UInt8(outputPixel.pixel & 0xFF), toByteOffset: offset, as: UInt8.self)
                        } else if colorSpace.depth < 8 {
                            if !colorSpace.pixelsInByteShareRow {
                                let width = area.width
                                let row = offset / width
                                let col = offset % width

                                offset = col * pixelsPerByte + (row / pixelsPerByte) * pixelsPerByte * width + row % pixelsPerByte
                            }
                            var shift = (offset % pixelsPerByte) * Int(colorSpace.depth)
                            if colorSpace.reversePixelsInByte {
                                shift = (pixelsPerByte - 1) * Int(colorSpace.depth) - shift;
                            }
                            var value = ptr.load(fromByteOffset: offset / pixelsPerByte, as: UInt8.self)
                            value |= UInt8((outputPixel.pixel << shift) & 0xFF)
                            ptr.storeBytes(of: value, toByteOffset: offset / pixelsPerByte, as: UInt8.self)
                        }
                    }
                }
            }
        }
        return fullCoverage
    }


    func finishRefresh() {
        let firstDraw = previousArea == nil
        let hidden = options.contains(.hidden) || options.contains(.hiddenByParent)

        if !firstDraw && hidden {
            previousArea = nil
        } else if firstDraw || options.contains(.moved) {
            previousArea = currentArea
        }

        options.remove([.moved, .fullChange, .partialChange])
        palette.finishRefresh()
        bitmap.finishRefresh()
    }

    func getRefreshAreas(_ areas: inout [Area]) {
        let firstDraw = previousArea == nil
        let hidden = options.contains(.hidden) || options.contains(.hiddenByParent)

        if hidden {
            if !firstDraw {
                areas.append(previousArea!)
                return
            } else {
                return
            }
        } else if !firstDraw && options.contains(.moved) {
            dirtyArea = previousArea!.union(currentArea)
            if dirtyArea.size <= 2 * bitmapWidth * bitmapHeight {
                areas.append(dirtyArea)
                return
            }
            areas.append(previousArea!)
            areas.append(currentArea)
            return
        }

        if let bitmapRefreshArea = bitmap.getRefreshArea() {
            dirtyArea = bitmapRefreshArea
            options.insert(.partialChange)
        }

        if palette.needsRefresh {
            options.insert(.fullChange)
        }

        if options.contains(.fullChange) || firstDraw {
            areas.append(currentArea)
            return
        }

        if options.contains(.partialChange) {
            if absoluteTransform.transposeXY {
                let tempX1 = dirtyArea.x1
                dirtyArea.x1 = absoluteTransform.x + absoluteTransform.dx * (y + dirtyArea.y1)
                dirtyArea.y1 = absoluteTransform.y + absoluteTransform.dy * (x + tempX1)
                let tempX2 = dirtyArea.x2
                dirtyArea.x2 = absoluteTransform.x + absoluteTransform.dx * (y + dirtyArea.y2)
                dirtyArea.y2 = absoluteTransform.y + absoluteTransform.dy * (x + tempX2)
            } else {
                dirtyArea.x1 = absoluteTransform.x + absoluteTransform.dx * (x + dirtyArea.x1)
                dirtyArea.y1 = absoluteTransform.y + absoluteTransform.dy * (y + dirtyArea.y1)
                dirtyArea.x2 = absoluteTransform.x + absoluteTransform.dx * (x + dirtyArea.x2)
                dirtyArea.y2 = absoluteTransform.y + absoluteTransform.dy * (y + dirtyArea.y2)
            }
            if dirtyArea.y2 < dirtyArea.y1 {
                swap(&dirtyArea.y2, &dirtyArea.y1)
            }
            if dirtyArea.x2 < dirtyArea.x1 {
                swap(&dirtyArea.x2, &dirtyArea.x1)
            }
            areas.append(dirtyArea)
        }
    }
}


extension Tile {

}