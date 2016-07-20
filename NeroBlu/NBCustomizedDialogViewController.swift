// =============================================================================
// NeroBluCustomizeDialog
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBCustomizedDialogOption -

/// NBCustomizedDialogViewControllerの設定オプション構造体
public struct NBCustomizedDialogOption {
    
    /// 背景がタップされた時に閉じるかどうか
    public var cancellable: Bool
    
    /// ダイアログのサイズ
    public var size: CGSize
    
    /// 背景にブラーエフェクトをかけるかどうか
    public var blur = false
    
    /// ブラーエフェクトのスタイル
    public var blurEffectStyle: UIBlurEffectStyle = .Light
    
    /// ビューを自動的に中央に配置するかどうか
    public var automaticCenter = true
    
    /// 背景色
    public var backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.75)
    
    /// 表示時のアニメーション時間
    public var presentationDuration: NSTimeInterval = 0.3
    
    /// 表示時のアニメーションオプション
    public var presentationAnimationOptions: UIViewAnimationOptions = [.TransitionCrossDissolve, .CurveEaseInOut]
    
    /// 表示終了時のアニメーション時間
    public var dismissingDuration: NSTimeInterval = 0.3
    
    /// 表示終了時のアニメーションオプション
    public var dismissingAnimationOptions: UIViewAnimationOptions = [.TransitionCrossDissolve, .CurveEaseInOut]
    
    // MARK: イニシャライザ
    
    /// イニシャライザ
    /// - parameter cancellable: 背景がタップされた時に閉じるかどうか
    /// - parameter size: ダイアログのサイズ
    public init(cancellable: Bool = false, size: CGSize = CGSizeMake(280, 320)) {
        self.cancellable = cancellable
        self.size        = size
    }
}

// MARK: - NBCustomizedDialogViewController -

/// ダイアログとして振る舞うビューコントローラ
public class NBCustomizedDialogViewController: UIViewController {
    
    /// 設定オプション
    public var dialogOption = NBCustomizedDialogOption()
}

private extension NBCustomizedDialogViewController {
    
    private static var dialog: NBCustomizedDialogViewController? = nil
    
    private static var dialogBackground: UIView? = nil
    
    private static var dialogBackgroundTapHandler: DialogBackgroundTapHandler? = nil
    
    // MARK: Inner Class
    
    /// ダイアログ背景のタップ時の処理をするハンドラクラス
    private class DialogBackgroundTapHandler: NSObject, UIGestureRecognizerDelegate {
        
        private var view: UIView
        
        init(view: UIView) {
            self.view = view
        }
        
        @objc func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
            if let touchedView = touch.view {
                if touchedView == self.view {
                    return false
                }
                for v in self.view.subviews {
                    if touchedView.isDescendantOfView(v) {
                        return false
                    }
                }
            }
            return true
        }
    }
}

// MARK: - UIViewController拡張 -
public extension UIViewController {

    /// ダイアログを表示する
    /// - warning: 既に他のダイアログが表示されている場合は実行されません
    /// - parameter dialog: NBCustomizedDialogViewControllerを継承したダイアログビューコントローラ
    /// - parameter completionHandler: 表示完了時の処理
    public func presentDialog<T: NBCustomizedDialogViewController>(dialog: T, completionHandler: ((Void) -> Void)? = nil) {
        
        if NBCustomizedDialogViewController.dialog != nil { return }
        
        let opt = dialog.dialogOption
        
        let mask = opt.blur ? UIVisualEffectView(effect: UIBlurEffect(style: opt.blurEffectStyle)) : UIView()
        mask.frame = UIScreen.mainScreen().bounds
        mask.backgroundColor = opt.backgroundColor
        mask.alpha = 0.0
        
        if opt.automaticCenter {
            let x = (mask.frame.width  - opt.size.width) / 2
            let y = (mask.frame.height - opt.size.height) / 2
            dialog.view.frame = CGRectMake(x, y, opt.size.width, opt.size.height)
        }
        
        if opt.cancellable {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(UIViewController.didTapDialogBackground))
            let handler = NBCustomizedDialogViewController.DialogBackgroundTapHandler(view: self.view)
            gesture.delegate = handler
            NBCustomizedDialogViewController.dialogBackgroundTapHandler = handler
            mask.addGestureRecognizer(gesture)
        }
        
        mask.addSubview(dialog.view)
        NBCustomizedDialogViewController.dialogBackground = mask
        
        NBCustomizedDialogViewController.dialog = dialog
        
        let windows = UIApplication.sharedApplication().windows.reverse()
        for window in windows {
            let isMainScreen  =  window.screen == UIScreen.mainScreen()
            let isVisible     = !window.hidden && window.alpha > 0
            let isNormalLevel =  window.windowLevel == UIWindowLevelNormal
            
            if isMainScreen && isVisible && isNormalLevel {
                window.addSubview(mask)
            }
        }
        
        UIView.transitionWithView(
            mask,
            duration: opt.presentationDuration,
            options:  opt.presentationAnimationOptions,
            animations: {
                mask.alpha = 1.0
            },
            completion: { _ in
                completionHandler?()
            }
        )
    }

    /// 表示中のダイアログを閉じる
    /// - warning: ダイアログが表示されていない場合は何もしません(completionHandlerも走らない)
    /// - parameter completionHandler: 完了時の処理
    public func dismissDialog(completionHandler: ((Void) -> Void)? = nil) {
        
        guard
            let mask   = NBCustomizedDialogViewController.dialogBackground,
            let dialog = NBCustomizedDialogViewController.dialog
            else {
                return
        }
        
        let opt = dialog.dialogOption
        
        UIView.transitionWithView(
            mask,
            duration: opt.dismissingDuration,
            options:  opt.dismissingAnimationOptions,
            animations: {
                mask.alpha = 0.0
            },
            completion: { _ in
                mask.subviews.forEach { $0.removeFromSuperview() }
                NBCustomizedDialogViewController.dialogBackgroundTapHandler = nil
                NBCustomizedDialogViewController.dialogBackground           = nil
                NBCustomizedDialogViewController.dialog                     = nil
                completionHandler?()
            }
        )
    }
    
    @objc private func didTapDialogBackground() {
        self.dismissDialog()
    }
}
