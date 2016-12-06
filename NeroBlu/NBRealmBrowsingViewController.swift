// =============================================================================
// NBRealm
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit
import RealmSwift
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


private typealias RmObject   = RealmSwift.Object
private typealias RmListBase = RealmSwift.ListBase
private typealias RmProperty = RealmSwift.Property
private typealias RmType     = RealmSwift.PropertyType

// MARK: - NBRealmBrowsingViewController -

/// Realmデータベースの内容を確認閲覧するビューコントローラ
open class NBRealmBrowsingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: 表示
    
    /// NBRealmBrowsingViewControllerをモーダル表示する
    /// - parameter viewController: 表示元のビューコントローラ
    open class func show(_ viewController: UIViewController) {
        let vc = NBRealmBrowsingViewController()
        let nvc = UINavigationController(rootViewController: vc)
        viewController.present(nvc, animated: true, completion: nil)
    }
    
    fileprivate var items                      = NBRealmBrowsingItems()
    fileprivate var type: NBRealmBrowsingType  = .classes
    fileprivate var targetClassName: String?   = nil
    fileprivate var targetObject: RmObject?    = nil
    fileprivate var targetObjects: [RmObject]? = nil
    
    // MARK: ライフサイクル
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.type.title(self.targetClassName)
        
        self.loadItems()
        self.setupNavigationItem()
        self.setupTableView()
    }
    
    // MARK: ナビゲーションアイテム
    
    fileprivate func setupNavigationItem() {
        if self.navigationController?.viewControllers.count > 1 { return }
        
        let close = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(NBRealmBrowsingViewController.didTapCloseBarItem))
        self.navigationItem.leftBarButtonItem = close
    }
    
    @objc fileprivate func didTapCloseBarItem() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: テーブルビュー
    
    fileprivate func setupTableView() {
        let v = UITableView(frame: CGRect.zero, style: .grouped)
        v.delegate = self
        v.dataSource = self
        v.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(v)
        
        for format in ["H:|-0-[v]-0-|", "V:|-0-[v]-0-|"] {
            self.view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: format,
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:   ["v": v]
                )
            )
        }
    }
    
    // MARK: データ(アイテム)の読込
    
    fileprivate func loadItems() {
        switch self.type {
        case .classes: self.items.loadClassesItems()
        case .schema:  self.items.loadClassSchemaItems(self.targetClassName!)
        case .detail:  self.items.loadDetailItems(self.targetObject!)
        case .objects:
            if let objects = self.targetObjects {
                self.items.loadObjectsItems(objects)
            } else if let className = self.targetClassName {
                self.items.loadObjectsItems(className)
            }
            break
        }
    }
    
    // MARK: 画面遷移
    
    fileprivate func transit(_ type: NBRealmBrowsingType, setup: (NBRealmBrowsingViewController) -> ()) {
        let vc = NBRealmBrowsingViewController()
        vc.type = type
        setup(vc)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: UITableViewDelegate & UITableViewDataSource
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.type.headerTitle(self.items.count)
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.items[indexPath.row]
        
        switch self.type {
        case .classes:
            self.transit(.objects) { vc in
                vc.targetClassName = self.items[indexPath.row].mainText
            }
        case .objects:
            self.transit(.detail) { vc in
                vc.targetObject = self.items[indexPath.row].object
            }
        case .detail:
            guard let object = self.targetObject, let property = item.property(object) else { return }
            
            if property.type == .string, let text = item.detailValue(object) as? String {
                let alert = UIAlertController(title: item.mainText, message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "close", style: .cancel) { _ in
                    alert.dismiss(animated: true, completion: nil)
                    })
                self.present(alert, animated: true, completion: nil)
            }
            else if property.type == .object, let object = item.detailValue(object) as? RmObject {
                self.transit(.detail) { vc in
                    vc.targetObject = object
                }
            }
            else if property.type == .array, let listInfo = item.detailListInfo(object) {
                self.transit(.objects) { vc in
                    vc.targetClassName = listInfo.name
                    vc.targetObjects   = listInfo.objects
                }
            }
            
        default: break
        }
    }
    
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch self.type {
        case .classes:
            self.transit(.schema) { vc in
                vc.targetClassName = self.items[indexPath.row].mainText
            }
        default: break
        }
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell = reusableCell
        } else {
            cell = UITableViewCell(style: self.type.cellStyle, reuseIdentifier: "cell")
            cell = self.setupCell(cell)
        }
        
        let item = self.items[indexPath.row]
        cell = self.assignCell(cell, item: item)
        return cell
    }
    
    // MARK: テーブルセル
    
    fileprivate func setupCell(_ cell: UITableViewCell) -> UITableViewCell {
        if let mainText = cell.textLabel {
            mainText.font          = UIFont.boldSystemFont(ofSize: 16)
            mainText.textAlignment = .left
            mainText.textColor     = NBRealmBrowsingTextUtil.mainTextColor
        }
        if let subText = cell.detailTextLabel {
            subText.textAlignment = .left
            subText.textColor     = NBRealmBrowsingTextUtil.subTextColor
            subText.lineBreakMode = .byTruncatingMiddle
            if self.type == .detail {
                subText.font = UIFont.systemFont(ofSize: 16)
            }
        }
        return cell
    }
    
    fileprivate func assignCell(_ cell: UITableViewCell, item: NBRealmBrowsingItem) -> UITableViewCell {
        cell.selectionStyle                  = item.selectionStyle
        cell.accessoryType                   = item.accessoryType
        cell.textLabel?.text                 = item.mainText
        cell.detailTextLabel?.attributedText = item.subText
        return cell
    }
}

// MARK: - NBRealmBrowsingType -
private enum NBRealmBrowsingType {
    
    case classes
    case schema
    case objects
    case detail
    
    /// 画面タイトル
    func title(_ className: String? = nil) -> String {
        switch self {
        case .classes: return "Classes"
        case .schema:  return className ?? ""
        case .objects: return className ?? ""
        case .detail:  return "Detail"
        }
    }
    
    /// ヘッダタイトル
    func headerTitle(_ count: Int) -> String {
        switch self {
        case .classes: return "\(count) Classes"
        case .schema:  return "Schema Of Class"
        case .objects: return "\(count) Objects"
        case .detail:  return "Detail Of Object"
        }
    }
    
    /// セル種別
    var cellStyle: UITableViewCellStyle {
        switch self {
        case .detail: return .value1
        default:      return .subtitle
        }
    }
}

// MARK: - NBRealmBrowsingItem -
private class NBRealmBrowsingItem {
    
    var mainText:      String
    var subText:       NSAttributedString?
    var cellStyle:     UITableViewCellStyle = .subtitle
    var accessoryType: UITableViewCellAccessoryType = .none
    var object:        RmObject?
    
    var selectionStyle: UITableViewCellSelectionStyle {
        return self.accessoryType == .none ? .none : .blue
    }
    
    init(_ text: String, subText: NSAttributedString? = nil) {
        self.mainText = text
        self.subText  = subText
    }
}

private extension NBRealmBrowsingItem {
    
    func detailValue(_ targetObject: RmObject?) -> Any? {
        if let object = targetObject, let ret = object.value(forKey: self.mainText) {
            return ret
        }
        return nil
    }
    
    func detailListInfo(_ targetObject: RmObject?) -> (objects: [RmObject], name: String)? {
        guard let object = targetObject else { return nil }
        
        let list = object.dynamicList(self.mainText)
        return (
            objects: list.map {$0},
            name:    self.property(targetObject)?.objectClassName ?? ""
        )
    }
    
    func property(_ targetObject: RmObject?) -> RmProperty? {
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
    
    fileprivate var items = [NBRealmBrowsingItem]()
    
    fileprivate var realm: RealmSwift.Realm { return try! RealmSwift.Realm() }
    
    fileprivate subscript (i: Int) -> NBRealmBrowsingItem {
        return self.items[i]
    }
    
    fileprivate var count: Int { return self.items.count }
    
    fileprivate func loadClassesItems() {
        self.items = [NBRealmBrowsingItem]()
        for schema in self.realm.schema.objectSchema {
            let item = NBRealmBrowsingItem(schema.className)
            item.accessoryType = .detailDisclosureButton
            self.items.append(item)
        }
    }
    
    fileprivate func loadClassSchemaItems(_ className: String) {
        self.items = [NBRealmBrowsingItem]()
        guard let schema = self.realm.schema[className] else { return }
        
        for property in schema.properties {
            let item = NBRealmBrowsingItem(property.name, subText: NBRealmBrowsingTextUtil.text(property: property))
            self.items.append(item)
        }
    }
    
    fileprivate func loadObjectsItems(_ className: String) {
        self.items = [NBRealmBrowsingItem]()
        
        let objects: [RmObject] = self.realm.dynamicObjects(className).map {$0}
        for object in objects {
            let item = NBRealmBrowsingItem(object.debugDescription)
            item.accessoryType = .disclosureIndicator
            item.object = object
            self.items.append(item)
        }
    }
    
    fileprivate func loadObjectsItems(_ objects: [RmObject]) {
        self.items = [NBRealmBrowsingItem]()
        
        for object in objects {
            let item = NBRealmBrowsingItem(object.debugDescription)
            item.accessoryType = .disclosureIndicator
            item.object = object
            self.items.append(item)
        }
    }
    
    fileprivate func loadDetailItems(_ object: RmObject) {
        self.items = [NBRealmBrowsingItem]()
        
        for property in object.objectSchema.properties {
            let detailValue = object.value(forKey: property.name)
            let item = NBRealmBrowsingItem(property.name, subText: NBRealmBrowsingTextUtil.text(detailValue: detailValue, propertyType: property.type))
            
            item.accessoryType = .none
            if self.selectableForDetail(property.type, detailValue) {
                item.accessoryType = .disclosureIndicator
            }
            self.items.append(item)
        }
    }
    
    fileprivate func selectableForDetail(_ type: RmType, _ value: Any?) -> Bool {
        guard let v = value else { return false }
        switch type {
        case .array, .object: return true
        case .string: return !(v as! String).isEmpty
        default: return false
        }
    }
}

// MARK: - NBRealmBrowsingTextUtil -
private class NBRealmBrowsingTextUtil {}

private extension NBRealmBrowsingTextUtil {
    
    class func text(property: RmProperty) -> NSAttributedString {
        let typeName: String
        switch property.type {
        case .int:            typeName = "Int"
        case .bool:           typeName = "Bool"
        case .float:          typeName = "Float"
        case .double:         typeName = "Double"
        case .string:         typeName = "String"
        case .data:           typeName = "BinaryData"
        case .any:            typeName = "Any: not supported in swift"
        case .date:           typeName = "DateTime"
        case .object:         typeName = "<\(property.objectClassName ?? "?" )>"
        case .array:          typeName = "Array of <\(property.objectClassName ?? "?" )>"
        case .linkingObjects: typeName = "LinkingObjects of <\(property.objectClassName ?? "?" )>"
        }
        
        let ret = self.string(typeName)
        if property.isOptional {
            self.addOptionalText(ret)
        }
        if property.isIndexed {
            self.addInexedText(ret)
        }
        
        return ret
    }
    
    class func text(detailValue any: Any?, propertyType type: RmType) -> NSAttributedString {
        guard let value = any else { return self.nilText }
		
        switch type {
        case .string:
            let ret = self.string("\"\(value)\"")
            self.setColor(ret, color: self.stringTextColor)
            return ret
        case .bool:
            let ret = self.string((value as! Bool) ? "true" : "false")
            self.setColor(ret, color: self.boolTextColor)
            return ret
        case .data:
            return self.string("Binary (\((value as! Data).count) bytes)")
        case .date:
            let df = DateFormatter()
            df.dateFormat = "yyyy/MM/dd HH:mm:ss"
            return self.string(df.string(from: (value as! Date)))
        case .object:
            return self.string(self.nameOfObject(value as! RmObject))
        case .array:
            let list = value as! RmListBase
            let ret = self.string(self.nameOfList(list))
            self.addCountText(ret, count: list.count)
            return ret
        default: return self.string("\(value)")
        }
    }
}

private extension NBRealmBrowsingTextUtil {
    
    class func addOptionalText(_ text: NSMutableAttributedString) {
        let prefix = self.string("Optional( ")
        self.setColor(prefix, color: NBRealmBrowsingTextUtil.optionalTextColor)
        text.insert(prefix, at: 0)
        
        let suffix = self.string(" )")
        self.setColor(suffix, color: NBRealmBrowsingTextUtil.optionalTextColor)
        text.append(suffix)
    }
    
    class func addInexedText(_ text: NSMutableAttributedString) {
        let suffix = self.string(" Indexed")
        self.setColor(suffix, color: NBRealmBrowsingTextUtil.indexedTextColor)
        text.append(suffix)
    }
    
    class func addCountText(_ text: NSMutableAttributedString, count: Int) {
        text.append(self.string(" "))
        
        let suffix = self.string(" \(count) ")
        self.setColor(suffix, color: UIColor.white)
        self.setBackgroundColor(suffix, color: NBRealmBrowsingTextUtil.subTextColor)
        text.append(suffix)
    }
    
    class var nilText: NSAttributedString {
        let ret = self.string("<nil>")
        self.setColor(ret, color: NBRealmBrowsingTextUtil.nilTextColor)
        return ret
    }
}

private extension NBRealmBrowsingTextUtil {
    
    class func nameOfList(_ list: RmListBase) -> String {
        return list._rlmArray.objectClassName
    }
    
    class func nameOfObject(_ object: RmObject) -> String {
        return object.objectSchema.className
    }
}

private extension NBRealmBrowsingTextUtil {
    
    static let mainTextColor     = UIColor(white: 0, alpha: 1)
    static let subTextColor      = UIColor(red:0, green:0.478, blue:1, alpha:1)
    static let stringTextColor   = UIColor(red:0.812, green:0.192, blue:0.145, alpha:1)
    static let boolTextColor     = UIColor(red:0.722, green:0.200, blue:0.631, alpha:1)
    static let nilTextColor      = UIColor(red:0.722, green:0.200, blue:0.631, alpha:1)
    static let optionalTextColor = UIColor(red:0.47, green:0.47, blue:0.47, alpha:1)
    static let indexedTextColor  = UIColor(red:0.984, green:0.42, blue:0.333, alpha:1)
    
    class func string(_ string: String = "") -> NSMutableAttributedString {
        return NSMutableAttributedString(string: string)
    }
    
    class func setColor(_ text: NSMutableAttributedString, color: UIColor) {
        text.addAttributes([NSForegroundColorAttributeName: color], range: NSMakeRange(0, text.length))
    }
    
    class func setBackgroundColor(_ text: NSMutableAttributedString, color: UIColor) {
        text.addAttributes([NSBackgroundColorAttributeName: color], range: NSMakeRange(0, text.length))
    }
}
