// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - String拡張: 文字列長 -
public extension String {
    
    /// 文字列長
    public var length: Int { return self.characters.count }
}

// MARK: - String拡張: ローカライズ -
public extension String {
    
    /// 自身をローカライズのキーとしてローカライズされた文字列を取得する
    /// - parameter comment: コメント
    /// - returns: ローカライズされた文字列
    public func localize(_ comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}


// MARK: - String拡張: フォーマット -
public extension String {
    
    /// 自身をフォーマットとしてフォーマット化された文字列を取得する
    /// - parameter args: 引数
    /// - returns: フォーマット化された文字列
    public func format(_ args: CVarArg...) -> String {
        let s = NSString(format: self, arguments: getVaList(args))
        return s as String
    }
}

// MARK: - String拡張: Objective-C連携 -
public extension String {
    
    /// NSStringにキャストした新しい文字列オブジェクト
    public var ns: NSString { return NSString(string: self) }
    
    /// NSMutableStringにキャストした新しい文字列オブジェクト
    public var mutable: NSMutableString { return NSMutableString(string: self) }
}

// MARK: - String拡張: 空文字代替返還 -
extension String {
    
    /// 空文字列であればnilを返す
    public var emptyToNil: String? {
        return self.isEmpty ? nil : self
    }
    
    /// 空文字列であれば指定の代替文字を返す
    /// - parameter substitute: 代替文字
    /// - returns: 空文字列の場合は代替文字、それ以外は自身を返す
    public func emptyTo(_ substitute: String) -> String {
        return self.isEmpty ? substitute : self
    }
}

// MARK: - String拡張: 文字列置換 -
extension String {
    
    /// 文字列置換を行う
    /// - parameter search: 検索する文字
    /// - parameter replacement: 置換する文字
    /// - returns: 置換された文字列
    public func replace(_ search: String, _ replacement: String) -> String {
        return self.replacingOccurrences(of: search, with: replacement, options: NSString.CompareOptions(), range: nil)
    }
    
    /// 指定した範囲の文字列置換を行う
    /// - parameter range: 範囲
    /// - parameter replacement: 置換する文字
    /// - returns: 置換された文字列
    public func replace(_ range: NSRange, _ replacement: String) -> String {
        return self.ns.replacingCharacters(in: range, with: replacement)
    }
}

// MARK: - String拡張: 文字列分割 -
extension String {
    
    /// 文字列分割を行う
    /// - parameter separator: 分割に使用するセパレータ文字
    /// - parameter allowEmpty: 空文字を許可するかどうか。falseにすると分割された結果が空文字だった場合は配列に入りません
    /// - returns: 分割された結果の文字列配列
    public func split(_ separator: String, allowEmpty: Bool = true) -> [String] {
        let ret = self.components(separatedBy: separator)
        if allowEmpty {
            return ret
        }
        return ret.filter { !$0.isEmpty }
    }
    
    /// 改行コードで文字列分割を行う
    /// - parameter allowEmpty: 空文字を許可するかどうか
    /// - returns: 分割された結果の文字列配列
    public func splitByCarriageReturn(allowEmpty allow: Bool = true) -> [String] {
        return self.split("\r\n", allowEmpty: allow)
    }
    
    /// カンマで文字列分割を行う
    /// - parameter allowEmpty: 空文字を許可するかどうか
    /// - returns: 分割された結果の文字列配列
    public func splitByComma(allowEmpty allow: Bool = true) -> [String] {
        return self.split(",", allowEmpty: allow)
    }
    
    /// ドットで文字列分割を行う
    /// - parameter allowEmpty: 空文字を許可するかどうか
    /// - returns: 分割された結果の文字列配列
    public func splitByDot(allowEmpty allow: Bool = true) -> [String] {
        return self.split(".", allowEmpty: allow)
    }
    
    /// スラッシュで文字列分割を行う
    /// - parameter allowEmpty: 空文字を許可するかどうか
    /// - returns: 分割された結果の文字列配列
    public func splitBySlash(allowEmpty allow: Bool = true) -> [String] {
        return self.split("/", allowEmpty: allow)
    }
    
    /// 空白文字で文字列分割を行う
    /// - parameter allowEmpty: 空文字を許可するかどうか
    /// - returns: 分割された結果の文字列配列
    public func splitByWhitespace(allowEmpty allow: Bool = true) -> [String] {
        return self.split(" ", allowEmpty: allow)
    }
}

// MARK: - String拡張: トリム -
extension String {
    
    /// 文字列のトリムを行う
    ///
    ///     " hello world  ".trim() // "hello world"
    ///
    ///     // 以下のようにすると改行コードもトリムできる
    ///     "hello world\n".trim(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    ///
    /// - parameter characterSet: トリムに使用するキャラクタセット(省略すると半角スペースのみがトリム対象となる)
    /// - returns: トリムされた文字列
    public func trim(_ characterSet: CharacterSet = .whitespaces) -> String {
        return self.trimmingCharacters(in: characterSet)
    }
}

// MARK: - String拡張: 部分取得 -
extension String {
    
    /// 文字列の部分取得を行う
    ///
    ///     "abcdef".substring(location: 1)              // bcdef
    ///     "abcdef".substring(location: 1, length: 3)   // bcd
    ///     "abcdef".substring(location: 0, length: 4)   // abcd
    ///     "abcdef".substring(location: 0, length: 8)   // abcdef
    ///     "abcdef".substring(location: -1, length: 1)  // f
    ///     "abcdef".substring(location: -1)             // f
    ///     "abcdef".substring(location: -2)             // ef
    ///     "abcdef".substring(location: -3, length: 1)  // d
    ///     "abcdef".substring(location: 0, length: -1)  // abcde
    ///     "abcdef".substring(location: 2, length: -1)  // cde
    ///     "abcdef".substring(location: 4, length: -4)  //
    ///     "abcdef".substring(location: -3, length: -1) // de
    /// - parameter start: 開始インデックス
    /// - parameter length: 文字列長
    /// - returns: 部分取得された文字列
    public func substring(location: Int, length: Int? = nil) -> String {
        let strlen = self.length
        let max = strlen - 1, min = strlen * -1
        
        var s = location
        
        if s < min || max < s {
            return ""
        } else if s < 0 {
            s = strlen + s
        }
        
        let len = length ?? strlen
        var e = 0
        
        if len > 0 {
            e = s + (len - 1)
            e = (e > max) ? max : e
        } else {
            e = max + len
        }
        
        return self.substring(startIndex: s, endIndex: e)
    }
    
    /// 文字列の部分取得を行う
    ///
    ///     "hello".substringWithRange(start: 2, end: 3) // "ll"
    /// - parameter start: 開始インデックス
    /// - parameter end: 終了インデックス
    /// - returns: 部分取得された文字列
    public func substring(startIndex start: Int, endIndex end: Int) -> String {
        let max = self.length - 1
        var s = start, e = end
        if max < 0 || e < s || max < s {
            return ""
        } else if s < 0 {
            s = 0
        } else if e < 0 {
            e = 0
        } else if max < e {
            e = max
        }
        let range = Range(self.characters.index(self.startIndex, offsetBy: s)...self.characters.index(self.startIndex, offsetBy: e))
        return self.substring(with: range)
    }
    
    /// 文字列の部分取得を行う
    /// - parameter range: 範囲
    /// - returns: 部分取得された文字列
    public func substring(range: NSRange) -> String {
        return self.substring(location: range.location, length: range.length)
    }
}


// MARK: - String拡張: 正規表現 -
extension String {
    
    /// 文字列から正規表現パターンに合った文字列を配列で返す
    /// - parameter pattern: 正規表現パターン
    /// - parameter regularExpressionOptions: 正規表現オプション
    /// - parameter matchingOptions: 正規表現マッチングオプション
    /// - returns: 正規表現パターンに合った文字列の配列
    public func matchedStrings(_ pattern: String, regularExpressionOptions: NSRegularExpression.Options? = nil, matchingOptions: NSRegularExpression.MatchingOptions? = nil) -> [String] {
        
        guard let regExp = try? NSRegularExpression(
            pattern: pattern,
            options: regularExpressionOptions ?? NSRegularExpression.Options()
            ) else {
                return []
        }
        
        let results = regExp.matches(
            in: self,
            options: matchingOptions ?? NSRegularExpression.MatchingOptions(),
            range:   NSMakeRange(0, self.length)
        )
        var ret = [String]()
        for result in results {
            ret.append(self.substring(range: result.rangeAt(0)))
        }
        return ret
    }
    
    /// 文字列から正規表現パターンに合った最初の文字列を返す
    /// - parameter pattern: 正規表現パターン
    /// - parameter regularExpressionOptions: 正規表現オプション
    /// - parameter matchingOptions: 正規表現マッチングオプション
    /// - returns: 正規表現パターンに合った最初の文字列
    public func matchedString(_ pattern: String, regularExpressionOptions: NSRegularExpression.Options? = nil, matchingOptions: NSRegularExpression.MatchingOptions? = nil) -> String? {
        return self.matchedStrings(pattern, regularExpressionOptions: regularExpressionOptions, matchingOptions: matchingOptions).first
    }
    
    /// 指定した正規表現パターンに合うかどうかを返す
    /// - parameter pattern: 正規表現パターン
    /// - returns: 文字列が正規表現パターンに合うかどうか
    public func isMatched(_ pattern: String) -> Bool {
        let range = self.ns.range(of: pattern, options: .regularExpression)
        return range.location != NSNotFound
    }
    
    /// 文字列から正規表現パターンに合った箇所を置換した文字列を返す
    /// - parameter pattern: 正規表現パターン
    /// - parameter replacement: 置換する文字
    /// - parameter regularExpressionOptions: 正規表現オプション
    /// - parameter matchingOptions: 正規表現マッチングオプション
    /// - returns: 置換した文字列
    public func replaceMatched(_ pattern: String, replacement: String, regularExpressionOptions: NSRegularExpression.Options? = nil, matchingOptions: NSRegularExpression.MatchingOptions? = nil) -> String {
        
        let mutableSelf = self.mutable
        guard let regExp = try? NSRegularExpression(pattern: pattern, options: regularExpressionOptions ?? NSRegularExpression.Options()) else {
            return "\(self)"
        }
        regExp.replaceMatches(in: mutableSelf, options: matchingOptions ?? NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, self.length), withTemplate: replacement)
        
        return mutableSelf as String
    }
    
    /// 文字列から正規表現パターンに合った箇所を削除した文字列を返す
    /// - parameter pattern: 正規表現パターン
    /// - parameter regularExpressionOptions: 正規表現オプション
    /// - parameter matchingOptions: 正規表現マッチングオプション
    /// - returns: 削除した文字列
    public func removeMatched(_ pattern: String, regularExpressionOptions: NSRegularExpression.Options? = nil, matchingOptions: NSRegularExpression.MatchingOptions? = nil) -> String {
        return self.replaceMatched(pattern, replacement: "", regularExpressionOptions: regularExpressionOptions, matchingOptions: matchingOptions)
    }
}


// MARK: - String拡張: 変換 -
extension String {
    
    /// 指定した変換方法で変換した文字列を返す
    /// - parameter transform: 変換方法
    /// - parameter reverse: 変換順序
    /// - returns: 変換した文字列
    public func transform(transform: CFString, reverse: Bool) -> String {
        let mutableSelf = self.mutable as CFMutableString
        CFStringTransform(mutableSelf, nil, transform, reverse)
        return mutableSelf as String
    }
    
    /// 半角文字を全角文字に変換した文字列を返す
    /// - returns: 変換した文字列
    public var fullWidth: String {
        return self.transform(transform: kCFStringTransformFullwidthHalfwidth, reverse: true)
    }
    
    /// 全角文字を半角文字に変換した文字列を返す
    /// - returns: 変換した文字列
    public var halfWidth: String {
        return self.transform(transform: kCFStringTransformFullwidthHalfwidth, reverse: false)
    }
    
    /// カタカタをひらがなに変換した文字列を返す
    /// - returns: 変換した文字列
    public var katakanaToHiragana: String {
        return self.transform(transform: kCFStringTransformHiraganaKatakana, reverse: true)
    }
    
    /// ひらがなをカタカナに変換した文字列を返す
    /// - returns: 変換した文字列
    public var hiraganaToKatakana: String {
        return self.transform(transform: kCFStringTransformHiraganaKatakana, reverse: false)
    }
    
    /// ローマ字をひらがなに変換した文字列を返す
    /// - returns: 変換した文字列
    public var hiraganaToLatin: String {
        return self.transform(transform: kCFStringTransformLatinHiragana, reverse: true)
    }
    
    /// ひらがなをローマ字に変換した文字列を返す
    /// - returns: 変換した文字列
    public var latinToHiragana: String {
        return self.transform(transform: kCFStringTransformLatinHiragana, reverse: false)
    }
    
    /// ローマ字をカタカナに変換した文字列を返す
    /// - returns: 変換した文字列
    public var katakanaToLatin: String {
        return self.transform(transform: kCFStringTransformLatinKatakana, reverse: true)
    }
    
    /// カタカナをローマ字に変換した文字列を返す
    /// - returns: 変換した文字列
    public var latinToKatakana: String {
        return self.transform(transform: kCFStringTransformLatinKatakana, reverse: false)
    }
}

// MARK: - String拡張: 構成チェック -
extension String {
    
    /// 半角数字の構成
    public static let structureOfNumber = "0123456789"
    
    /// 半角小文字アルファベットの構成
    public static let structureOfLowercaseAlphabet = "abcdefghijklmnopqrstuvwxyz"
    
    /// 半角大文字アルファベットの構成
    public static let structureOfUppercaseAlphabet = structureOfLowercaseAlphabet.uppercased()
    
    /// 半角アルファベットの構成
    public static let structureOfAlphabet = structureOfLowercaseAlphabet + structureOfUppercaseAlphabet
    
    /// 半角英数字の構成
    public static let structureOfAlphabetAndNumber = structureOfAlphabet + structureOfNumber
    
    /// 半角数字のみで構成されているかどうか
    public var isOnlyNumber: Bool {
        
        let chars = String.structureOfNumber
        return self.isOnly(structuredBy: chars)
    }
    
    /// 半角アルファベットのみで構成されているかどうか
    public var isOnlyAlphabet: Bool {
        let chars = String.structureOfAlphabet
        return self.isOnly(structuredBy: chars)
    }
    
    /// 半角英数字のみで構成されているかどうか
    public var isOnlyAlphabetAndNumber: Bool {
        let chars = String.structureOfAlphabetAndNumber
        return self.isOnly(structuredBy: chars)
    }
    
    /// 指定した文字のみで構成されているかどうかを返す
    /// - parameter chars: 指定の文字
    /// - returns: 渡した文字のみで構成されているかどうか
    public func isOnly(structuredBy chars: String) -> Bool {
        let characterSet = NSMutableCharacterSet()
        characterSet.addCharacters(in: chars)
        return self.trimmingCharacters(in: characterSet as CharacterSet).length <= 0
    }
}

// MARK: - String拡張: URLエンコード -
extension String {
    
    /// URLエンコードした文字列
    public var urlEncode: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) ?? ""
    }
    
    /// URLデコードした文字列
    public var urlDecode: String {
        return self.stringByRemovingPercentEncoding ?? ""
    }
}

// MARK: - String拡張: 記法変換 -
extension String {
    
    /// スネーク記法をキャメル記法に変換した文字列
    public var snakeToCamel: String {
        if self.isEmpty { return "" }
        
        let r = NSMakeRange(0, 1)
        var ret = self.capitalized.replacingOccurrences(of: "_", with: "")
        ret = ret.ns.replacingCharacters(in: r, with: ret.ns.substring(with: r).lowercased())
        return ret
    }
    
    /// キャメル記法をスネーク記法に変換した文字列
    public var camelToSnake: String {
        if self.isEmpty { return "" }
        return self.replaceMatched("(?<=\\w)([A-Z])", replacement: "_$1").lowercased()
    }
}

// MARK: - String汎用関数 -

/// 文字列分割を行う
/// - parameter string: 対象の文字列
/// - parameter separator: 分割に使用するセパレータ文字
/// - parameter allowEmpty: 空文字を許可するかどうか。falseにすると分割された結果が空文字だった場合は配列に入りません
/// - returns: 分割された結果の文字列配列
public func split(_ string: String, _ separator: String, allowEmpty: Bool = true) -> [String] {
    return string.split(separator, allowEmpty: allowEmpty)
}

/// 文字列結合を行う
/// - parameter strings: 対象の文字列
/// - parameter glue: 結合に使用する文字
/// - returns: 結合した結果の文字列
public func join(_ strings: [String], _ glue: String) -> String {
    return (strings as NSArray).componentsJoined(by: glue)
}

/// 文字列の部分取得を行う
/// - parameter start: 開始インデックス
/// - parameter length: 文字列長(省略した場合は末尾まで取得)
/// - returns: 部分取得された文字列
public func substring(_ string: String, _ location: Int, _ length: Int? = nil) -> String {
    return string.substring(location: location, length: length)
}
