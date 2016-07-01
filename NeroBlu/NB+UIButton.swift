// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

extension UIButton {
    
    /// Normal時のタイトル
    public var title: String? {
        get { return self.titleForState(.Normal) }
        set(v) {
            UIView.performWithoutAnimation {
                self.setTitle(v, forState: .Normal)
                self.layoutIfNeeded()
            }
        }
    }
    
    /// Normal時のタイトル色
    public var titleColor: UIColor? {
        get    { return self.titleColorForState(.Normal) }
        set(v) { self.setTitleColor(v, forState: .Normal) }
    }
    
    /// Normal時の属性付きタイトル
    public var attributedTitle: NSAttributedString? {
        get    { return self.attributedTitleForState(.Normal) }
        set(v) { self.setAttributedTitle(v, forState: .Normal) }
    }
    
    /// Normal時のタイトル影色
    public var titleShadowColor: UIColor? {
        get    { return self.titleShadowColorForState(.Normal) }
        set(v) { self.setTitleShadowColor(v, forState: .Normal) }
    }
    
    /// Normal時の画像
    public var image: UIImage? {
        get    { return self.imageForState(.Normal) }
        set(v) { self.setImage(v, forState: .Normal) }
    }
    
    /// Normal時の背景画像
    public var backgroundImage: UIImage? {
        get    { return self.backgroundImageForState(.Normal) }
        set(v) { self.setBackgroundImage(v, forState: .Normal) }
    }
    
    /// タイトルラベルのフォント
    public var titleFont: UIFont? {
        get { return self.titleLabel?.font }
        set(v) {
            if let titleLabel = self.titleLabel {
                titleLabel.font = v
            }
        }
    }
}
