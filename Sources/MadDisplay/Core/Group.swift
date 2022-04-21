/// Create a group to gather tiles and groups for display.
///
/// For your final display, you need to put all your elements in one group,
/// including tiles and groups. Each elements constitute one layer. You could
/// decide the order of layers to determine how the group shows on the screen.
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

    /// Initialize a group by setting its position and the size of all its elements.
    ///
    /// The position of a group is decided by its upper left pixel relative to
    /// screen, the origin by default.
    /// After you set the value for scale, all elements in that group will be scaled.
    /// For a scale of 2, 1 pixel is resized to 4 (2*2) pixels. So the area is
    /// actually 4 (the square of scale) times the original size.
    /// - Parameters:
    ///   - x: the x coordinate of the upper left corner, 0 by default.
    ///   - y: the y coordinate of the upper left corner, 0 by default.
    ///   - scale: an integer that decides how the group will be enlarge, 1 by
    ///   default, which means the original size.
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
            if let t = child as? Tile {
                t.setHiddenByParent(value)
            } else if let g = child as? Group {
                g.setHiddenByParent(value)
            }
        }
    }

    public func setHidden(_ value: Bool, at layer: Int) {
        if layer >= size {
	    return
        }
        if let t = children[layer] as? Tile {
            t.setHiddenByParent(value)
        } else if let g = children[layer] as? Group {
            g.setHiddenByParent(value)
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
            if let t = child as? Tile {
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

            if let t = child as? Tile {
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
                area = area!.union(layerArea!)
            }
        }

        if options.contains(.itemRemoved) {
            if first {
                area = dirtyArea
                first = false
            } else {
                area = area!.union(dirtyArea)
            }
        }

        return area
    }

    func updateChildTransforms() {
        if !options.contains(.inGroup) {
            return
        }

        for child in children {
            if let t = child as? Tile {
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

    /// Scale the group.
    /// - Parameter value: the scale to resize of the group.
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

    /// Get the position of group in x coordinate.
    /// - Returns: the x coordinate of the upper left corner.
    public func getX() -> Int {
        return x
    }

    /// Get the position of group in y coordinate.
    /// - Returns: the y coordinate of the upper left corner.
    public func getY() -> Int {
        return y
    }

    /// Change the group’s position on the screen horizontally.
    /// - Parameter value: x coordinate of the upper left corner of the group.
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

    /// Change the group’s position on the screen vertically.
    /// - Parameter value: y coordinate of the upper left corner of the group.
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

    private func addLayer(_ layer: Tile) {
        if layer.options.contains(.inGroup) {
            fatalError("tile already in a group.")
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

    /// Add an new tile to the group. This one will be on the top layer and
    /// thus overlap those who already in the group.
    /// - Parameter tile: the tile to be added.
    public func append(_ tile: Tile) {
        addLayer(tile)
        children.append(tile)
    }

    /// Add an new group to the group. This one will be on the top layer and
    /// thus overlap those who already in the group.
    /// - Parameter group: the group to be added.
    public func append(_ group: Group) {
        addLayer(group)
        children.append(group)
    }

    /// Insert a tile to the group at a specified position.
    ///
    /// The position is decided by the index which starts from 0. The index 0
    /// refers to the first element in the group.
    /// The index should not be bigger than the index for the existing layers
    /// in the group.
    /// - Parameters:
    ///   - tile: the specified tile to be added.
    ///   - index: the position to place the tile.
    public func insert(_ tile: Tile, at index: Int) {
        if index >= size {
            fatalError("Insert position must before the end of all children")
        }
        addLayer(tile)
        children.insert(tile, at: index)
    }

    /// Insert another group to the group at a specified position.
    ///
    /// The position is decided by the index which starts from 0. The index 0
    /// refers to the first element in the group.
    /// The index should not be bigger than the index for the existing layers
    /// in the group.
    /// - Parameters:
    ///   - group: the specified group to be added.
    ///   - index: the position to place the group.
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

            if let t = layer as? Tile {
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
            dirtyArea = dirtyArea.union(layerArea!)
        }

        options.insert(.itemRemoved)
    }


    /// Remove the element (tile or group) at the specified position in the group.
    /// - Parameter index: the position of the layer.
    /// - Returns: the element at the specified position.
    public func remove(at index: Int) -> AnyObject {
        removeLayer(at: index)
        return children.remove(at: index)
    }

    /// Remove a specified tile from the group.
    /// - Parameter t: the tile needed to be removed.
    /// - Returns: a boolean value to know if it’s removed.
    public func remove(_ t: Tile) -> Bool {
        if let index = children.firstIndex(where: {item in item === t}) {
            _ = remove(at: index)
            return true
        }
        return false
    }

    /// Remove the specified group from the group.
    /// - Parameter g: the group needed to be removed.
    /// - Returns: a boolean value to know if it’s removed.
    public func remove(_ g: Group) -> Bool {
        if let index = children.firstIndex(where: {item in item === g}) {
            _ = remove(at: index)
            return true
        }
        return false
    }

    /// Remove the last element in the group
    /// - Returns: a boolean value to know if it’s removed.
    public func pop() -> Bool {
        if size > 0 {
            let index = size - 1
            _  = remove(at: index)
            return true
        }
        return false
    }

    /// Count the number of elements in the group.
    /// - Returns: the count of element.
    public func getLength() -> Int {
        return size
    }

    /// Replace an element in the group with a tile.
    /// - Parameters:
    ///   - tile: the tile used to replace an existing element.
    ///   - index: the position of the element.
    public func replace(with tile: Tile, at index: Int) {
        addLayer(tile)
        removeLayer(at: index)
        children[index] = tile
    }

    /// Replace an element in the group with a tile.
    /// - Parameters:
    ///   - group: the group used to replace an existing element.
    ///   - index: the position of the element.
    public func replace(with group: Group, at index: Int) {
        addLayer(group)
        removeLayer(at: index)
        children[index] = group
    }

    func fillArea(colorSpace: ColorSpace, area: Area, mask: inout [UInt32], data: inout [UInt8]) -> Bool {
        var fullCoverage = false
        for index in (0..<size).reversed() {
            let layer = children[index]

            if let t = layer as? Tile {
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

            if let t = layer as? Tile {
                t.finishRefresh()
            } else if let g = layer as? Group {
                g.finishRefresh()
            }
        }
    }

    func getRefreshAreas(_ areas: inout [Area]) {

        if options.contains(.itemRemoved) {
            areas.append(dirtyArea)
        }

        for index in (0..<size).reversed() {
            let layer = children[index]

            if let t = layer as? Tile {
                t.getRefreshAreas(&areas)
            } else if let g = layer as? Group {
                g.getRefreshAreas(&areas)
            }
        }
    }
}
