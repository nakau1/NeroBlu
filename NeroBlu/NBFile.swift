// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBFile  -

/// ファイルクラス
public class NBFile: CustomStringConvertible {
    
    /// ファイルパス
    public private(set) var path = ""
    
    /// イニシャライザ
    /// - parameter path: ファイルパス
    public init(path: String) {
        self.path = path
    }
    
    public var description: String {
        return "File:\n\(self.path)"
    }
}

// MARK: - NBFile: ファイル情報  -
public extension NBFile {
    
    /// ファイル名
    public var name: String {
        return self.pathString.lastPathComponent
    }
    
    /// 拡張子
    public var extensions: String {
        return self.pathString.pathExtension
    }
    
    /// 拡張子抜きのファイル名
    public var nameWithoutExtension: String {
        return (self.name as NSString).stringByDeletingPathExtension
    }
    
    /// ディレクトリパス
    public var directoryPath: String {
        if self.path == "/" { return "" }
        return self.pathString.stringByDeletingLastPathComponent
    }
    
    /// ファイルURL
    public var url: NSURL {
        return NSURL(fileURLWithPath: self.path, isDirectory: self.isDirectory)
    }
}

// MARK: - NBFile: ファイル確認関連  -
public extension NBFile {
    
    /// ファイルが存在するかどうか
    public var exists: Bool {
        return self.manager.fileExistsAtPath(self.path)
    }
    
    /// ファイルかどうか
    public var isFile: Bool {
        var isDirectory: ObjCBool = false
        if self.manager.fileExistsAtPath(self.path, isDirectory: &isDirectory) {
            if !isDirectory { return true }
        }
        return false
    }
    
    /// ディレクトリかどうか
    public var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        if self.manager.fileExistsAtPath(self.path, isDirectory: &isDirectory) {
            if isDirectory { return true }
        }
        return false
    }
}

// MARK: - NBFile: 属性取得  -
public extension NBFile {
    
    /// ファイルサイズ
    public var size: UInt64 {
        guard let n = self.fileAttributeForKey(NSFileSize) as? NSNumber else { return 0 }
        return n.unsignedLongLongValue
    }
    
    /// ファイルの作成日付
    public var createdDate: NSDate? {
        return self.fileAttributeForKey(NSFileCreationDate) as? NSDate
    }
    
    /// ファイルの更新日付
    public var modifiedDate: NSDate? {
        return self.fileAttributeForKey(NSFileModificationDate) as? NSDate
    }
    
    /// ファイル属性
    public var fileAttributes: [String : AnyObject] {
        var ret = [String : AnyObject]()
        if self.exists {
            if let attr = try? self.manager.attributesOfItemAtPath(self.path) {
                attr.forEach { ret.updateValue($1, forKey: $0) }
            }
            if let attr = try? self.manager.attributesOfFileSystemForPath(self.path) {
                attr.forEach { ret.updateValue($1, forKey: $0) }
            }
        }
        return ret
    }
    
    /// 指定したキーのファイル属性を返却する
    /// - parameter key: キー
    /// - returns: ファイル属性値
    private func fileAttributeForKey(key: String) -> AnyObject? {
        return self.fileAttributes[key]
    }
}

// MARK: - NBFile: ディレクトリ親子関係  -
public extension NBFile {
    
    /// 親ディレクトリ(親ディレクトリが存在しない場合はnilを返す)
    public var parent: NBFile? {
        let ret = NBFile.init(path: self.directoryPath)
        return ret.exists ? ret : nil
    }
    
    /// ディレクトリ内のファイル(ディレクトリも含む)をすべて配列で返す(自身がディレクトリでない場合は空配列を返す)
    public var files: [NBFile] {
        var ret = [NBFile]()
        guard let names = try? self.manager.contentsOfDirectoryAtPath(self.path) where self.isDirectory else { return ret }
        for name in names {
            let path = self.pathString.stringByAppendingPathComponent(name)
            ret.append(NBFile(path: path))
        }
        return ret
    }
    
    /// ディレクトリ内のファイル(ディレクトリも含む)パス文字列をすべて配列で返す(自身がディレクトリでない場合は空配列を返す)
    public var paths: [String] {
        return self.files.map { $0.path }
    }
    
    /// ディレクトリ内のファイル(ディレクトリも含む)名をすべて配列で返す(自身がディレクトリでない場合は空配列を返す)
    public var names: [String] {
        return self.files.map { $0.name }
    }
}

// MARK: - ロケーション -
public extension NBFile {

    /// ロケーション文字列からディレクトリを指定する
    /// - parameter location: "/"で区切ったディレクトリ以下のパス
    /// - parameter make: ディレクトリが存在しない場合に作成するかどうか
    /// - returns: 自身の参照
    public func locate(location: String?, makeIfNeeded make: Bool = true) -> NBFile? {
        if !self.isDirectory {
            print("could not locate because file object not point to directory. path ='\(self.path)'")
            return nil
        }
        if (location?.isEmpty ?? true) {
            return self
        }
        
        var path = self.path
        for locationElement in self.locationElements(location) {
            path = self.addComponent(path, locationElement)
        }
        
        if make && !self.manager.fileExistsAtPath(path) {
            do {
                try self.manager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("failed to make directory during locating. path ='\(path)'")
                return nil
            }
        }
        self.path = path
        return self
    }
    
    /// ファイル名を更新する
    /// - parameter name: ファイル名
    /// - returns: 自身の参照
    public func name(name: String) -> NBFile {
        if self.isFile {
            self.path = self.addComponent(self.directoryPath, name)
        } else {
            self.path = self.addComponent(self.path, name)
        }
        return self
    }
    
    /// "/"で区切った文字列を分割して配列化する
    /// - parameter makeDirIfNotExists: ディレクトリが存在しない場合作成するかどうか
    /// - returns: ロケーションで指定したドキュメントディレクトリ内のディレクトリ絶対パス
    private func locationElements(location: String?) -> [String] {
        guard let location = location else { return [] }
        return location.componentsSeparatedByString("/").filter { !$0.isEmpty }
    }
}

// MARK: - NBFile: ファイル読込 -
public extension NBFile {
    
    /// テキストファイルの内容を取得する
    /// - parameter encoding: 文字エンコーディング
    /// - returns: テキストファイルの内容(取得できない場合はnil)
    public func loadText(encoding: NSStringEncoding = NSUTF8StringEncoding) -> String? {
        if let data = NSData(contentsOfFile: self.path) {
            return String(data: data, encoding: NSUTF8StringEncoding)
        }
        return nil
    }
    
    /// 画像ファイルから画像データを取得する
    /// - returns: 画像データ(取得できない場合はnil)
    public func loadImage() -> UIImage? {
        if let data = NSData(contentsOfFile: self.path) {
            return UIImage(data: data)
        }
        return nil
    }
}

// MARK: - NBFile: ファイル書込 -
public extension NBFile {
    
    /// 文字列をファイルに書き込む
    /// - parameter text: 書き込む文字列
    /// - parameter encoding: 文字エンコーディング
    /// - returns: 実行結果
    public func saveText(text: String, encoding: NSStringEncoding = NSUTF8StringEncoding) -> NBResult {
        do {
            try text.writeToFile(self.path, atomically: true, encoding: encoding)
            return self.createResult(nil)
        } catch {
            return self.createResult(.FailedWrite)
        }
    }
    
    /// 画像をPNGとしてファイルに書き込む
    /// - parameter image: 画像
    /// - returns: 実行結果
    public func saveImageAsPNG(image: UIImage) -> NBResult {
        do {
            guard let data = UIImagePNGRepresentation(image) else {
                return self.createResult(nil, cancelled: true)
            }
            try data.writeToFile(self.path, options: [.DataWritingAtomic])
            return self.createResult(nil)
        } catch {
            return self.createResult(.FailedWrite)
        }
    }
    
    /// 画像をJPEGとしてファイルに書き込む
    /// - parameter image: 画像
    /// - parameter quality: 圧縮品質
    /// - returns: 実行結果
    public func saveImageAsJPEG(image: UIImage, quality: CGFloat = 0.93) -> NBResult {
        do {
            guard let data = UIImageJPEGRepresentation(image, quality) else {
                return self.createResult(nil, cancelled: true)
            }
            try data.writeToFile(self.path, options: [.DataWritingAtomic])
            return self.createResult(nil)
        } catch {
            return self.createResult(.FailedWrite)
        }
    }
}

// MARK: - NBFile: 汎用ディレクトリ取得 -
public extension NBFile {
    
    /// メインバンドル
    public static var mainBundle: NBFile {
        let path = NSBundle.mainBundle().bundlePath
        return NBFile(path: path)
    }
    
    /// ドキュメントディレクトリ
    public static var documentDirectory: NBFile {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        return NBFile(path: path)
    }
    
    /// 一時ディレクトリ
    public static var temporaryDirectory: NBFile {
        let path = NSTemporaryDirectory()
        return NBFile(path: path)
    }
    
    /// キャッシュディレクトリ
    public static var cachesDirectory: NBFile {
        let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as String
        return NBFile(path: path)
    }
}

// MARK: - NBFile: ファイルコピー -
public extension NBFile {
    
    /// ファイルをコピーする
    /// - parameter to: 実行先のパス
    /// - parameter forcibly: 実行先にファイルがある場合は事前に削除を試みるかどうか
    /// - returns: 実行結果
    public func copy(to: String, forcibly: Bool = true) -> NBResult {
        return self.copy(NBFile(path: to), forcibly: forcibly)
    }
    
    /// ファイルをコピーする
    /// - parameter to: 実行先
    /// - parameter forcibly: 実行先にファイルがある場合は事前に削除を試みるかどうか
    /// - returns: 実行結果
    public func copy(to: NBFile, forcibly: Bool = true) -> NBResult  {
        if !self.exists {
            return self.createResult(.NotExists)
        }
        
        if to.exists && forcibly {
            let res = to.delete()
            if !res.succeed {
                return res
            }
        }
        
        do {
            try self.manager.copyItemAtPath(self.path, toPath: to.path)
        } catch {
            return self.createResult(.FailedCopy)
        }
        
        return createResult(nil)
    }
}
// MARK: - NBFile: ファイル移動 -
public extension NBFile {
    
    /// ファイルを移動する
    /// - parameter to: 実行先のパス
    /// - parameter forcibly: 実行先にファイルがある場合は事前に削除を試みるかどうか
    /// - returns: 実行結果
    public func move(to: String, forcibly: Bool = true) -> NBResult {
        return self.move(NBFile(path: to), forcibly: forcibly)
    }
    
    /// ファイルを移動する
    /// - parameter to: 実行先
    /// - parameter forcibly: 実行先にファイルがある場合は事前に削除を試みるかどうか
    /// - returns: 実行結果
    public func move(to: NBFile, forcibly: Bool = true) -> NBResult  {
        if !self.exists {
            return self.createResult(.NotExists)
        }
        
        if to.exists && forcibly {
            let res = to.delete()
            if !res.succeed {
                return res
            }
        }
        
        do {
            try self.manager.moveItemAtPath(self.path, toPath: to.path)
        } catch {
            return self.createResult(.FailedCopy)
        }
        
        return createResult(nil)
    }
}

// MARK: - NBFile: ファイル削除 -
public extension NBFile {
    
    /// ファイルを削除する
    /// - returns: 実行結果
    public func delete() -> NBResult {
        
        if !self.exists {
            return self.createResult(.NotExists)
        }
        
        do {
            try self.manager.removeItemAtPath(self.path)
        } catch {
            return self.createResult(.FailedDelete)
        }
        return createResult(nil)
    }
}

// MARK: - NBFile: 実行結果 -
public extension NBFile {
    
    /// エラー種別
    public enum ErrorType: Int {
        case NotExists    = 404
        case FailedWrite  = 500
        case FailedCopy   = 501
        case FailedDelete = 502
        
        private var message: String {
            switch self {
            case .NotExists:    return "file is not exitsts"
            case .FailedWrite:  return "failed write to file"
            case .FailedCopy:   return "failed copy file"
            case .FailedDelete: return "failed delete file"
            }
        }
    }
    
    /// 実行結果を生成する
    /// - parameter error: エラー種別
    /// - parameter cancelled: キャンセル扱いとするかどうか
    /// - returns: 実行結果
    private func createResult(error: ErrorType?, cancelled: Bool = false) -> NBResult {
        if let error = error {
            return .Failed(Error(error.message, error.rawValue, "NBFileErrorDomain"))
        }
        return cancelled ? .Cancelled : .Succeed
    }
}

// MARK: - NBFile: プライベート -
private extension NBFile {
    
    /// ファイルマネージャ
    private var manager: NSFileManager { return NSFileManager.defaultManager() }
    
    /// NSStringにキャストしたパス文字列
    private var pathString: NSString { return self.path as NSString }
    
    ///
    private func addComponent(path: String, _ add: String) -> String {
        return (path as NSString).stringByAppendingPathComponent(add)
    }
}
