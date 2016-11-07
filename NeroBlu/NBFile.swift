// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBFile  -

/// ファイルクラス
open class NBFile: CustomStringConvertible {
    
    /// ファイルパス
    open fileprivate(set) var path = ""
    
    /// イニシャライザ
    /// - parameter path: ファイルパス
    public init(path: String) {
        self.path = path
    }
    
    open var description: String {
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
        return (self.name as NSString).deletingPathExtension
    }
    
    /// ディレクトリパス
    public var directoryPath: String {
        if self.path == "/" { return "" }
        return self.pathString.deletingLastPathComponent
    }
    
    /// ファイルURL
    public var url: URL {
        return URL(fileURLWithPath: self.path, isDirectory: self.isDirectory)
    }
}

// MARK: - NBFile: ファイル確認関連  -
public extension NBFile {
    
    /// ファイルが存在するかどうか
    public var exists: Bool {
        return self.manager.fileExists(atPath: self.path)
    }
    
    /// ファイルかどうか
    public var isFile: Bool {
        var isDirectory: ObjCBool = false
        if self.manager.fileExists(atPath: self.path, isDirectory: &isDirectory) {
            if !isDirectory { return true }
        }
        return false
    }
    
    /// ディレクトリかどうか
    public var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        if self.manager.fileExists(atPath: self.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue { return true }
        }
        return false
    }
}

// MARK: - NBFile: 属性取得  -
public extension NBFile {
    
    /// ファイルサイズ
    public var size: UInt64 {
        guard let n = self.fileAttributeForKey(FileAttributeKey.size.rawValue) as? NSNumber else { return 0 }
        return n.uint64Value
    }
    
    /// ファイルの作成日付
    public var createdDate: Date? {
        return self.fileAttributeForKey(FileAttributeKey.creationDate.rawValue) as? Date
    }
    
    /// ファイルの更新日付
    public var modifiedDate: Date? {
        return self.fileAttributeForKey(FileAttributeKey.modificationDate.rawValue) as? Date
    }
    
    /// ファイル属性
    public var fileAttributes: [String : AnyObject] {
        var ret = [String : AnyObject]()
        if self.exists {
            if let attr = try? self.manager.attributesOfItem(atPath: self.path) {
                attr.forEach { ret.updateValue($1 as AnyObject, forKey: $0.rawValue) }
            }
            if let attr = try? self.manager.attributesOfFileSystem(forPath: self.path) {
                attr.forEach { ret.updateValue($1 as AnyObject, forKey: $0.rawValue) }
            }
        }
        return ret
    }
    
    /// 指定したキーのファイル属性を返却する
    /// - parameter key: キー
    /// - returns: ファイル属性値
    fileprivate func fileAttributeForKey(_ key: String) -> AnyObject? {
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
        guard let names = try? self.manager.contentsOfDirectory(atPath: self.path), self.isDirectory else { return ret }
        for name in names {
            let path = self.pathString.appendingPathComponent(name)
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
    public func locate(_ location: String?, makeIfNeeded make: Bool = true) -> NBFile? {
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
        
        if make && !self.manager.fileExists(atPath: path) {
            do {
                try self.manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
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
    public func name(_ name: String) -> NBFile {
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
    fileprivate func locationElements(_ location: String?) -> [String] {
        guard let location = location else { return [] }
        return location.components(separatedBy: "/").filter { !$0.isEmpty }
    }
}

// MARK: - NBFile: ファイル読込 -
public extension NBFile {
    
    /// テキストファイルの内容を取得する
    /// - parameter encoding: 文字エンコーディング
    /// - returns: テキストファイルの内容(取得できない場合はnil)
    public func loadText(_ encoding: String.Encoding = String.Encoding.utf8) -> String? {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: self.path)) {
            return String(data: data, encoding: String.Encoding.utf8)
        }
        return nil
    }
    
    /// 画像ファイルから画像データを取得する
    /// - returns: 画像データ(取得できない場合はnil)
    public func loadImage() -> UIImage? {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: self.path)) {
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
    public func saveText(_ text: String, encoding: String.Encoding = String.Encoding.utf8) -> NBResult {
        do {
            try text.write(toFile: self.path, atomically: true, encoding: encoding)
            return self.createResult(nil)
        } catch {
            return self.createResult(.failedWrite)
        }
    }
    
    /// 画像をPNGとしてファイルに書き込む
    /// - parameter image: 画像
    /// - returns: 実行結果
    public func saveImageAsPNG(_ image: UIImage) -> NBResult {
        do {
            guard let data = UIImagePNGRepresentation(image) else {
                return self.createResult(nil, cancelled: true)
            }
            try data.write(to: URL(fileURLWithPath: self.path), options: [.atomic])
            return self.createResult(nil)
        } catch {
            return self.createResult(.failedWrite)
        }
    }
    
    /// 画像をJPEGとしてファイルに書き込む
    /// - parameter image: 画像
    /// - parameter quality: 圧縮品質
    /// - returns: 実行結果
    public func saveImageAsJPEG(_ image: UIImage, quality: CGFloat = 0.93) -> NBResult {
        do {
            guard let data = UIImageJPEGRepresentation(image, quality) else {
                return self.createResult(nil, cancelled: true)
            }
            try data.write(to: URL(fileURLWithPath: self.path), options: [.atomic])
            return self.createResult(nil)
        } catch {
            return self.createResult(.failedWrite)
        }
    }
}

// MARK: - NBFile: 汎用ディレクトリ取得 -
public extension NBFile {
    
    /// メインバンドル
    public static var mainBundle: NBFile {
        let path = Bundle.main.bundlePath
        return NBFile(path: path)
    }
    
    /// ドキュメントディレクトリ
    public static var documentDirectory: NBFile {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        return NBFile(path: path)
    }
    
    /// 一時ディレクトリ
    public static var temporaryDirectory: NBFile {
        let path = NSTemporaryDirectory()
        return NBFile(path: path)
    }
    
    /// キャッシュディレクトリ
    public static var cachesDirectory: NBFile {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String
        return NBFile(path: path)
    }
}

// MARK: - NBFile: ファイルコピー -
public extension NBFile {
    
    /// ファイルをコピーする
    /// - parameter to: 実行先のパス
    /// - parameter forcibly: 実行先にファイルがある場合は事前に削除を試みるかどうか
    /// - returns: 実行結果
    public func copy(_ to: String, forcibly: Bool = true) -> NBResult {
        return self.copy(NBFile(path: to), forcibly: forcibly)
    }
    
    /// ファイルをコピーする
    /// - parameter to: 実行先
    /// - parameter forcibly: 実行先にファイルがある場合は事前に削除を試みるかどうか
    /// - returns: 実行結果
    public func copy(_ to: NBFile, forcibly: Bool = true) -> NBResult  {
        if !self.exists {
            return self.createResult(.notExists)
        }
        
        if to.exists && forcibly {
            let res = to.delete()
            if !res.succeed {
                return res
            }
        }
        
        do {
            try self.manager.copyItem(atPath: self.path, toPath: to.path)
        } catch {
            return self.createResult(.failedCopy)
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
    public func move(_ to: String, forcibly: Bool = true) -> NBResult {
        return self.move(NBFile(path: to), forcibly: forcibly)
    }
    
    /// ファイルを移動する
    /// - parameter to: 実行先
    /// - parameter forcibly: 実行先にファイルがある場合は事前に削除を試みるかどうか
    /// - returns: 実行結果
    public func move(_ to: NBFile, forcibly: Bool = true) -> NBResult  {
        if !self.exists {
            return self.createResult(.notExists)
        }
        
        if to.exists && forcibly {
            let res = to.delete()
            if !res.succeed {
                return res
            }
        }
        
        do {
            try self.manager.moveItem(atPath: self.path, toPath: to.path)
        } catch {
            return self.createResult(.failedCopy)
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
            return self.createResult(.notExists)
        }
        
        do {
            try self.manager.removeItem(atPath: self.path)
        } catch {
            return self.createResult(.failedDelete)
        }
        return createResult(nil)
    }
}

// MARK: - NBFile: 実行結果 -
public extension NBFile {
    
    /// エラー種別
    public enum ErrorType: Int {
        case notExists    = 404
        case failedWrite  = 500
        case failedCopy   = 501
        case failedDelete = 502
        
        fileprivate var message: String {
            switch self {
            case .notExists:    return "file is not exitsts"
            case .failedWrite:  return "failed write to file"
            case .failedCopy:   return "failed copy file"
            case .failedDelete: return "failed delete file"
            }
        }
    }
    
    /// 実行結果を生成する
    /// - parameter error: エラー種別
    /// - parameter cancelled: キャンセル扱いとするかどうか
    /// - returns: 実行結果
    fileprivate func createResult(_ error: ErrorType?, cancelled: Bool = false) -> NBResult {
        if let error = error {
            return .Failed(Error(error.message, error.rawValue, "NBFileErrorDomain"))
        }
        return cancelled ? .Cancelled : .Succeed
    }
}

// MARK: - NBFile: プライベート -
private extension NBFile {
    
    /// ファイルマネージャ
    var manager: FileManager { return FileManager.default }
    
    /// NSStringにキャストしたパス文字列
    var pathString: NSString { return self.path as NSString }
    
    ///
    func addComponent(_ path: String, _ add: String) -> String {
        return (path as NSString).appendingPathComponent(add)
    }
}
