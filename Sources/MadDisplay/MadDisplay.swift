import SwiftIO


public final class MadDisplay {
    let screen: BitmapWritable
    let colorSpace: ColorSpace
    let transform: Transform
    let pixelsPerWord: Int
    let screenArea: Area

    //public init(screen: BitmapWritable, bitCount: Int) {
    public init(screen: BitmapWritable) {
        self.screen = screen

        //colorSpace = ColorSpace(depth: UInt8(bitCount))
        //colorSpace = ColorSpace()

        colorSpace = screen.colorSpace
        transform = Transform()
        pixelsPerWord = 32 / Int(colorSpace.depth)
        screenArea = Area(x1: 0, y1: 0, x2: screen.width - 1, y2: screen.height - 1)
    }


    func getUpdateAreas(_ area: Area) -> Area? {
        guard let clipped = screenArea.intersection(area) else {
            return nil
        }

        return clipped
    }

    func getRefreshData(_ clipped: Area, group: Group) -> [UInt32] {
        let pixelsPerBuffer = clipped.size

        var bufferSize = pixelsPerBuffer / pixelsPerWord

        if pixelsPerBuffer % pixelsPerWord != 0 {
            bufferSize += 1
        }

        let maskLength = (pixelsPerBuffer / 32) + 1

        //print("pixelsPerBuffer = \(pixelsPerBuffer), buffersize = \(bufferSize), maskLength = \(maskLength)")
        var buffer = [UInt32](repeating: 0, count: bufferSize)
        var mask = [UInt32](repeating: 0, count: maskLength)

        _ = group.fillArea(colorSpace: colorSpace, area: clipped, mask: &mask, data: &buffer)

        return buffer
    }

    public func show(_ group: Group) {
        if group.absoluteTransform == nil {
            group.updateTransform(transform)
        }

        var currentArea = group.getRefreshAreas(nil)

        while currentArea != nil {
            if let clippedArea = getUpdateAreas(currentArea!) {
                let data = getRefreshData(clippedArea, group: group)
                data.withUnsafeBytes { ptr in
                    screen.writeBitmap(x: clippedArea.x1, y: clippedArea.y1, width: clippedArea.width, height: clippedArea.height, data: Array(ptr))
                }
                //screen.writeBitmap(x: clippedArea.x1, y: clippedArea.y1, width: clippedArea.width, height: clippedArea.height, data: data)
            }
            currentArea = currentArea!.next
        }

        group.finishRefresh()
    }


}