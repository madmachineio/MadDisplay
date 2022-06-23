/// Create a display to show graphics on a screen.
///
/// After you gather all elements in a group, you pass the group to the display
/// instance to display it on the screen.
///
/// ```swift
/// // let screen = ...
/// let display = MadDisplay(screen: screen)
///
/// let group = Group()
/// ...
/// display.update(group)
///
/// ```
public final class MadDisplay {
    let screen: BitmapWritable
    let colorSpace: ColorSpace
    let transform: Transform

    let screenArea: Area
    let pixelsPerWord: Int

    var mask: [UInt32]
    var screenBuffer: [UInt8]

    /// Initialize a display to show all elements on the screen.
    /// - Parameters:
    ///   - screen: the screen to display the elements. It follows the protocol BitmapWritable.
    ///   - colorSpace: the colorspace for the display.
    public init(screen: BitmapWritable, colorSpace: ColorSpace? = nil) {
        self.screen = screen

        if colorSpace == nil {
            self.colorSpace = screen.colorSpace
        } else {
            self.colorSpace = colorSpace!
        }

        self.transform = Transform()

        screenArea = Area(x1: 0, y1: 0, width: screen.width, height: screen.height)

        let pixelsPerBuffer = screenArea.size
        pixelsPerWord = 32 / Int(self.colorSpace.depth)

        var bufferWordSize = pixelsPerBuffer / pixelsPerWord

        if pixelsPerBuffer % pixelsPerWord != 0 {
            bufferWordSize += 1
        }

        let maskLength = (pixelsPerBuffer / 32) + 1

        mask = [UInt32](repeating: 0, count: maskLength)
        screenBuffer = [UInt8](repeating: 0, count: bufferWordSize * 4)
    }


    /// Display the specified group on the screen.
    ///
    /// This is necessary every time you change the group and want to show it.
    /// - Parameter group: the group for display.
    public func update(_ group: Group) {
        if group.absoluteTransform == nil {
            group.updateTransform(transform)
        }

        var dirtyAreas = [Area]()
        dirtyAreas.reserveCapacity(group.size)

        group.getRefreshAreas(&dirtyAreas)

        for i in (0..<dirtyAreas.count).reversed() {
            let area = dirtyAreas[i]
            if let clippedArea = area.intersection(screenArea) {
                let pixelsPerBuffer = clippedArea.size
                var bufferWordSize = pixelsPerBuffer / pixelsPerWord
                if pixelsPerBuffer % pixelsPerWord != 0 {
                    bufferWordSize += 1
                }
                for n in 0..<(bufferWordSize * 4) {
                    screenBuffer[n] = 0
                }
                let maskLength = pixelsPerBuffer / 32 + 1
                for m in 0..<maskLength {
                    mask[m] = 0
                }
                group.fillArea(colorSpace: colorSpace, area: clippedArea, mask: &mask, data: &screenBuffer)
                screen.writeBitmap(x: clippedArea.x1, y: clippedArea.y1, width: clippedArea.width, height: clippedArea.height, data: screenBuffer)
            }
        }

        group.finishRefresh()
    }


}
