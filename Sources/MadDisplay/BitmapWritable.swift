public protocol BitmapWritable {
    var width: Int { get }
    var height: Int { get }

    func writeBitmap(x: Int, y: Int, width w: Int, height h: Int, data: [UInt8])
}