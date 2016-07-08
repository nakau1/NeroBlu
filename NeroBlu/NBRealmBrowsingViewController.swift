// =============================================================================
// NBRealm
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit
import RealmSwift

private typealias RmObject   = RealmSwift.Object
private typealias RmListBase = RealmSwift.ListBase
private typealias RmProperty = RealmSwift.Property
private typealias RmType     = RealmSwift.PropertyType

// MARK: - NBRealmBrowsingViewController -

/// Realmデータベースの内容を確認閲覧するビューコントローラ
public class NBRealmBrowsingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: 表示
    
    /// NBRealmBrowsingViewControllerをモーダル表示する
    /// - parameter viewController: 表示元のビューコントローラ
    public class func show(viewController: UIViewController) {
        let vc = NBRealmBrowsingViewController()
        let nvc = UINavigationController(rootViewController: vc)
        viewController.presentViewController(nvc, animated: true, completion: nil)
    }
    
    private var items                      = NBRealmBrowsingItems()
    private var type: NBRealmBrowsingType  = .Classes
    private var targetClassName: String?   = nil
    private var targetObject: RmObject?    = nil
    private var targetObjects: [RmObject]? = nil
    
    // MARK: ライフサイクル
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.type.title(self.targetClassName)
        
        self.loadItems()
        self.setupNavigationItem()
        self.setupTableView()
    }
    
    // MARK: ナビゲーションアイテム
    
    private func setupNavigationItem() {
        if self.navigationController?.viewControllers.count > 1 { return }
        
        let close = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(NBRealmBrowsingViewController.didTapCloseBarItem))
        self.navigationItem.leftBarButtonItem = close
    }
    
    @objc private func didTapCloseBarItem() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: テーブルビュー
    
    private func setupTableView() {
        let v = UITableView(frame: CGRectZero, style: .Grouped)
        v.delegate = self
        v.dataSource = self
        v.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(v)
        
        for format in ["H:|-0-[v]-0-|", "V:|-0-[v]-0-|"] {
            self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
                format,
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:   ["v": v]
                )
            )
        }
    }
    
    // MARK: データ(アイテム)の読込
    
    private func loadItems() {
        switch self.type {
        case .Classes: self.items.loadClassesItems()
        case .Schema:  self.items.loadClassSchemaItems(self.targetClassName!)
        case .Detail:  self.items.loadDetailItems(self.targetObject!)
        case .Objects:
            if let objects = self.targetObjects {
                self.items.loadObjectsItems(objects)
            } else if let className = self.targetClassName {
                self.items.loadObjectsItems(className)
            }
            break
        }
    }
    
    // MARK: 画面遷移
    
    private func transit(type: NBRealmBrowsingType, setup: (NBRealmBrowsingViewController) -> ()) {
        let vc = NBRealmBrowsingViewController()
        vc.type = type
        setup(vc)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: UITableViewDelegate & UITableViewDataSource
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.type.headerTitle(self.items.count)
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let item = self.items[indexPath.row]
        
        switch self.type {
        case .Classes:
            self.transit(.Objects) { vc in
                vc.targetClassName = self.items[indexPath.row].mainText
            }
        case .Objects:
            self.transit(.Detail) { vc in
                vc.targetObject = self.items[indexPath.row].object
            }
        case .Detail:
            guard let object = self.targetObject, property = item.property(object) else { return }
            
            if property.type == .String, let text = item.detailValue(object) as? String {
                let alert = UIAlertController(title: item.mainText, message: text, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "close", style: .Cancel) { _ in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    })
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else if property.type == .Object, let object = item.detailValue(object) as? RmObject {
                self.transit(.Detail) { vc in
                    vc.targetObject = object
                }
            }
            else if property.type == .Array, let listInfo = item.detailListInfo(object) {
                self.transit(.Objects) { vc in
                    vc.targetClassName = listInfo.name
                    vc.targetObjects   = listInfo.objects
                }
            }
            
        default: break
        }
    }
    
    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        switch self.type {
        case .Classes:
            self.transit(.Schema) { vc in
                vc.targetClassName = self.items[indexPath.row].mainText
            }
        default: break
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let reusableCell = tableView.dequeueReusableCellWithIdentifier("cell") {
            cell = reusableCell
        } else {
            cell = UITableViewCell(style: self.type.cellStyle, reuseIdentifier: "cell")
            self.setupCell(cell)
        }
        
        let item = self.items[indexPath.row]
        cell = self.assignCell(cell, item: item)
        return cell
    }
    
    // MARK: テーブルセル
    
    private func setupCell(cell: UITableViewCell) -> UITableViewCell {
        if let mainText = cell.textLabel {
            mainText.font          = UIFont.boldSystemFontOfSize(16)
            mainText.textAlignment = .Left
            mainText.textColor     = NBRealmBrowsingTextUtil.mainTextColor
        }
        if let subText = cell.detailTextLabel {
            subText.textAlignment = .Left
            subText.textColor     = NBRealmBrowsingTextUtil.subTextColor
            subText.lineBreakMode = .ByTruncatingMiddle
            if self.type == .Detail {
                subText.font = UIFont.systemFontOfSize(16)
            }
        }
        return cell
    }
    
    private func assignCell(cell: UITableViewCell, item: NBRealmBrowsingItem) -> UITableViewCell {
        cell.selectionStyle                  = item.selectionStyle
        cell.accessoryType                   = item.accessoryType
        cell.textLabel?.text                 = item.mainText
        cell.detailTextLabel?.attributedText = item.subText
        return cell
    }
}

// MARK: - NBRealmBrowsingType -
private enum NBRealmBrowsingType {
    
    case Classes
    case Schema
    case Objects
    case Detail
    
    /// 画面タイトル
    func title(className: String? = nil) -> String {
        switch self {
        case .Classes: return "Classes"
        case .Schema:  return className ?? ""
        case .Objects: return className ?? ""
        case .Detail:  return "Detail"
        }
    }
    
    /// ヘッダタイトル
    func headerTitle(count: Int) -> String {
        switch self {
        case .Classes: return "\(count) Classes"
        case .Schema:  return "Schema Of Class"
        case .Objects: return "\(count) Objects"
        case .Detail:  return "Detail Of Object"
        }
    }
    
    /// セル種別
    var cellStyle: UITableViewCellStyle {
        switch self {
        case .Detail: return .Value1
        default:      return .Subtitle
        }
    }
}

// MARK: - NBRealmBrowsingItem -
private class NBRealmBrowsingItem {
    
    var mainText:      String
    var subText:       NSAttributedString?
    var cellStyle:     UITableViewCellStyle = .Subtitle
    var accessoryType: UITableViewCellAccessoryType = .None
    var object:        RmObject?
    
    var selectionStyle: UITableViewCellSelectionStyle {
        return self.accessoryType == .None ? .None : .Blue
    }
    
    init(_ text: String, subText: NSAttributedString? = nil) {
        self.mainText = text
        self.subText  = subText
    }
}

private extension NBRealmBrowsingItem {
    
    private func detailValue(targetObject: RmObject?) -> AnyObject? {
        if let object = targetObject, let ret = object.valueForKey(self.mainText) {
            return ret
        }
        return nil
    }
    
    private func detailListInfo(targetObject: RmObject?) -> (objects: [RmObject], name: String)? {
        guard let object = targetObject else { return nil }
        
        let list = object.dynamicList(self.mainText)
        return (
            objects: list.map {$0},
            name:    self.property(targetObject)?.objectClassName ?? ""
        )
    }
    
    private func property(targetObject: RmObject?) -> RmProperty? {
        guard let object = targetObject else { return nil }
        
        for property in object.objectSchema.properties {
            if self.mainText == property.name {
                return property
            }
        }
        return nil
    }
}

// MARK: - NBRealmBrowsingItems -
private class NBRealmBrowsingItems {
    
    private var items = [NBRealmBrowsingItem]()
    
    private var realm: RealmSwift.Realm { return try! RealmSwift.Realm() }
    
    private subscript (i: Int) -> NBRealmBrowsingItem {
        return self.items[i]
    }
    
    private var count: Int { return self.items.count }
    
    private func loadClassesItems() {
        self.items = [NBRealmBrowsingItem]()
        for schema in self.realm.schema.objectSchema {
            let item = NBRealmBrowsingItem(schema.className)
            item.accessoryType = .DetailDisclosureButton
            self.items.append(item)
        }
    }
    
    private func loadClassSchemaItems(className: String) {
        self.items = [NBRealmBrowsingItem]()
        guard let schema = self.realm.schema[className] else { return }
        
        for property in schema.properties {
            let item = NBRealmBrowsingItem(property.name, subText: NBRealmBrowsingTextUtil.text(property: property))
            self.items.append(item)
        }
    }
    
    private func loadObjectsItems(className: String) {
        self.items = [NBRealmBrowsingItem]()
        
        let objects: [RmObject] = self.realm.dynamicObjects(className).map {$0}
        for object in objects {
            let item = NBRealmBrowsingItem(object.debugDescription)
            item.accessoryType = .DisclosureIndicator
            item.object = object
            self.items.append(item)
        }
    }
    
    private func loadObjectsItems(objects: [RmObject]) {
        self.items = [NBRealmBrowsingItem]()
        
        for object in objects {
            let item = NBRealmBrowsingItem(object.debugDescription)
            item.accessoryType = .DisclosureIndicator
            item.object = object
            self.items.append(item)
        }
    }
    
    private func loadDetailItems(object: RmObject) {
        self.items = [NBRealmBrowsingItem]()
        
        for property in object.objectSchema.properties {
            let detailValue = object.valueForKey(property.name)
            let item = NBRealmBrowsingItem(property.name, subText: NBRealmBrowsingTextUtil.text(detailValue: detailValue, propertyType: property.type))
            
            item.accessoryType = .None
            if self.selectableForDetail(property.type, detailValue) {
                item.accessoryType = .DisclosureIndicator
            }
            self.items.append(item)
        }
    }
    
    private func selectableForDetail(type: RmType, _ value: AnyObject?) -> Bool {
        guard let v = value else { return false }
        switch type {
        case .Array, .Object: return true
        case .String: return !(v as! String).isEmpty
        default: return false
        }
    }
}

// MARK: - NBRealmBrowsingTextUtil -
private class NBRealmBrowsingTextUtil {}

private extension NBRealmBrowsingTextUtil {
    
    private class func text(property property: RmProperty) -> NSAttributedString {
        let typeName: String
        switch property.type {
        case .Int:            typeName = "Int"
        case .Bool:           typeName = "Bool"
        case .Float:          typeName = "Float"
        case .Double:         typeName = "Double"
        case .String:         typeName = "String"
        case .Data:           typeName = "BinaryData"
        case .Any:            typeName = "Any: not supported in swift"
        case .Date:           typeName = "DateTime"
        case .Object:         typeName = "<\(property.objectClassName ?? "?" )>"
        case .Array:          typeName = "Array of <\(property.objectClassName ?? "?" )>"
        case .LinkingObjects: typeName = "LinkingObjects of <\(property.objectClassName ?? "?" )>"
        }
        
        let ret = self.string(typeName)
        if property.optional {
            self.addOptionalText(ret)
        }
        if property.indexed {
            self.addInexedText(ret)
        }
        
        return ret
    }
    
    private class func text(detailValue any: AnyObject?, propertyType type: RmType) -> NSAttributedString {
        guard let value = any else { return self.nilText }
        
        switch type {
        case .String:
            let ret = self.string("\"\(value)\"")
            self.setColor(ret, color: self.stringTextColor)
            return ret
        case .Bool:
            let ret = self.string((value as! Bool) ? "true" : "false")
            self.setColor(ret, color: self.boolTextColor)
            return ret
        case .Data:
            return self.string("Binary (\((value as! NSData).length) bytes)")
        case .Date:
            let df = NSDateFormatter()
            df.dateFormat = "yyyy/MM/dd HH:mm:ss"
            return self.string(df.stringFromDate((value as! NSDate)))
        case .Object:
            return self.string(self.nameOfObject(value as! RmObject))
        case .Array:
            let list = value as! RmListBase
            let ret = self.string(self.nameOfList(list))
            self.addCountText(ret, count: list.count)
            return ret
        default: return self.string("\(value)")
        }
    }
}

private extension NBRealmBrowsingTextUtil {
    
    private class func addOptionalText(text: NSMutableAttributedString) {
        let prefix = self.string("Optional( ")
        self.setColor(prefix, color: NBRealmBrowsingTextUtil.optionalTextColor)
        text.insertAttributedString(prefix, atIndex: 0)
        
        let suffix = self.string(" )")
        self.setColor(suffix, color: NBRealmBrowsingTextUtil.optionalTextColor)
        text.appendAttributedString(suffix)
    }
    
    private class func addInexedText(text: NSMutableAttributedString) {
        let suffix = self.string(" Indexed")
        self.setColor(suffix, color: NBRealmBrowsingTextUtil.indexedTextColor)
        text.appendAttributedString(suffix)
    }
    
    private class func addCountText(text: NSMutableAttributedString, count: Int) {
        text.appendAttributedString(self.string(" "))
        
        let suffix = self.string(" \(count) ")
        self.setColor(suffix, color: UIColor.whiteColor())
        self.setBackgroundColor(suffix, color: NBRealmBrowsingTextUtil.subTextColor)
        text.appendAttributedString(suffix)
    }
    
    private class var nilText: NSAttributedString {
        let ret = self.string("<nil>")
        self.setColor(ret, color: NBRealmBrowsingTextUtil.nilTextColor)
        return ret
    }
}

private extension NBRealmBrowsingTextUtil {
    
    private class func nameOfList(list: RmListBase) -> String {
        return list._rlmArray.objectClassName
    }
    
    private class func nameOfObject(object: RmObject) -> String {
        return object.objectSchema.className
    }
}

private extension NBRealmBrowsingTextUtil {
    
    private static let mainTextColor     = UIColor(white: 0, alpha: 1)
    private static let subTextColor      = UIColor(red:0, green:0.478, blue:1, alpha:1)
    private static let stringTextColor   = UIColor(red:0.812, green:0.192, blue:0.145, alpha:1)
    private static let boolTextColor     = UIColor(red:0.722, green:0.200, blue:0.631, alpha:1)
    private static let nilTextColor      = UIColor(red:0.722, green:0.200, blue:0.631, alpha:1)
    private static let optionalTextColor = UIColor(red:0.47, green:0.47, blue:0.47, alpha:1)
    private static let indexedTextColor  = UIColor(red:0.984, green:0.42, blue:0.333, alpha:1)
    
    private class func string(string: String = "") -> NSMutableAttributedString {
        return NSMutableAttributedString(string: string)
    }
    
    private class func setColor(text: NSMutableAttributedString, color: UIColor) {
        text.addAttributes([NSForegroundColorAttributeName: color], range: NSMakeRange(0, text.length))
    }
    
    private class func setBackgroundColor(text: NSMutableAttributedString, color: UIColor) {
        text.addAttributes([NSBackgroundColorAttributeName: color], range: NSMakeRange(0, text.length))
    }
}
