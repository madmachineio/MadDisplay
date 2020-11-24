public protocol Font {
    var glyphCache: [UInt16: Glyph] { get }
    var fontHeight: Int { get }
    var maxCharAscent: Int { get }
    var maxCharDescent: Int { get }
    func getGlyph(_ encoding: UInt16) -> Glyph
}