public class Group {

    struct GroupOptions: OptionSet {
        let rawValue: UInt8

        static let itemRemoved = GroupOptions(rawValue: 1 << 0)
        static let inGroup = GroupOptions(rawValue: 1 << 1)
        static let hidden = GroupOptions(rawValue: 1 << 2)
        static let hiddenByParent = GroupOptions(rawValue: 1 << 3)
    }

    var children: [AnyObject] = []
    var absoluteTransform: Transform!
    var dirtyArea = Area()
    var x: Int
    var y: Int
    var scale: Int
    //var maxSize: Int
    var options: GroupOptions = []

    var size: Int {
        children.count
    }

    public init(x: Int = 0, y: Int = 0, scale: Int = 1) {
        guard scale >= 1 else {
            fatalError("scale must >= 1")
        }

        self.x = x
        self.y = y
        self.scale = scale
    }
}


extension Group {

    func getHidden() -> Bool {
        return options.contains(.hidden)
    }

    func setHidden(_ value: Bool) {
        if options.contains(.hidden) == value {
            return
        }

        if value {
            options.insert(.hidden)
        } else {
            options.remove(.hidden)
        }

        if options.contains(.hiddenByParent) {
            return
        }

        for child in children {
            if let t = child as? TileGrid {
                t.setHiddenByParent(value)
            } else if let g = child as? Group {
                g.setHiddenByParent(value)
            }
        }
    }


    func setHiddenByParent(_ value: Bool) {
        if options.contains(.hiddenByParent) == value {
            return
        }

        if value {
            options.insert(.hiddenByParent)
        } else {
            options.remove(.hiddenByParent)
        }

        if options.contains(.hidden) {
            return
        }

        for child in children {
            if let t = child as? TileGrid {
                t.setHiddenByParent(value)
            } else if let g = child as? Group {
                g.setHiddenByParent(value)
            }
        }
    }

    func getScale() -> Int {
        return scale
    }

    func getPreviousArea() -> Area? {
        var first = true
        var area: Area? = nil

        for child in children {
            var layerArea: Area? = nil

            if let t = child as? TileGrid {
                layerArea = t.getPreviousArea()
            } else if let g = child as? Group {
                layerArea = g.getPreviousArea()
            }

            if layerArea == nil {
                continue
            }

            if first {
                area = layerArea
                first = false
            } else {
                area!.formUnion(layerArea!)
            }
        }

        if options.contains(.itemRemoved) {
            if first {
                area = dirtyArea
                first = false
            } else {
                area!.formUnion(dirtyArea)
            }
        }

        return area
    }

    func updateChildTransforms() {
        if !options.contains(.inGroup) {
            return
        }

        for child in children {
            if let t = child as? TileGrid {
                t.updateTransform(absoluteTransform)
            } else if let g = child as? Group {
                g.updateTransform(absoluteTransform)
            }
        }
    }

    func updateTransform(_ _parentTransform: Transform?) {
        if _parentTransform != nil {
            options.insert(.inGroup)
        } else {
            options.remove(.inGroup)
        }
        
        absoluteTransform = Transform()

        if let parentTransform = _parentTransform {
            var x = self.x
            var y = self.y
            
            if parentTransform.transposeXY {
                x = y
                y = self.x
            }

            absoluteTransform.x = parentTransform.x + parentTransform.dx * x
            absoluteTransform.y = parentTransform.y + parentTransform.dy * y
            absoluteTransform.dx = parentTransform.dx * scale
            absoluteTransform.dy = parentTransform.dy * scale
            absoluteTransform.transposeXY = parentTransform.transposeXY
            absoluteTransform.mirrorX = parentTransform.mirrorX
            absoluteTransform.mirrorY = parentTransform.mirrorY
            absoluteTransform.scale = parentTransform.scale * scale
        }

        updateChildTransforms()
    }

    public func setScale(_ value: Int) {
        if scale == value {
            return
        }

        let parentScale = absoluteTransform.scale * scale
        absoluteTransform.dx = absoluteTransform.dx / scale * value
        absoluteTransform.dy = absoluteTransform.dy / scale * value
        absoluteTransform.scale = parentScale * value
        scale = value
        updateChildTransforms()
    } 

    public func getX() -> Int {
        return x
    }

    public func getY() -> Int {
        return y
    }

    public func setX(_ value: Int) {
        if x == value {
            return
        }

        if absoluteTransform.transposeXY {
            let dy = absoluteTransform.dy / scale
            absoluteTransform.y += dy * (value - x)
        } else {
            let dx = absoluteTransform.dx / scale
            absoluteTransform.x += dx * (value - x)
        }

        x = value
        updateChildTransforms()
    }

    public func setY(_ value: Int) {
        if y == value {
            return
        }

        if absoluteTransform.transposeXY {
            let dx = absoluteTransform.dx / scale
            absoluteTransform.x += dx * (value - y)
        } else {
            let dy = absoluteTransform.dy / scale
            absoluteTransform.y += dy * (value - y)
        }

        y = value
        updateChildTransforms()
    }

    private func addLayer(_ layer: TileGrid) {
        if layer.options.contains(.inGroup) {
            fatalError("tileGrid already in a group.")
        } else {
            layer.options.insert(.inGroup)
        }
        layer.updateTransform(absoluteTransform)
    }

    private func addLayer(_ layer: Group) {
        if layer.options.contains(.inGroup) {
            fatalError("group already in a group.")
        } else {
            layer.options.insert(.inGroup)
        }
        layer.updateTransform(absoluteTransform)
    }

    public func append(_ tileGrid: TileGrid) {
        addLayer(tileGrid)
        children.append(tileGrid)
    }

    public func append(_ group: Group) {
        addLayer(group)
        children.append(group)
    }

    public func insert(_ tileGrid: TileGrid, at index: Int) {
        if index >= size {
            fatalError("Insert position must before the end of all children")
        }
        addLayer(tileGrid)
        children.insert(tileGrid, at: index)
    }

    public func insert(_ group: Group, at index: Int) {
        if index >= size {
            fatalError("Insert position must before the end of all children")
        }
        addLayer(group)
        children.insert(group, at: index)
    }


    private func removeLayer(at index: Int) {
        var layerArea: Area? = nil
        let layer = children[index]

            if let t = layer as? TileGrid {
                layerArea = t.getPreviousArea()
                t.updateTransform(nil)
            } else if let g = layer as? Group {
                layerArea = g.getPreviousArea()
                g.updateTransform(nil)
            }

        if layerArea == nil {
            return
        }

        if !options.contains(.itemRemoved) {
            dirtyArea = layerArea!
        } else {
            dirtyArea.formUnion(layerArea!)
        }

        options.insert(.itemRemoved)
    }


    public func remove(at index: Int) -> AnyObject {
        removeLayer(at: index)
        return children.remove(at: index)
    }

    public func remove(_ t: TileGrid) -> Bool {
        if let index = children.firstIndex(where: {item in item === t}) {
            _ = remove(at: index)
            return true
        }
        return false
    }

    public func remove(_ g: Group) -> Bool {
        if let index = children.firstIndex(where: {item in item === g}) {
            _ = remove(at: index)
            return true
        }
        return false
    }

    public func pop() -> Bool {
        if size > 0 {
            let index = size - 1
            _  = remove(at: index)
            return true
        }
        return false
    }

    public func getLength() -> Int {
        return size
    }

    public func replace(with tileGrid: TileGrid, at index: Int) {
        addLayer(tileGrid)
        removeLayer(at: index)
        children[index] = tileGrid
    }

    public func replace(with group: Group, at index: Int) {
        addLayer(group)
        removeLayer(at: index)
        children[index] = group
    }

    func fillArea(colorSpace: ColorSpace, area: Area, mask: inout [UInt32], data: inout [UInt32]) -> Bool {
        var fullCoverage = false
        for index in (0..<size).reversed() {
            let layer = children[index]

            if let t = layer as? TileGrid {
                fullCoverage = t.fillArea(colorSpace: colorSpace, area: area, mask: &mask, data: &data)
                if fullCoverage {
                    break
                }
            } else if let g = layer as? Group {
                fullCoverage = g.fillArea(colorSpace: colorSpace, area: area, mask: &mask, data: &data)
                if fullCoverage {
                    break
                }
            }
        }

        return fullCoverage
    }

    func finishRefresh() {
        options.remove(.itemRemoved)

        for index in (0..<size).reversed() {
            let layer = children[index]

            if let t = layer as? TileGrid {
                t.finishRefresh()
            } else if let g = layer as? Group {
                g.finishRefresh()
            }
        }
    }

    func getRefreshAreas(_ tail: Area?) -> Area? {
        var tail = tail

        if options.contains(.itemRemoved) {
            dirtyArea.next = tail
            tail = dirtyArea
        }

        for index in (0..<size).reversed() {
            let layer = children[index]
            //print("index = \(index)")
            //print("tail = \(tail)")

            if let t = layer as? TileGrid {
                tail = t.getRefreshAreas(tail)
            } else if let g = layer as? Group {
                tail = g.getRefreshAreas(tail)
            }
        }

        return tail
    }

}