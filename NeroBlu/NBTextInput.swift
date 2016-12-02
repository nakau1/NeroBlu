// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - UITextField拡張 -
public extension UITextField {
    
    /// プレースホルダの文字色
    @IBInspectable public var placeholderColor : UIColor? {
        get {
            var r : NSRange? = NSMakeRange(0, 1)
            guard
                let ap = self.attributedPlaceholder,
                let ret = ap.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: &r!) as? UIColor
                else {
                    return nil
            }
            return ret
        }
        set(v) {
            guard let color = v, let font = self.font else {
                return
            }
            let attributes: [String : AnyObject] = [
                NSForegroundColorAttributeName : color,
                NSFontAttributeName            : font,
                ]
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: attributes)
        }
    }
}

// MARK: - NBTextFieldManager -

// テキストフィールドを管理するクラス
open class NBTextFieldManager: NSObject, UITextFieldDelegate {

    public typealias ProcessingClosure = (String) -> String // (inputted raw text) -> processed text
    
    public typealias RestrictingClosure = (String) -> Bool   // (inputted raw text) -> is allowed text
    
    public typealias CommittedClosure = (String) -> Void   // (processed text) -> void
    
    /// 管理対象のテキストフィールド
    open fileprivate(set) weak var textField: UITextField!
    
    /// リターンキー押下で値を確定させるかどうか
    open var shouldCommitReturnKey = true
    
    /// 値変更(EditingChanged)が行われる度に入力値の加工を行うかどうか
    /// 日本語入力の際はfalseに設定すると自然な動作をする
    open var shouldProcessEditingChanged = true
    
    /// 許可する文字列長
    open var maxLength: Int? = nil
    
    /// 入力された値に対して加工を行うクロージャ
    open var processing: ProcessingClosure?
    
    /// 入力された値を制限する(使用禁止文字)かどうかを返すクロージャ
    open var restricting: RestrictingClosure?
    
    /// 入力された値を確定した時に呼ばれるクロージャ
    open var committed: CommittedClosure?
    
    /// リターンキー押下時に呼ばれるクロージャ
    open var returned: VoidClosure?
    
    /// イニシャライザ
    /// - parameter textField: 管理対象のテキストフィールド
    public init(_ textField: UITextField) {
        super.init()
        self.textField = textField
        self.textField.delegate = self
        self.textField.addTarget(self, action: #selector(NBTextFieldManager.textFieldDidEditingChanged(_:)), for: .editingChanged)
    }
    
    /// キーボードを閉じてテキストフィールドの値を確定させる
    open func commit() {
        if self.textField.isFirstResponder {
            self.textField.resignFirstResponder()
        } else {
            self.textFieldDidEndEditing(self.textField)
        }
    }
    
    // MARK: UITextFieldDelegate
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.shouldCommitReturnKey {
            self.commit()
        }
        self.returned?()
        return true
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        var text = self.textField.text ?? ""
        if let max = self.maxLength {
            if text.length > max {
                text = text.substring(location: 0, length: max)
            }
        }
        if let processing = self.processing {
            text = processing(text)
        }
        self.committed?(text)
        self.textField.text = text
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let restricting = self.restricting {
            return !restricting(string)
        }
        return true
    }
    
    open func textFieldDidEditingChanged(_ textField: UITextField) {
        if self.shouldProcessEditingChanged {
            self.textFieldDidEndEditing(textField)
        }
    }
}

// MARK: - NBKeyboardEventManager -

// キーボードイベントを管理するクラス
open class NBKeyboardEventManager: NSObject {
    
    public typealias ChangingClosure = (CGFloat) -> Void
    
    /// キーボードの座標変更時のアニメーション実行時に呼ばれるクロージャ
    ///
    /// self.view.layoutIfNeeded() を呼び出すことで綺麗にアニメーションされる
    /// - parameter distance: 座標変更後の画面最下部とキーボードのY座標の距離
    open var changing: ChangingClosure?
    
    fileprivate var keyboardHeight: CGFloat = CGFloat.leastNormalMagnitude
    fileprivate var keyboardY:      CGFloat = CGFloat.leastNormalMagnitude
    
    /// イニシャライザ
    /// - parameter changing: キーボードの座標変更時のアニメーション実行時に呼ばれるクロージャ
    public init(_ changing: ChangingClosure?) {
        super.init()
        self.observeKeyboardEvents(true)
        self.changing = changing
    }
    
    deinit {
        self.observeKeyboardEvents(false)
    }
    
    // MARK: プライベート
    
    fileprivate func observeKeyboardEvents(_ start: Bool) {
        let selector = "willChangeKeyboardFrame:"
        
        if start {
            self.keyboardHeight = CGFloat.leastNormalMagnitude
            self.keyboardY      = CGFloat.leastNormalMagnitude
        }
        
        App.Notify.observe(self, start: start, notificationsAndSelectors:[
            NSNotification.Name.UIKeyboardWillShow.rawValue        : selector,
            NSNotification.Name.UIKeyboardWillChangeFrame.rawValue : selector,
            NSNotification.Name.UIKeyboardWillHide.rawValue        : selector,
            ]
        )
    }

    @objc fileprivate func willChangeKeyboardFrame(_ notify: Notification) {
        guard
            let userInfo   = notify.userInfo,
            let beginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue,
            let endFrame   = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
            let curve      = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber,
            let duration   = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval
            else {
                return
        }

        // 初回のみ
        if self.keyboardHeight == CGFloat.leastNormalMagnitude && self.keyboardY == CGFloat.leastNormalMagnitude {
            self.keyboardHeight = beginFrame.height
            self.keyboardY      = beginFrame.minY
        }
        
        let height = endFrame.height
        let endY   = endFrame.minY
        
        // 別画面でキーボードを表示すると変数yに大きな整数が入ってしまうため
        if endY > App.Dimen.Screen.Height * 2 { return }
        
        // 高さもY座標も変化していない場合は処理抜け
        if self.keyboardHeight == height && self.keyboardY == endY { return }
        
        self.keyboardHeight = height
        self.keyboardY      = endY
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIViewAnimationOptions(rawValue: UInt(curve)),
            animations: {
                let distance = App.Dimen.Screen.Height - endY
                self.changing?(distance)
            },
            completion: nil
        )
    }
}
