// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

/// ハイライト時の設定が簡易にできるボタン
@IBDesignable public class NBHighlightButton: UIButton {
    
    private var originalBackgroundColor: UIColor?
    private var originalBorderColor:     UIColor?
    
    /// 通常文字色
    @IBInspectable public var normalTitleColor : UIColor? = nil {
        didSet { let v = self.normalTitleColor
            self.setTitleColor(v, forState: .Normal)
        }
    }
    
    /// 通常背景色
    @IBInspectable public var normalBackgroundColor : UIColor? = nil {
        didSet { let v = self.normalBackgroundColor
            self.originalBackgroundColor = v
            self.backgroundColor         = v
        }
    }
    
    /// 通常枠色
    @IBInspectable public var normalBorderColor: UIColor? {
        didSet { let v = self.normalBorderColor
            self.originalBorderColor = v
            self.borderColor         = v
        }
    }
    
    /// ハイライト時の文字色
    @IBInspectable public var highlightedTitleColor : UIColor? = nil {
        didSet { let v = self.highlightedTitleColor
            self.setTitleColor(v, forState: .Highlighted)
        }
    }
    
    /// ハイライト時の背景色
    @IBInspectable public var highlightedBackgroundColor : UIColor? = nil
    
    /// ハイライト時の枠線の色
    @IBInspectable public var highlightedBorderColor : UIColor?
    
    override public var highlighted: Bool {
        get {
            return super.highlighted
        }
        set(v) {
            super.highlighted = v
            
            let nb = self.originalBackgroundColor, hb = self.highlightedBackgroundColor, cb = v ? hb : nb
            self.backgroundColor = cb
            
            let nl = self.originalBorderColor, hl = self.highlightedBorderColor, cl = v ? hl : nl
            self.layer.borderColor = cl?.CGColor
        }
    }
}
