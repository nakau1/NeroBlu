// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

/// ハイライト時の設定が簡易にできるボタン
@IBDesignable open class NBHighlightButton: UIButton {
    
    fileprivate var originalBackgroundColor: UIColor?
    fileprivate var originalBorderColor:     UIColor?
    
    /// 通常文字色
    @IBInspectable open var normalTitleColor : UIColor? = nil {
        didSet { let v = self.normalTitleColor
            self.setTitleColor(v, for: UIControlState())
        }
    }
    
    /// 通常背景色
    @IBInspectable open var normalBackgroundColor : UIColor? = nil {
        didSet { let v = self.normalBackgroundColor
            self.originalBackgroundColor = v
            self.backgroundColor         = v
        }
    }
    
    /// 通常枠色
    @IBInspectable open var normalBorderColor: UIColor? {
        didSet { let v = self.normalBorderColor
            self.originalBorderColor = v
            self.borderColor         = v
        }
    }
    
    /// ハイライト時の文字色
    @IBInspectable open var highlightedTitleColor : UIColor? = nil {
        didSet { let v = self.highlightedTitleColor
            self.setTitleColor(v, for: .highlighted)
        }
    }
    
    /// ハイライト時の背景色
    @IBInspectable open var highlightedBackgroundColor : UIColor? = nil
    
    /// ハイライト時の枠線の色
    @IBInspectable open var highlightedBorderColor : UIColor?
    
    override open var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set(v) {
            super.isHighlighted = v
            
            let nb = self.originalBackgroundColor, hb = self.highlightedBackgroundColor, cb = v ? hb : nb
            self.backgroundColor = cb
            
            let nl = self.originalBorderColor, hl = self.highlightedBorderColor, cl = v ? hl : nl
            self.layer.borderColor = cl?.cgColor
        }
    }
}
