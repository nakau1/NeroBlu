// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBCellBackgroundViewOptions -

/// NBCellBackgroundViewのオプション
public struct NBCellBackgroundViewOptions {
    
    /// イニシャライザ
    /// - parameter highlightedBackgroundColor: ハイライト時の背景色
    /// - parameter separatorColor: セパレータ色
    public init(highlightedBackgroundColor: UIColor? = nil, separatorColor: UIColor? = nil) {
        if let color = highlightedBackgroundColor { self.highlightedBackgroundColor = color }
        if let color = separatorColor             { self.separatorColor             = color }
    }
    
    /// ハイライト時の背景色
    public var highlightedBackgroundColor = UIColor(rgb: 0x68C1FD).alpha(0.5)
    
    /// 通常時の背景色
    public var backgroundColor = UIColor.whiteColor()
    
    /// セパレータ色
    public var separatorColor = UIColor(rgb: 0xC8C7CC)
    
    /// セパレータの太さ
    public var separatorWidth: CGFloat = 0.5
    
    /// セパレータの左側マージン値
    public var separatorLeftMargin: CGFloat = 20.0
    
    /// セパレータの右側マージン値
    public var separatorRightMargin: CGFloat = 0.0
}

// MARK: - NBCellBackgroundView -

/// テーブルビュー/コレクションビューの主にハイライトを目的としたセル背景用のビュークラス
public class NBCellBackgroundView: UIView {
    
    private var highlighted = false
    
    private var options: NBCellBackgroundViewOptions!
    
    // private
    private convenience init(highlighted: Bool, options: NBCellBackgroundViewOptions) {
        self.init()
        self.highlighted = highlighted
        self.options     = options
    }
    
    override public func drawRect(rect: CGRect) {
        let opt = self.options
        let context = UIGraphicsGetCurrentContext()
        
        opt.backgroundColor.setFill(); UIRectFill(rect)
        
        CGContextMoveToPoint(context, 0, 0)
        CGContextSetFillColorWithColor(context, self.properBackgroundColor(opt).CGColor)
        CGContextFillRect(context, rect)
        
        let minX: CGFloat = opt.separatorLeftMargin
        let maxX: CGFloat = rect.maxX - opt.separatorRightMargin
        let y:    CGFloat = rect.maxY - opt.separatorWidth / 2
        CGContextSetStrokeColorWithColor(context, opt.separatorColor.CGColor)
        CGContextSetLineWidth(context, opt.separatorWidth)
        CGContextMoveToPoint(context, minX, y)
        CGContextAddLineToPoint(context, maxX, y)
        CGContextStrokePath(context)
    }
    
    private func properBackgroundColor(opt: NBCellBackgroundViewOptions) -> UIColor {
        return self.highlighted ? opt.highlightedBackgroundColor : opt.backgroundColor
    }
}

// MARK: NBCellBackgroundView
public extension NBCellBackgroundView {
    
    /// テーブルビューに対してNBCellBackgroundViewを使用するために既存セパレータを消すなどの適切な設定を行う
    /// - parameter tableView: テーブルビュー
    public static func prepareTableView(tableView: UITableView) {
        if tableView.style == .Plain {
            tableView.separatorStyle = .None
        }
    }
}

// MARK: - UITableViewCell拡張 -
public extension UITableViewCell {
    
    /// テーブルセルに背景ビューをセットする
    /// - parameter highlightedBackgroundColor: ハイライト時の背景色
    /// - parameter separatorColor: セパレータ色
    public func setCellBackgrounView(highlightedBackgroundColor: UIColor, separatorColor: UIColor? = nil) {
        let opt = NBCellBackgroundViewOptions(highlightedBackgroundColor: highlightedBackgroundColor, separatorColor: separatorColor)
        self.setCellBackgrounView(options: opt)
    }
    
    /// テーブルセルに背景ビューをセットする
    /// - parameter options: オプション
    public func setCellBackgrounView(options options: NBCellBackgroundViewOptions = NBCellBackgroundViewOptions()) {
        self.selectionStyle         = .Default
        self.backgroundView         = NBCellBackgroundView(highlighted: false, options: options)
        self.selectedBackgroundView = NBCellBackgroundView(highlighted: true,  options: options)
    }
}

// MARK: - UICollectionViewCell拡張 -
public extension UICollectionViewCell {
    
    /// テーブルセルに背景ビューをセットする
    /// - parameter highlightedBackgroundColor: ハイライト時の背景色
    /// - parameter separatorColor: セパレータ色
    public func setCellBackgrounView(highlightedBackgroundColor: UIColor, separatorColor: UIColor? = nil) {
        let opt = NBCellBackgroundViewOptions(highlightedBackgroundColor: highlightedBackgroundColor, separatorColor: separatorColor)
        self.setCellBackgrounView(options: opt)
    }
    
    /// テーブルセルに背景ビューをセットする
    /// - parameter options: オプション
    public func setCellBackgrounView(options options: NBCellBackgroundViewOptions = NBCellBackgroundViewOptions()) {
        self.backgroundView         = NBCellBackgroundView(highlighted: false, options: options)
        self.selectedBackgroundView = NBCellBackgroundView(highlighted: true,  options: options)
    }
}

