public final class MadDisplay {
    let screen: BitmapWritable
    let colorSpace: ColorSpace
    let transform: Transform

    let screenArea: Area

    var mask: [UInt32]
    var screenBuffer: [UInt8]

    public init(screen: BitmapWritable, colorSpace: ColorSpace, transform: Transform? = nil) {
        self.screen = screen
        self.colorSpace = colorSpace

        if transform == nil {
            self.transform = Transform()
        } else {
            self.transform = transform!
        }

        screenArea = Area(x1: 0, y1: 0, width: screen.width, height: screen.height)

        let pixelsPerWord = 32 / Int(colorSpace.depth)
        let pixelsPerBuffer = screenArea.size

        var bufferWordSize = pixelsPerBuffer / pixelsPerWord

        if pixelsPerBuffer % pixelsPerWord != 0 {
            bufferWordSize += 1
        }

        let maskLength = (pixelsPerBuffer / 32) + 1

        mask = [UInt32](repeating: 0, count: maskLength)
        screenBuffer = [UInt8](repeating: 0, count: bufferWordSize * 4)
    }


    public func update(_ group: Group) {
        if group.absoluteTransform == nil {
            group.updateTransform(transform)
        }

        var dirtyAreas = [Area]()
        dirtyAreas.reserveCapacity(group.size)

        group.getRefreshAreas(&dirtyAreas)
        //print(dirtyAreas)

        for i in (0..<dirtyAreas.count).reversed() {
            let area = dirtyAreas[i]
            if let clippedArea = area.intersection(screenArea) {
                let maskLength = clippedArea.size / 32 + 1
                for m in 0..<maskLength {
                    mask[m] = 0
                }
                let bufferLength = clippedArea.size * Int(colorSpace.depth)
                for n in 0..<bufferLength {
                    screenBuffer[n] = 0
                }
                group.fillArea(colorSpace: colorSpace, area: clippedArea, mask: &mask, data: &screenBuffer)
                screen.writeBitmap(x: clippedArea.x1, y: clippedArea.y1, width: clippedArea.width, height: clippedArea.height, data: screenBuffer)
                //print("update area: \(clippedArea)")
            }
        }

        group.finishRefresh()
    }


}