// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBUserDefaults -

/// UserDefaultsを使用した永続的データを扱うクラス
open class NBUserDefaults: NSObject {
    
    fileprivate let ud = UserDefaults.standard
    
    fileprivate var domain = ""
    
    public override init() {
        super.init()
        
        self.registerDomain()
        self.registerDefaults()
        self.setupProperty()
        self.observe(true)
    }
    
    deinit {
        self.observe(false)
    }
}

// MARK: - 設定 -
public extension NBUserDefaults {
    
    /// 永続的データとして扱わないプロパティ名を返却する
    /// - returns: 永続的データとして扱わないプロパティ名の配列
    class func ignoredProperties() -> [String] { return [] }
}

// MARK: - パブリックメソッド -
public extension NBUserDefaults {
    
    /// 現在の保存内容を辞書形式で返却する
    /// - returns: 現在の保存内容(キー:値)
    func currentDefaults() -> [String : AnyObject] {
        var ret = [String : AnyObject]()
        let filter = { (key: String, val: AnyObject) -> Bool in key.hasSuffix(self.domain) }
        let each   = { (key: String, val: AnyObject) -> Void in ret[key] = val }
        self.ud.dictionaryRepresentation().filter(filter as! ((key: String, value: Any)) -> Bool).forEach(each as! ((key: String, value: Any)) -> Void)
        return ret
    }
}

// MARK: - プライベートメソッド -
private extension NBUserDefaults {
    
    func registerDomain() {
        self.domain = "@\( NSStringFromClass(type(of: self)) )"
    }
    
    func registerDefaults() {
        let dic = self.propertyNames.reduce([String : AnyObject]()) { (dic, key) -> [String : AnyObject] in
            var dic = dic
            dic[self.keyName(key)] = self.value(forKey: key) as AnyObject?
            return dic
        }
        self.ud.register(defaults: dic)
    }
    
    func setupProperty() {
        self.propertyNames.forEach { propertyName in
            self.setValue(self.ud.object(forKey: self.keyName(propertyName)), forKey: propertyName)
        }
    }
    
    func observe(_ start: Bool) {
        self.propertyNames.forEach { propertyName in
            if start {
                self.addObserver(self, forKeyPath: propertyName, options: .new, context: nil)
            } else {
                self.removeObserver(self, forKeyPath: propertyName)
            }
        }
    }
    
    func keyName(_ name: String) -> String {
        return "\(name)\(self.domain)"
    }
    
    var propertyNames: [String] {
        return Mirror(reflecting: self).children.flatMap { $0.label }.filter {
            !type(of: self).ignoredProperties().contains($0)
        }
    }
}

// MARK: - KVO -
public extension NBUserDefaults {
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        self.ud.set(change?["new"], forKey: self.keyName(keyPath))
        self.ud.synchronize()
    }
}

// MARK - App拡張 -
public extension App {
    
    /// 設定(UserDefaults)定義
    public struct Config {}
}
