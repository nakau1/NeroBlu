// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - UIColor拡張: イニシャライザ -
public extension UIColor {
    
    /// イニシャライザ
    /// - parameter red: R値(0-255)
    /// - parameter green: G値(0-255)
    /// - parameter blue: B値(0-255)
    /// - parameter alpha: アルファ値(0-255)
    public convenience init(_ red: Int, _ green: Int, _ blue: Int, _ alpha: Int = 255) {
        func calc(_ i: Int) -> CGFloat {
            if i < 0 { return 0 } else if 255 < i { return 1 } else { return CGFloat(i) / 255 }
        }
        self.init(red: calc(red), green: calc(green), blue: calc(blue), alpha: calc(alpha))
    }
    
    /// イニシャライザ
    /// - parameter rgb: RGB値
    public convenience init(rgb: Int) {
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >>  8) / 255.0
        let b = CGFloat( rgb & 0x0000FF       ) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    /// イニシャライザ
    /// - parameter colorCode: カラーコード文字列
    public convenience init(colorCode: String) {
        self.init(rgb: UIColor.colorCodeToHex(colorCode))
    }
}

// MARK: - UIColor拡張: ファクトリ -
public extension UIColor {

    /// アルファ値を設定した新しいインスタンスを返す
    /// - parameter alpha: アルファ値
    /// - returns: UIColor
    public func alpha(_ alpha: CGFloat) -> UIColor {
        return self.withAlphaComponent(alpha)
    }
}

// MARK: - UIColor拡張: RGB値 -
public extension UIColor {
    
    /// RGB値
    public var rgb: Int {
        let i = self.intValues
        return (i.red * 0x010000) + (i.green * 0x000100) + i.blue
    }
    
    /// RGB値文字列
    public var rgbString: String {
        var r:CGFloat = -1, g:CGFloat = -1, b:CGFloat = -1, a:CGFloat = -1
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        var ret = ""
        ret += UIColor.hexStringByCGFloat(r)
        ret += UIColor.hexStringByCGFloat(g)
        ret += UIColor.hexStringByCGFloat(b)
        return ret
    }
}

// MARK: - UIColor拡張: カラーコード -
public extension UIColor {
    
    /// カラーコードを整数に変換する
    /// - parameter colorCode: カラーコード
    /// - returns: カラーコードを整数化した値(RGBA値)
    public class func colorCodeToHex(_ colorCode: String) -> Int {
        var colorCode = colorCode
        if colorCode.hasPrefix(self.prefix) {
            colorCode = colorCode.substring(location: 1)
        }
        
        switch colorCode.characters.count {
        case 6: // e.g. 35D24C
            break
        case 3: // e.g. 35D
            let r = colorCode.substring(location: 0, length: 1)
            let g = colorCode.substring(location: 1, length: 1)
            let b = colorCode.substring(location: 2, length: 1)
            colorCode = "\(r)\(r)\(g)\(g)\(b)\(b)"
        default: return self.minHex
        }
        
        if (colorCode as NSString).range(of: "^[a-fA-F0-9]+$", options: .regularExpression).location == NSNotFound {
            return self.minHex
        }
        
        var ret: UInt32 = 0
        Scanner(string: colorCode).scanHexInt32(&ret)
        return Int(ret)
    }
    
    /// 整数をカラーコードに変換する
    /// - parameter hex: 整数
    /// - parameter prefix: 先頭に"#"を付けるどうか
    /// - returns: カラーコード文字列
    public class func hexToColorCode(_ hex: UInt32, withPrefix prefix: Bool = true) -> String {
        var hex = hex
        if hex > UInt32(self.maxHex) {
            hex = UInt32(self.maxHex)
        }
        
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x00FF00) >>  8) / 255.0
        let b = CGFloat((hex & 0x0000FF)      ) / 255.0
        
        var ret = ""
        ret += self.hexStringByCGFloat(r)
        ret += self.hexStringByCGFloat(g)
        ret += self.hexStringByCGFloat(b)
        if prefix {
            ret = self.prefix + ret
        }
        return ret
    }
}

// MARK: - UIColor拡張: 各値タプル取得 -
public extension UIColor {
    
    /// 各RGBAのCGFloat値
    /// - returns: タプル (red: R値(0.0-1.0), green: G値(0.0-1.0), blue: B値(0.0-1.0), alpha: アルファ値(0.0-1.0))
    public var floatValues: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r:CGFloat = -1, g:CGFloat = -1, b:CGFloat = -1, a:CGFloat = -1
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
    
    /// 各RGBAの整数値
    /// - returns: タプル (red: R値(0-255), green: G値(0-255), blue: B値(0-255), alpha: アルファ値(0-255))
    public var intValues: (red: Int, green: Int, blue: Int, alpha: Int) {
        let f = self.floatValues
        return (
            UIColor.intByCGFloat(f.red),
            UIColor.intByCGFloat(f.green),
            UIColor.intByCGFloat(f.blue),
            UIColor.intByCGFloat(f.alpha)
        )
    }
}

// MARK: - UIColor拡張: プライベート -
private extension UIColor {
    
    static let maxHex = 0xFFFFFF
    static let minHex = 0x0
    
    static let prefix = "#"
    
    class func intByCGFloat(_ v: CGFloat) -> Int {
        return Int(round(v * 255.0))
    }
    
    class func hexStringByCGFloat(_ v: CGFloat) -> String {
        let n = self.intByCGFloat(v)
        return NSString(format: "%02X", n) as String
    }
}

// MARK: - 色定義 -
public struct Color {
 
    public static let Black     = UIColor.black
    public static let DarkGray  = UIColor.darkGray
    public static let LightGray = UIColor.lightGray
    public static let White     = UIColor.white
    public static let Gray      = UIColor.gray
    public static let Red       = UIColor.red
    public static let Green     = UIColor.green
    public static let Blue      = UIColor.blue
    public static let Cyan      = UIColor.cyan
    public static let Yellow    = UIColor.yellow
    public static let Magenta   = UIColor.magenta
    public static let Orange    = UIColor.orange
    public static let Purple    = UIColor.purple
    public static let Brown     = UIColor.brown
    public static let Clear     = UIColor.clear
    
    public static var Random: UIColor { return self.Random(0, 255) }
    
    public static var DarkRandom: UIColor { return self.Random(0, 127) }
    
    public static var LightRandom: UIColor { return self.Random(128, 255) }
    
    fileprivate static func Random(_ min: Int, _ max: Int) -> UIColor {
        var c = [Int](); for _ in 0..<3 { c.append(Int.random(min: min, max: max)) }
        return UIColor(c[0], c[1], c[2])
    }
}

// MARK: - テスト色定義 -
public struct TestColor {
    
    fileprivate static let alpha: CGFloat = 0.3
    
    public static let Black     = UIColor.black.alpha(alpha)
    public static let DarkGray  = UIColor.darkGray.alpha(alpha)
    public static let LightGray = UIColor.lightGray.alpha(alpha)
    public static let White     = UIColor.white.alpha(alpha)
    public static let Gray      = UIColor.gray.alpha(alpha)
    public static let Red       = UIColor(rgb: 0xD4161C).alpha(alpha)
    public static let Green     = UIColor(rgb: 0x2AA48E).alpha(alpha)
    public static let Blue      = UIColor(rgb: 0x406FC5).alpha(alpha)
    public static let Cyan      = UIColor(rgb: 0x85D3E0).alpha(alpha)
    public static let Yellow    = UIColor(rgb: 0xfECE56).alpha(alpha)
    public static let Magenta   = UIColor(rgb: 0xBF3484).alpha(alpha)
    public static let Orange    = UIColor(rgb: 0xFD8E25).alpha(alpha)
    public static let Purple    = UIColor(rgb: 0x6F41A7).alpha(alpha)
    public static let Brown     = UIColor(rgb: 0x714E30).alpha(alpha)
    
    public static var Random: UIColor { return Color.Random.alpha(alpha) }
    
    public static var DarkRandom: UIColor { return Color.DarkRandom.alpha(alpha) }
    
    public static var LightRandom: UIColor { return Color.LightRandom.alpha(alpha) }
}
