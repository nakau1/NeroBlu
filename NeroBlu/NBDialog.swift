// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// - MARK: UIAlertAction拡張-
public extension UIAlertAction {
    
    // MARK: コンビニエンスイニシャライザ

    /// イニシャライザ (UIAlertActionStyle.Defaultとして初期化)
    /// - parameter title: タイトル
    /// - parameter handler: 押下時のハンドラ
    public convenience init(_ title: String?, _ handler: VoidClosure? = nil) {
        self.init(title: title, style: .Default, handler: { _ in handler?() })
    }
    
    /// イニシャライザ (UIAlertActionStyle.Destructiveとして初期化)
    /// - parameter title: タイトル
    /// - parameter handler: 押下時のハンドラ
    public convenience init(destructive title: String?, _ handler: VoidClosure? = nil) {
        self.init(title: title, style: .Destructive, handler: { _ in handler?() })
    }
    
    /// イニシャライザ (UIAlertActionStyle.Cancelとして初期化)
    /// - parameter title: タイトル
    /// - parameter handler: 押下時のハンドラ
    public convenience init(cancel title: String?, _ handler: VoidClosure? = nil) {
        self.init(title: title, style: .Cancel, handler: { _ in handler?() })
    }
    
    // MARK: 定型アクション
    
    /// "OK"アクションを返す
    /// - parameter handler: 押下時のハンドラ
    /// - returns: UIAlertAction
    public class func ok(handler: VoidClosure? = nil) -> UIAlertAction {
        return UIAlertAction("OK".localize(), handler)
    }
    
    /// "キャンセル"アクションを返す
    /// - parameter handler: 押下時のハンドラ
    /// - returns: UIAlertAction
    public class func cancel(handler: VoidClosure? = nil) -> UIAlertAction {
        return UIAlertAction(cancel: "Cancel".localize(), handler)
    }
    
    /// "はい"アクションを返す
    /// - parameter handler: 押下時のハンドラ
    /// - returns: UIAlertAction
    public class func yes(handler: VoidClosure? = nil) -> UIAlertAction {
        return UIAlertAction("Yes".localize(), handler)
    }
    
    /// "いいえ"アクションを返す
    /// - parameter handler: 押下時のハンドラ
    /// - returns: UIAlertAction
    public class func no(handler: VoidClosure? = nil) -> UIAlertAction {
        return UIAlertAction(cancel: "No".localize(), handler)
    }
    
    /// "戻る"アクションを返す
    /// - parameter handler: 押下時のハンドラ
    /// - returns: UIAlertAction
    public class func back(handler: VoidClosure? = nil) -> UIAlertAction {
        return UIAlertAction(cancel: "Back".localize(), handler)
    }
    
    /// "次へ"アクションを返す
    /// - parameter handler: 押下時のハンドラ
    /// - returns: UIAlertAction
    public class func next(handler: VoidClosure? = nil) -> UIAlertAction {
        return UIAlertAction("Next".localize(), handler)
    }
}

// MARK: - NBAlert -

/// アラートの表示を行うクラス
public class NBAlert {
    
    /// アラートを表示する
    /// - parameter controller: 表示を行うビューコントローラ
    /// - parameter title: タイトル文言
    /// - parameter message: メッセージ文言
    /// - parameter actions: UIAlertActionの配列
    public class func show(controller: UIViewController, title: String? = nil, message: String?, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        actions.forEach { alert.addAction($0) }
        controller.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: 「OK」のみのアラート
public extension NBAlert {
    
    /// 「OK」のみのアラートを表示する
    /// - parameter controller: 表示を行うビューコントローラ
    /// - parameter title: タイトル文言
    /// - parameter message: メッセージ文言
    /// - parameter handler: アラートのボタン押下時のイベントハンドラ
    public class func show(OK controller: UIViewController, title: String? = nil, message: String?, handler: VoidClosure? = nil) {
        let actions = [
            UIAlertAction.ok() { _ in handler?() },
            ]
        self.show(controller, title: title, message: message, actions: actions)
    }
}

// MARK: 「はい/いいえ」のアラート
public extension NBAlert {
    
    /// 「はい/いいえ」のアラートを表示する
    /// - parameter controller: 表示を行うビューコントローラ
    /// - parameter title: タイトル文言
    /// - parameter message: メッセージ文言
    /// - parameter handler: 「はい」押下時のイベントハンドラ
    public class func show(YesNo controller: UIViewController, title: String? = nil, message: String?, handler: VoidClosure?) {
        let actions = [
            UIAlertAction.no(),
            UIAlertAction.yes(handler),
            ]
        self.show(controller, title: title, message: message, actions: actions)
    }
    
    /// 「はい/いいえ」のアラートを表示する
    /// - parameter controller: 表示を行うビューコントローラ
    /// - parameter title: タイトル文言
    /// - parameter message: メッセージ文言
    /// - parameter yes: 「はい」押下時のイベントハンドラ
    /// - parameter no: 「いいえ」押下時のイベントハンドラ
    public class func show(YesNo controller: UIViewController, title: String? = nil, message: String?, yes: VoidClosure, no: VoidClosure) {
        let actions = [
            UIAlertAction.no(no),
            UIAlertAction.yes(yes),
            ]
        self.show(controller, title: title, message: message, actions: actions)
    }
}

// MARK: 「OK/キャンセル」のアラート
public extension NBAlert {
    
    /// 「OK/キャンセル」のアラートを表示する
    /// - parameter controller: 表示を行うビューコントローラ
    /// - parameter title: タイトル文言
    /// - parameter message: メッセージ文言
    /// - parameter handler: 「OK」押下時のイベントハンドラ
    public class func show(OKCancel controller: UIViewController, title: String? = nil, message: String?, handler: VoidClosure?) {
        let actions = [
            UIAlertAction.cancel(),
            UIAlertAction.ok(handler),
            ]
        self.show(controller, title: title, message: message, actions: actions)
    }
    
    /// 「OK/キャンセル」のアラートを表示する
    /// - parameter controller: 表示を行うビューコントローラ
    /// - parameter title: タイトル文言
    /// - parameter message: メッセージ文言
    /// - parameter ok: 「OK」押下時のイベントハンドラ
    /// - parameter cancel: 「キャンセル」押下時のイベントハンドラ
    public class func show(OKCancel controller: UIViewController, title: String? = nil, message: String?, ok: VoidClosure, cancel: VoidClosure) {
        let actions = [
            UIAlertAction.cancel(cancel),
            UIAlertAction.ok(ok),
            ]
        self.show(controller, title: title, message: message, actions: actions)
    }
}

// MARK: 「OK/戻る」のアラート
public extension NBAlert {
    
    /// 「OK/戻る」のアラートを表示する
    /// - parameter controller: 表示を行うビューコントローラ
    /// - parameter title: タイトル文言
    /// - parameter message: メッセージ文言
    /// - parameter handler: 「OK」押下時のイベントハンドラ
    public class func show(OKBack controller: UIViewController, title: String? = nil, message: String?, handler: VoidClosure?) {
        let actions = [
            UIAlertAction.back(),
            UIAlertAction.ok(handler),
            ]
        self.show(controller, title: title, message: message, actions: actions)
    }
    
    /// 「OK/戻る」のアラートを表示する
    /// - parameter controller: 表示を行うビューコントローラ
    /// - parameter title: タイトル文言
    /// - parameter message: メッセージ文言
    /// - parameter ok: 「OK」押下時のイベントハンドラ
    /// - parameter back: 「戻る」押下時のイベントハンドラ
    public class func show(OKBack controller: UIViewController, title: String? = nil, message: String?, ok: VoidClosure, back: VoidClosure) {
        let actions = [
            UIAlertAction.back(back),
            UIAlertAction.ok(ok),
            ]
        self.show(controller, title: title, message: message, actions: actions)
    }
}

// MARK: - NBActionSheet -

/// アクションシートの表示を行うクラス
public class NBActionSheet {
    
    /// アクションシートを表示する
    /// - parameter controller: 表示を行うビューコントローラ
    /// - parameter title: タイトル文言
    /// - parameter message: メッセージ文言
    /// - parameter actions: UIAlertActionの配列
    public class func show(controller: UIViewController, title: String? = nil, message: String? = nil, actions: [UIAlertAction]) {
        if actions.isEmpty { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        actions.forEach { alert.addAction($0) }
        controller.presentViewController(alert, animated: true, completion: nil)
    }
}
