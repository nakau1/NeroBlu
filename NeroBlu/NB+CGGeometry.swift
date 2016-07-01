// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

/// CGRectZeroの短縮形
public let cr0 = CGRectZero

/// CGPointZeroの短縮形
public let cp0 = CGPointZero

/// CGSizeZeroの短縮形
public let cs0 = CGSizeZero

// MARK: - CGRect拡張 -
public extension CGRect {
    
    // MARK: 値の設定/取得
    
    /// 値を設定する
    /// - parameter x: X座標
    /// - parameter y: Y座標
    /// - parameter w: 幅
    /// - parameter h: 高さ
    public mutating func update<T>(x x: T? = nil, y: T? = nil, w: T? = nil, h: T? = nil) {
        self.origin = CGPointMake(
            (x != nil) ? CGFloat.cast(x!) : self.origin.x,
            (y != nil) ? CGFloat.cast(y!) : self.origin.y
        )
        self.size = CGSizeMake(
            (w != nil) ? CGFloat.cast(w!) : self.size.width,
            (h != nil) ? CGFloat.cast(h!) : self.size.height
        )
    }
    
    /// サイズをCGSizeZeroに変更する
    /// - returns: 変更後のCGRect
    public mutating func toSizeZero() -> CGRect {
        self.size = CGSizeZero
        return self
    }
    
    /// 位置をCGPointZeroに変更する
    /// - returns: 変更後のCGRect
    public mutating func toOriginZero() -> CGRect {
        self.origin = CGPointZero
        return self
    }
    
    /// CGSize (sizeのエイリアス)
    public var s: CGSize {
        get    { return self.size }
        set(v) { self.size = v }
    }
    
    /// CGPoint (originのエイリアス)
    public var o: CGPoint {
        get    { return self.origin }
        set(v) { self.origin = v }
    }
    
    /// CGPoint (originのエイリアス)
    public var p: CGPoint {
        get    { return self.origin }
        set(v) { self.origin = v }
    }
    
    /// X座標 (leftのエイリアス)
    public var x: CGFloat {
        get    { return self.origin.x }
        set(v) { self.update(x: v) }
    }
    
    /// Y座標 (topのエイリアス)
    public var y: CGFloat {
        get    { return self.origin.y }
        set(v) { self.update(y: v) }
    }
    
    /// 幅 (widthのエイリアス)
    public var w: CGFloat {
        get    { return self.size.width }
        set(v) { self.update(w: v) }
    }
    
    /// 高さ (heightのエイリアス)
    public var h: CGFloat {
        get    { return self.size.height }
        set(v) { self.update(h: v) }
    }
    
    /// 右端座標 (rightのエイリアス)
    public var r: CGFloat {
        get    { return self.maxX }
        set(v) { self.update(w: v - self.x) }
    }
    
    /// 下端座標 (bottomのエイリアス)
    public var b: CGFloat {
        get    { return self.maxY }
        set(v) { self.update(h: v - self.y) }
    }
    
    /// 水平中央座標 (centerXのエイリアス)
    public var cx: CGFloat {
        get    { return self.midX }
        set(v) { self.update(x: v - (self.width / 2)) }
    }
    
    /// 垂直中央座標 (centerYのエイリアス)
    public var cy: CGFloat {
        get    { return self.midY }
        set(v) { self.update(y: v - (self.height / 2)) }
    }
    
    /// X座標
    public var left: CGFloat { get { return self.x } set(v) { self.x = v } }
    
    /// Y座標
    public var top: CGFloat { get { return self.y } set(v) { self.y = v } }

    /// 右端座標
    public var right: CGFloat { get { return self.r } set(v) { self.r = v } }
    
    /// 下端座標
    public var bottom: CGFloat { get { return self.b } set(v) { self.b = v } }
    
    /// 水平中央座標
    public var centerX: CGFloat { get { return self.cx } set(v) { self.cx = v } }
    
    /// 垂直中央座標
    public var centerY: CGFloat { get { return self.cy } set(v) { self.cy = v } }
    
    // MARK: イニシャライザ
    
    /// イニシャライザ
    /// - parameter x: X座標
    /// - parameter y: Y座標
    /// - parameter width: 幅
    /// - parameter height: 高さ
    public init<T>(_ x: T, _ y: T, _ width: T, _ height: T) {
        self.origin = CGPoint(x: CGFloat.cast(x), y: CGFloat.cast(y))
        self.size   = CGSize(width: CGFloat.cast(width), height: CGFloat.cast(height))
    }
    
    /// イニシャライザ
    /// - parameter x: X座標
    /// - parameter y: Y座標
    /// - parameter size: サイズ
    public init<T>(x: T, y: T, size: CGSize = CGSizeZero) {
        self.origin = CGPoint(x: CGFloat.cast(x), y: CGFloat.cast(y))
        self.size   = size
    }
    
    /// イニシャライザ
    /// - parameter width: 幅
    /// - parameter height: 高さ
    /// - parameter origin: 位置
    public init<T>(width: T, height: T, origin: CGPoint = CGPointZero) {
        self.origin = origin
        self.size   = CGSize(width: CGFloat.cast(width), height: CGFloat.cast(height))
    }
    
    /// イニシャライザ
    /// - parameter w: 幅
    /// - parameter h: 高さ
    public init<T>(_ w: T, _ h: T) {
        self.init(width: w, height: h)
    }
    
    /// イニシャライザ
    /// - parameter size: サイズ
    public init(size: CGSize) {
        self.origin = CGPointZero
        self.size   = size
    }

    /// イニシャライザ
    /// - parameter orgin: 位置
    public init(origin: CGPoint) {
        self.origin = origin
        self.size   = CGSizeZero
    }
    
    /// イニシャライザ
    /// - parameter center: 中央位置
    /// - parameter size: サイズ
    public init(center: CGPoint, size: CGSize) {
        self.size = size
        self.origin = CGPointZero
        self.centerX = center.x
        self.centerY = center.y
    }
}

// MARK: - CGSize拡張 -
public extension CGSize {
    
    // MARK: 値の設定/取得
    
    /// 幅 (widthのエイリアス)
    public var w: CGFloat {
        get    { return self.width }
        set(v) { self.width = v }
    }
    
    /// 高さ (heightのエイリアス)
    public var h: CGFloat {
        get    { return self.height }
        set(v) { self.height = v }
    }
    
    // MARK: 値の反転
    
    /// 幅と高さを入れ替える
    /// - returns: 自身
    public mutating func reverse() -> CGSize {
        let w = self.width, h = self.height
        self.width = h; self.height = w
        return self
    }
    
    // MARK: イニシャライザ
    
    /// イニシャライザ
    /// - parameter width: 幅
    /// - parameter height: 高さ
    public init<T>(_ w: T, _ h: T) {
        self.init(width: CGFloat.cast(w), height: CGFloat.cast(h))
    }
    
    /// イニシャライザ(正方形)
    /// - parameter width: 正方形一辺の幅
    public init<T>(_ width: T) {
        let widthOfSide = CGFloat.cast(width)
        self.init(width: widthOfSide, height: widthOfSide)
    }
}

// MARK: - CGPoint拡張 -
public extension CGPoint {
    
    // MARK: 値の反転
    
    /// X座標とY座標を入れ替える
    /// - returns: 自身
    public mutating func reverse() -> CGPoint {
        let x = self.x, y = self.y
        self.x = y; self.y = x
        return self
    }
    
    // MARK: イニシャライザ
    
    /// イニシャライザ
    /// - parameter x: X座標
    /// - parameter y: Y座標
    public init<T>(_ x: T, _ y: T) {
        self.init(x: CGFloat.cast(x), y: CGFloat.cast(y))
    }
}

// MARK: - CGRect作成関数 -

/// CGRectを作成する
/// - parameter x: X座標
/// - parameter y: Y座標
/// - parameter width: 幅
/// - parameter height: 高さ
/// - returns: CGRect
public func cr<T>(x: T, _ y: T, _ width: T, _ height: T) -> CGRect {
    return CGRect(x, y, width, height)
}

/// CGRectを作成する
/// - parameter x: X座標
/// - parameter y: Y座標
/// - parameter size: サイズ
/// - returns: CGRect
public func cr<T>(x x: T, y: T, size: CGSize = CGSizeZero) -> CGRect {
    return CGRect(x: x, y: y, size: size)
}

/// CGRectを作成する
/// - parameter width: 幅
/// - parameter height: 高さ
/// - parameter origin: 位置
/// - returns: CGRect
public func cr<T>(width width: T, height: T, origin: CGPoint = CGPointZero) -> CGRect {
    return CGRect(width: width, height: height, origin: origin)
}

/// CGRectを作成する
/// - parameter w: 幅
/// - parameter h: 高さ
/// - returns: CGRect
public func cr<T>(w: T, _ h: T) -> CGRect {
    return CGRect(w, h)
}

/// CGRectを作成する
/// - parameter size: サイズ
/// - returns: CGRect
public func cr(size: CGSize) -> CGRect {
    return CGRect(size: size)
}

/// CGRectを作成する
/// - parameter orgin: 位置
/// - returns: CGRect
public func cr(origin: CGPoint) -> CGRect {
    return CGRect(origin: origin)
}

/// CGRectを作成する
/// - parameter origin: 位置
/// - parameter size: サイズ
/// - returns: CGRect
public func cr(origin origin: CGPoint, size: CGSize) -> CGRect {
    return CGRect(origin: origin, size: size)
}

/// CGRectを作成する
/// - parameter center: 中央位置
/// - parameter size: サイズ
/// - returns: CGRect
public func cr(center center: CGPoint, size: CGSize) -> CGRect {
    return CGRect(center: center, size: size)
}

// MARK: - CGPoint作成関数 -

/// CGPointを作成する
/// - parameter x: X座標
/// - parameter y: Y座標
/// - returns: CGPoint
public func cp<T>(x: T, _ y: T) -> CGPoint {
    return CGPoint(x, y)
}

// MARK: - CGSize作成関数 -

/// CGSizeを作成する
/// - parameter width: 幅
/// - parameter height: 高さ
/// - returns: CGSize
public func cs<T>(width: T, _ height: T) -> CGSize {
    return CGSize(width, height)
}
