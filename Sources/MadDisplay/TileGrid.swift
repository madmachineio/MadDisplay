public class TileGrid {
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

    var bitmap: Bitmap

    var palette: Palette
    var x, y: Int
    var pixelWidth, pixelHeight: Int
    var bitmapWidthInTiles: Int
    var tilesInBitmap: Int
    var gridWidthInTiles, gridHeightInTiles: Int
    var tileWidthInPixels, tileHeightInPixels: Int
    var topLeftX, topLeftY: Int
    var dirtyArea: Area
    var previousArea: Area!
    var currentArea: Area
    var options: TileOptions
    var absoluteTransform: Transform!
    var tiles: [Int]

    public init(bitmap: Bitmap, palette: Palette, width: Int = 1, height: Int = 1, tileWidth: Int = 0, tileHeight: Int = 0, defaultTile: Int = 0, x: Int = 0, y: Int = 0) {
        tiles = [Int](repeating: defaultTile, count: width * height)
        self.bitmap = bitmap
        self.palette = palette

        self.x = x
        self.y = y

        topLeftX = 0
        topLeftY = 0

        tileWidthInPixels = tileWidth
        tileHeightInPixels = tileHeight

        if tileWidthInPixels == 0 {
            tileWidthInPixels = bitmap.width
        }
        if tileHeightInPixels == 0 {
            tileHeightInPixels = bitmap.height
        }

        gridWidthInTiles = width
        gridHeightInTiles = height

        pixelWidth = gridWidthInTiles * tileWidthInPixels
        pixelHeight = gridHeightInTiles * tileHeightInPixels

        dirtyArea = Area()
        currentArea = Area()
        previousArea = nil

        bitmapWidthInTiles = bitmap.width / tileWidthInPixels
        let bitmapHeightInTiles = bitmap.height / tileHeightInPixels
        tilesInBitmap = bitmapWidthInTiles * bitmapHeightInTiles

        options = []

        if (bitmap.width % tileWidthInPixels != 0) || (bitmap.height % tileHeightInPixels != 0) {
            fatalError("Tile width and height must exactly divide bitmap width and height")
        }
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
        var width: Int

        if options.contains(.transposeXY) {
            width = pixelHeight
        } else {
            width = pixelWidth
        }

        if absoluteTransform.transposeXY {
            currentArea.y1 = absoluteTransform.y + absoluteTransform.dy * x
            currentArea.y2 = absoluteTransform.y + absoluteTransform.dy * (x + width - 1)
            if currentArea.y2 < currentArea.y1 {
                let temp = currentArea.y2
                currentArea.y2 = currentArea.y1
                currentArea.y1 = temp
            }
        } else {
            currentArea.x1 = absoluteTransform.x + absoluteTransform.dx * x
            currentArea.x2 = absoluteTransform.x + absoluteTransform.dx * (x + width - 1)
            if currentArea.x2 < currentArea.x1 {
                let temp = currentArea.x2
                currentArea.x2 = currentArea.x1
                currentArea.x1 = temp
            }
        }
    }

    func updateCurrentY() {
        var height: Int

        if options.contains(.transposeXY) {
            height = pixelWidth
        } else {
            height = pixelHeight
        }

        if absoluteTransform.transposeXY {
            currentArea.x1 = absoluteTransform.x + absoluteTransform.dx * y
            currentArea.x2 = absoluteTransform.x + absoluteTransform.dx * (y + height - 1)
            if currentArea.x2 < currentArea.x1 {
                let temp = currentArea.x2
                currentArea.x2 = currentArea.x1
                currentArea.x1 = temp
            }
        } else {
            currentArea.y1 = absoluteTransform.y + absoluteTransform.dy * y
            currentArea.y2 = absoluteTransform.y + absoluteTransform.dy * (y + height - 1)
            if currentArea.y2 < currentArea.y1 {
                let temp = currentArea.y2
                currentArea.y2 = currentArea.y1
                currentArea.y1 = temp
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

    func getWidth() -> Int {
        return gridWidthInTiles
    }

    func getHeight() -> Int {
        return gridHeightInTiles
    }

    func getTile(x: Int, y: Int) -> Int? {
        let pos = y * gridWidthInTiles + x
        if pos < tiles.count {
            return tiles[pos]
        } else {
            return nil
        }
    }

    public func setTile(x: Int, y: Int, index: Int) {
        guard index < tilesInBitmap else { return }

        let pos = y * gridWidthInTiles + x
        if pos < tiles.count {
            tiles[pos] = index
        } else {
            return
        }

        var tileArea: Area
        if !options.contains(.partialChange) {
            tileArea = dirtyArea
        } else {
            tileArea = Area()
        }

        var tx = (x - topLeftX) % gridWidthInTiles
        if tx < 0 {
            tx += gridWidthInTiles
        }

        tileArea.x1 = tx * tileWidthInPixels
        tileArea.x2 = tileArea.x1 + tileWidthInPixels

        if options.contains(.partialChange) {
            dirtyArea.formUnion(tileArea)
        }

        options.insert(.partialChange)
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

        if pixelWidth == pixelHeight {
            options.insert(.fullChange)
            return
        }

        updateCurrentX()
        updateCurrentY()

        options.insert(.moved)
    }

    func setTopLeft(x: Int, y: Int) {
        topLeftX = x
        topLeftY = y
        options.insert(.fullChange)
    }

    func fillArea(colorSpace: ColorSpace, area: Area, mask: inout [UInt32], data: inout [UInt32]) -> Bool {
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
            let tempFlip = flipX
            flipX = flipY
            flipY = tempFlip
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
        let transformed = overlap.transformWithin( mirrorX: flipX != (absoluteTransform.dx < 0),
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
            let tempStride = xStride
            xStride = yStride
            yStride = tempStride

            let tempShift = xShift
            xShift = yShift
            yShift = tempShift
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
                let tileLocation = ((localY / tileHeightInPixels + topLeftY) % gridHeightInTiles) * gridWidthInTiles
                                   + (localX / tileWidthInPixels + topLeftX) % gridWidthInTiles
                inputPixel.tile = tiles[tileLocation]
                inputPixel.tileX = (inputPixel.tile % bitmapWidthInTiles) * tileWidthInPixels + localX % tileWidthInPixels
                inputPixel.tileY = (inputPixel.tile / bitmapWidthInTiles) * tileHeightInPixels + localY % tileHeightInPixels

                inputPixel.pixel = bitmap.getPixel(x: inputPixel.tileX, y: inputPixel.tileY)

                if let ret = palette.getColor(colorSpace: colorSpace, at: Int(inputPixel.pixel)) {
                    outputPixel.opaque = true
                    outputPixel.pixel = ret
                } else {
                    outputPixel.opaque = false
                }

                if !outputPixel.opaque {
                    fullCoverage = false
                } else {
                    mask[offset / 32] |= 1 << (offset % 32)

                    data.withUnsafeMutableBytes { ptr in
                        if colorSpace.depth == 16 {
                            //print("inputPixel.pixel = \(inputPixel.pixel)")
                            //print("outputPixel.pixel = \(outputPixel.pixel), offset = \(offset)")
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

        //print("finish 0")
        if !firstDraw && hidden {
            previousArea = nil
        } else if firstDraw || options.contains(.moved) {
            if previousArea == nil {
                previousArea = Area()
            }
            previousArea.reSize(currentArea)
        }
        //print("finish 1")

        options.remove([.moved, .fullChange, .partialChange])


        palette.finishRefresh()
        //print("finish 2")

        bitmap.finishRefresh()
        //print("finish 3")
    }

    func getRefreshAreas(_ tail: Area?) -> Area? {
        let firstDraw = previousArea == nil
        let hidden = options.contains(.hidden) || options.contains(.hiddenByParent)

        if hidden {
            if !firstDraw {
                previousArea.next = tail
                return previousArea
            } else {
                return tail
            }
        } else if !firstDraw && options.contains(.moved) {
            dirtyArea = previousArea.union(currentArea)
            if dirtyArea.size <= 2 * pixelWidth * pixelHeight {
                dirtyArea.next = tail
                return dirtyArea
            }
            previousArea.next = tail
            currentArea.next = previousArea
            return currentArea
        }

        let refreshArea = bitmap.getRefreshAreas(tail)

        if refreshArea != tail && refreshArea != nil {
            if tilesInBitmap == 1 {
                //dirtyArea = refreshArea!
                dirtyArea.reSize(refreshArea!)
                options.insert(.partialChange)
            } else {
                options.insert(.fullChange)
            }
        }

        if palette.needsRefresh {
            options.insert(.fullChange)
            //print(currentArea)
        }

        if options.contains(.fullChange) || firstDraw {
            currentArea.next = tail
            return currentArea
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
                let temp = dirtyArea.y2
                dirtyArea.y2 = dirtyArea.y1
                dirtyArea.y1 = temp
            }
            if dirtyArea.x2 < dirtyArea.x1 {
                let temp = dirtyArea.x2
                dirtyArea.x2 = dirtyArea.x1
                dirtyArea.x1 = temp
            }
            dirtyArea.next = tail
            return dirtyArea
        }

        return tail
    }
}