// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBUserDefaults -

/// UserDefaultsを使用した永続的データを扱うクラス
public class NBUserDefaults: NSObject {
    
    private let ud = NSUserDefaults.standardUserDefaults()
    
    private var domain = ""
    
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
        self.ud.dictionaryRepresentation().filter(filter).forEach(each)
        return ret
    }
}

// MARK: - プライベートメソッド -
private extension NBUserDefaults {
    
    private func registerDomain() {
        self.domain = "@\( NSStringFromClass(self.dynamicType) )"
    }
    
    private func registerDefaults() {
        let dic = self.propertyNames.reduce([String : AnyObject]()) { (dic, key) -> [String : AnyObject] in
            var dic = dic
            dic[self.keyName(key)] = self.valueForKey(key)
            return dic
        }
        self.ud.registerDefaults(dic)
    }
    
    private func setupProperty() {
        self.propertyNames.forEach { propertyName in
            self.setValue(self.ud.objectForKey(self.keyName(propertyName)), forKey: propertyName)
        }
    }
    
    private func observe(start: Bool) {
        self.propertyNames.forEach { propertyName in
            if start {
                self.addObserver(self, forKeyPath: propertyName, options: .New, context: nil)
            } else {
                self.removeObserver(self, forKeyPath: propertyName)
            }
        }
    }
    
    private func keyName(name: String) -> String {
        return "\(name)\(self.domain)"
    }
    
    var propertyNames: [String] {
        return Mirror(reflecting: self).children.flatMap { $0.label }.filter {
            !self.dynamicType.ignoredProperties().contains($0)
        }
    }
}

// MARK: - KVO -
public extension NBUserDefaults {
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let keyPath = keyPath else { return }
        self.ud.setObject(change?["new"], forKey: self.keyName(keyPath))
        self.ud.synchronize()
    }
}

// MARK - App拡張 -
public extension App {
    
    /// 設定(UserDefaults)定義
    public struct Config {}
}
