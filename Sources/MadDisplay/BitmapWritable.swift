public protocol BitmapWritable {
    var width: Int { get }
    var height: Int { get }
    var colorSpace: ColorSpace { get }

    func writeBitmap(x: Int, y: Int, width w: Int, height h: Int, data: [UInt8])
}