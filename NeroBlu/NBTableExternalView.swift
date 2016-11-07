// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBTableExternalViewOptions -

/// NBTableExternalViewのオプション
public struct NBTableExternalViewOptions {
    
    /// 文字色
    public var textColor = UIColor(rgb: 0x94949A)
    
    /// 背景色
    public var backgroundColor = UIColor(rgb: 0xEFEFF4)
    
    /// フォント
    public var font = UIFont.systemFont(ofSize: 16.0)
    
    /// セパレータの左側マージン値
    public var insets = UIEdgeInsets(top: 4.0, left: 20.0, bottom: 4.0, right: 12.0)
    
    /// テキスト揃え
    public var align = NSTextAlignment.left
}

// MARK: - NBTableExternalView -

/// テーブルビュー/コレクションビューの主にハイライトを目的としたセル背景用のビュークラス
open class NBTableExternalView: UIView {
    
    /// イニシャライザ
    /// - parameter text: テキスト
    /// - parameter tableView: テーブルビューの参照
    /// - parameter opt: NBTableExternalViewのオプション
    public convenience init(text: String, tableView: UITableView, opt: NBTableExternalViewOptions = NBTableExternalViewOptions()) {
        self.init()
        self.backgroundColor = opt.backgroundColor
        
        let max = tableView.frame.width - (opt.insets.left + opt.insets.right)
        
        let label = UILabel()
        label.text          = text
        label.numberOfLines = 0
        label.textAlignment = opt.align
        label.font          = opt.font
        label.textColor     = opt.textColor
        
        var labelFrame = cr0
        labelFrame.size.width  = max
        labelFrame.size.height = label.sizeThatFits(cs(max, CGFloat.greatestFiniteMagnitude)).height
        labelFrame.origin.x    = opt.insets.left
        labelFrame.origin.y    = opt.insets.top
        
        label.frame = labelFrame
        self.addSubview(label)
        
        var selfFrame = cr0
        selfFrame.size.width  = opt.insets.left + labelFrame.width  + opt.insets.right
        selfFrame.size.height = opt.insets.top  + labelFrame.height + opt.insets.bottom
        
        self.frame = selfFrame
    }
}
