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
                let ret = ap.attribute(NSForegroundColorAttributeName, atIndex: 0, effectiveRange: &r!) as? UIColor
                else {
                    return nil
            }
            return ret
        }
        set(v) {
            guard let color = v, font = self.font else {
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
public class NBTextFieldManager: NSObject, UITextFieldDelegate {

    public typealias ProcessingClosure = (String) -> String // (inputted raw text) -> processed text
    
    public typealias RestrictingClosure = (String) -> Bool   // (inputted raw text) -> is allowed text
    
    public typealias CommittedClosure = (String) -> Void   // (processed text) -> void
    
    /// 管理対象のテキストフィールド
    public private(set) weak var textField: UITextField!
    
    /// リターンキー押下で値を確定させるかどうか
    public var shouldCommitReturnKey = true
    
    /// 値変更(EditingChanged)が行われる度に入力値の加工を行うかどうか
    /// 日本語入力の際はfalseに設定すると自然な動作をする
    public var shouldProcessEditingChanged = true
    
    /// 許可する文字列長
    public var maxLength: Int? = nil
    
    /// 入力された値に対して加工を行うクロージャ
    public var processing: ProcessingClosure?
    
    /// 入力された値を制限する(使用禁止文字)かどうかを返すクロージャ
    public var restricting: RestrictingClosure?
    
    /// 入力された値を確定した時に呼ばれるクロージャ
    public var committed: CommittedClosure?
    
    /// リターンキー押下時に呼ばれるクロージャ
    public var returned: VoidClosure?
    
    /// イニシャライザ
    /// - parameter textField: 管理対象のテキストフィールド
    public init(_ textField: UITextField) {
        super.init()
        self.textField = textField
        self.textField.delegate = self
        self.textField.addTarget(self, action: #selector(NBTextFieldManager.textFieldDidEditingChanged(_:)), forControlEvents: .EditingChanged)
    }
    
    /// キーボードを閉じてテキストフィールドの値を確定させる
    public func commit() {
        if self.textField.isFirstResponder() {
            self.textField.resignFirstResponder()
        } else {
            self.textFieldDidEndEditing(self.textField)
        }
    }
    
    // MARK: UITextFieldDelegate
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if self.shouldCommitReturnKey {
            self.commit()
        }
        self.returned?()
        return true
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
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
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let restricting = self.restricting {
            return !restricting(string)
        }
        return true
    }
    
    public func textFieldDidEditingChanged(textField: UITextField) {
        if self.shouldProcessEditingChanged {
            self.textFieldDidEndEditing(textField)
        }
    }
}

// MARK: - NBKeyboardEventManager -

// キーボードイベントを管理するクラス
public class NBKeyboardEventManager: NSObject {
    
    public typealias ChangingClosure = (CGFloat) -> Void
    
    /// キーボードの座標変更時のアニメーション実行時に呼ばれるクロージャ
    ///
    /// self.view.layoutIfNeeded() を呼び出すことで綺麗にアニメーションされる
    /// - parameter distance: 座標変更後の画面最下部とキーボードのY座標の距離
    public var changing: ChangingClosure?
    
    private var keyboardHeight: CGFloat = CGFloat.min
    private var keyboardY:      CGFloat = CGFloat.min
    
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
    
    private func observeKeyboardEvents(start: Bool) {
        let selector = "willChangeKeyboardFrame:"
        
        if start {
            self.keyboardHeight = CGFloat.min
            self.keyboardY      = CGFloat.min
        }
        
        App.Nofify.observe(self, start: start, notificationsAndSelectors:[
            UIKeyboardWillShowNotification        : selector,
            UIKeyboardWillChangeFrameNotification : selector,
            UIKeyboardWillHideNotification        : selector,
            ]
        )
    }

    @objc private func willChangeKeyboardFrame(notify: NSNotification) {
        guard
            let userInfo   = notify.userInfo,
            let beginFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue,
            let endFrame   = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue,
            let curve      = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber,
            let duration   = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval
            else {
                return
        }

        // 初回のみ
        if self.keyboardHeight == CGFloat.min && self.keyboardY == CGFloat.min {
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
        
        UIView.animateWithDuration(
            duration,
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
