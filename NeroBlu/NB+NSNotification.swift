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
        open class func add(_ observer: Any, _ selectorName: String, _ name: String, _ object: Any? = nil) {
            self.center.addObserver(observer, selector: Selector(selectorName), name: NSNotification.Name(rawValue: name), object: object)
        }
        
        /// 通知の監視を終了する
        /// - parameter observer: 監視解除するオブジェクト
        /// - parameter name: 通知文字列
        /// - parameter object: 監視対象のオブジェクト
        open class func remove(_ observer: Any, _ name: String, _ object: Any? = nil) {
            self.center.removeObserver(observer, name: NSNotification.Name(rawValue: name), object: object)
        }
        
        /// 渡したNSNotificationオブジェクトに紐づく通知監視を終了する
        /// - parameter observer: 監視するオブジェクト
        /// - parameter notification: NSNotificationオブジェクト
        open class func remove(_ observer: Any, _ notification: Notification) {
            self.center.removeObserver(observer, name: notification.name, object: notification.object)
        }
        
        /// 通知の監視開始/終了の設定を一括で行う
        /// - parameter observer: 監視するオブジェクト
        /// - parameter start: 監視の開始または終了
        /// - parameter notificationsAndSelectors: [通知文字列:セレクタ名]形式の辞書
        open class func observe(_ observer: Any, start: Bool, notificationsAndSelectors: [String : String]) {
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
        open class func post(_ name: String, _ object: Any? = nil, _ userInfo: [AnyHashable: Any]? = nil) {
            self.center.post(name: Notification.Name(rawValue: name), object: object, userInfo: userInfo)
        }
        
        fileprivate class var center: NotificationCenter {
            return NotificationCenter.default
        }
    }
}
