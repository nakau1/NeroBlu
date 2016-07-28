// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NSNotificationCenterの拡張 -
public extension App {
    
    /// サイズ定義
    public class Notify {
        
        /// 通知の監視を開始する
        /// - parameter observer: 監視するオブジェクト
        /// - parameter selectorName: 通知受信時に動作するセレクタ
        /// - parameter name: 通知文字列
        /// - parameter object: 監視対象のオブジェクト
        public class func add(observer: AnyObject, _ selectorName: String, _ name: String, _ object: AnyObject? = nil) {
            self.center.addObserver(observer, selector: Selector(selectorName), name: name, object: object)
        }
        
        /// 通知の監視を終了する
        /// - parameter observer: 監視解除するオブジェクト
        /// - parameter name: 通知文字列
        /// - parameter object: 監視対象のオブジェクト
        public class func remove(observer: AnyObject, _ name: String, _ object: AnyObject? = nil) {
            self.center.removeObserver(observer, name: name, object: object)
        }
        
        /// 渡したNSNotificationオブジェクトに紐づく通知監視を終了する
        /// - parameter observer: 監視するオブジェクト
        /// - parameter notification: NSNotificationオブジェクト
        public class func remove(observer: NSObject, _ notification: NSNotification) {
            self.remove(observer, notification.name, notification.object)
        }
        
        /// 通知の監視開始/終了の設定を一括で行う
        /// - parameter observer: 監視するオブジェクト
        /// - parameter start: 監視の開始または終了
        /// - parameter notificationsAndSelectors: [通知文字列:セレクタ名]形式の辞書
        public class func observe(observer: NSObject, start: Bool, notificationsAndSelectors: [String : String]) {
            for e in notificationsAndSelectors {
                if start {
                    self.add(observer, e.1, e.0)
                } else {
                    self.remove(observer, e.0)
                }
            }
        }
        
        /// 通知を行う
        /// - parameter name: 通知文字列
        /// - parameter object: 通知をするオブジェクト
        /// - parameter userInfo: 通知に含める情報
        public class func post(name: String, _ object: AnyObject? = nil, _ userInfo: [NSObject : AnyObject]? = nil) {
            self.center.postNotificationName(name, object: object, userInfo: userInfo)
        }
        
        private class var center: NSNotificationCenter {
            return NSNotificationCenter.defaultCenter()
        }
    }
}
