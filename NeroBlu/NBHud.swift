// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

public typealias SVMaskType = SVProgressHUDMaskType

// MARK: - NBHud -

/// HUDの表示を行うクラス
public class NBHud {
    
    /// HUDを表示する
    /// - parameter message: メッセージ
    public class func show(message: String? = nil) {
        if SVProgressHUD.isVisible() { return }
        
        self.enabledTouches = false
        if let message = message {
            SVProgressHUD.showWithStatus(message)
        } else {
            SVProgressHUD.show()
        }
    }

    /// 表示していたHUDを閉じる
    public class func hide() {
        if !SVProgressHUD.isVisible() { return }
        
        SVProgressHUD.dismiss()
        self.enabledTouches = true
    }

    /// HUDの設定を変更する
    /// - parameter maskType: マスクタイプ
    /// - parameter backgroundColor: HUD背景色
    /// - parameter foregroundColor: HUDインジケータ色
    /// - parameter font: メッセージのフォント
    /// - parameter ringThickness: インジケータリングの太さ(幅)
    public class func setup(
        maskType maskType: SVMaskType = .None,
        backgroundColor:   UIColor    = UIColor.whiteColor(),
        foregroundColor:   UIColor    = UIColor.blackColor(),
        font:              UIFont     = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline),
        ringThickness:     CGFloat    = 4.0
        )
    {
        SVProgressHUD.setDefaultMaskType(maskType)
        SVProgressHUD.setRingThickness(ringThickness)
        SVProgressHUD.setForegroundColor(foregroundColor)
        SVProgressHUD.setBackgroundColor(backgroundColor)
        SVProgressHUD.setFont(font)
    }
}

private extension NBHud {
    
    private static var enabledTouches: Bool = true {
        didSet {
            let app = UIApplication.sharedApplication()
            if self.enabledTouches {
                app.endIgnoringInteractionEvents()
            } else {
                app.beginIgnoringInteractionEvents()
            }
        }
    }
}
