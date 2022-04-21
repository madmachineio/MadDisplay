import SwiftIO

/// Get pixel info from bitmap images.
public struct BMP {
    struct FileHeader {
        var bfSize: Int32 = 0
        var bfReserved1: Int16 = 0
        var bfReserved2: Int16 = 0
        var bfOffBits: Int32 = 0
    }

    struct InfoHeader {
        var biSize: Int32 = 0
        var biWidth: Int32 = 0
        var biHeight: Int32 = 0
        var biPlanes: UInt16 = 0
        var biBitCount: UInt16 = 0
        var biCompression: Int32 = 0
        var biSizeImages: Int32 = 0
        var biXpelsPerMeter: Int32 = 0
        var biYpelsPerMeter: Int32 = 0
        var biClrUsed: Int32 = 0
        var biClrImportant: Int32 = 0
    }

    let header = UInt16(0x4D42)
    let file: FileDescriptor

    var bitmap: Bitmap! = nil
    var palette: Palette! = nil
    var colorConverter: ColorConverter? = nil

    var width: Int = 0
    var height: Int = 0
    var bitsPerPixel: Int = 0
    var compression: Bool  = false

    /// Read the BMP file on the SD card.
    /// - Parameters:
    ///   - path: the path of the BMP file on SD card.
    ///   - transparentColor: the color used as a transparent color, nil by default.
    public init(path: String, transparentColor: UInt32? = nil) {
        var bfType = UInt16(0)
        var fileHeader = FileHeader()
        var infoHeader = InfoHeader()

        file = FileDescriptor.open(path)
        _ = withUnsafeMutableBytes(of: &bfType) { buffer in
            file.read(into: buffer)
        }

        if bfType != header {
            print("BMP file type error!")
        }

        _ = withUnsafeMutableBytes(of: &fileHeader) { buffer in
            file.read(fromAbsoluteOffest: 2, into: buffer)
        }

        _ = withUnsafeMutableBytes(of: &infoHeader) { buffer in
            file.read(fromAbsoluteOffest: 14, into: buffer)
        }

        //print(fileHeader)
        //print(infoHeader)

        width = Int(infoHeader.biWidth)
        height = Int(infoHeader.biHeight)
        bitsPerPixel = Int(infoHeader.biBitCount)
        compression = infoHeader.biCompression == 3

        let bytesPerLine = (bitsPerPixel * width + 31) / 32 * 4 
        let imageByteSize = bytesPerLine * height

        var imageData = [UInt32](repeating: 0x0, count: imageByteSize / 4)
        _ = imageData.withUnsafeMutableBytes { buffer in
            file.read(fromAbsoluteOffest: Int(fileHeader.bfOffBits), into: buffer)
        }

        if bitsPerPixel > 8 {
            //print("------not indexed--------")
            bitmap = Bitmap(width: width, height: height, bitCount: 32)

            if bitsPerPixel == 32 {
                for y in 0..<height {
                    for x in 0..<width {
                        bitmap.data[y * width + x] = imageData[(height - y - 1) * width + x]
                    }
                }
            } else if bitsPerPixel == 24 {
                for y in 0..<height {
                    for x in 0..<width {
                        let byteOffset = (height - y - 1) * bytesPerLine + x * 3
                        var color32: UInt32 = 0
                        imageData.withUnsafeBytes { ptr in
                            let r = UInt32(ptr[byteOffset + 2]) << 16
                            let g = UInt32(ptr[byteOffset + 1]) << 8
                            let b = UInt32(ptr[byteOffset + 0])
                            color32 = r | g | b
                        }
                        bitmap.data[y * width + x] = color32
                    }
                }
            }
        } else {
            //print("------indexed--------")
            let colorCount = 1 << bitsPerPixel
            var colors = [UInt32](repeating: 0, count: colorCount)

            _ = colors.withUnsafeMutableBytes { buffer in
                file.read(fromAbsoluteOffest: 54, into: buffer)
            }

            palette = Palette(count: colorCount)
            for i in 0..<colorCount {
                palette[i] = colors[i]
            }
            if let trans = transparentColor {
                if colors[0] == trans {
                    palette.makeTransparent(0)
                }
            }
            //print("bitsPerPixel = \(bitsPerPixel)")
            bitmap = Bitmap(width: width, height: height, bitCount: bitsPerPixel)

            if bitsPerPixel < 8 {
                imageData = imageData.map {
                    $0.byteSwapped
                }
            }
            
            //print("bitmap uint32 size = \(bitmap.data.count), image uint32 size = \(imageData.count)")
            let uint32CountPerLine = bytesPerLine / 4
            for r in 0..<height {
                for c in 0..<uint32CountPerLine {
                    bitmap.data[r * uint32CountPerLine + c] = imageData[(height - r - 1) * uint32CountPerLine + c]
                }
            }
        }

        file.close()
    }

    /// Get bitmap info from the BMP file.
    /// - Returns: a bitmap that stores all pixel info of the image.
    public func getBitmap() -> Bitmap {
        return bitmap
    }

    /// Get the palette from the file if it is an indexed image.
    /// - Returns: a palette if the image is indexed; nil if it's not indexed.
    public func getPalette() -> Palette? {
        return palette
    }
}
