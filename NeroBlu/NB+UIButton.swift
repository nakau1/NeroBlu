// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

extension UIButton {
    
    /// Normal時のタイトル
    public var title: String? {
        get { return self.title(for: UIControlState()) }
        set(v) {
            UIView.performWithoutAnimation {
                self.setTitle(v, for: UIControlState())
                self.layoutIfNeeded()
            }
        }
    }
    
    /// Normal時のタイトル色
    public var titleColor: UIColor? {
        get    { return self.titleColor(for: UIControlState()) }
        set(v) { self.setTitleColor(v, for: UIControlState()) }
    }
    
    /// Normal時の属性付きタイトル
    public var attributedTitle: NSAttributedString? {
        get    { return self.attributedTitle(for: UIControlState()) }
        set(v) { self.setAttributedTitle(v, for: UIControlState()) }
    }
    
    /// Normal時のタイトル影色
    public var titleShadowColor: UIColor? {
        get    { return self.titleShadowColor(for: UIControlState()) }
        set(v) { self.setTitleShadowColor(v, for: UIControlState()) }
    }
    
    /// Normal時の画像
    public var image: UIImage? {
        get    { return self.image(for: UIControlState()) }
        set(v) { self.setImage(v, for: UIControlState()) }
    }
    
    /// Normal時の背景画像
    public var backgroundImage: UIImage? {
        get    { return self.backgroundImage(for: UIControlState()) }
        set(v) { self.setBackgroundImage(v, for: UIControlState()) }
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
