// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NSIndexPath拡張 -
public extension IndexPath {
    
    /// イニシャライザ
    /// - parameter row: 行インデックス
    /// - parameter section: セクションインデックス
    public init(_ row: Int, _ section: Int = 0) {
        self.init(row: row, section: section)
    }
}

// MARK: - NBCellRegisterable プロトコル -

public let NBCellDefaultIdentifier = "cell"

/// セルの登録を行うために必要な実装のインターフェイスプロトコル
public protocol NBCellRegisterable {
    
    /// 再利用セルID文字列
    static var cellIdentifier: String { get }
    
    /// クラス名
    static var className: String { get }
}
public extension NBCellRegisterable {
    
    /// 使用するXib(Nib)ファイル名(デフォルトは"クラス名.xib"を使用する)
    public static func nibName() -> String { return self.className }
    
    /// 使用するXib(Nib)があるバンドル(デフォルトはメインバンドルを使用する)
    public static func cellBundle() -> Bundle? { return nil }
    
    public static var cellIdentifier: String { return NBCellDefaultIdentifier }
}

// MARK: - テーブルビュー
// MARK: - UITableView拡張 -
public extension UITableView {
    
    /// セルを登録する
    /// - parameter registerableType: NBCellRegisterableを実装したクラスの型
    public func register<T: NBCellRegisterable>(_ registerableType: T.Type) where T: UITableViewCell {
        let id = registerableType.cellIdentifier
        if let nib = UINib.create(nibName: registerableType.nibName(), bundle: registerableType.cellBundle()) {
            self.register(nib, forCellReuseIdentifier: id)
        } else {
            self.register(registerableType, forCellReuseIdentifier: id)
        }
    }
    
    /// 再利用可能なセルを取得する
    /// - parameter registerableType: NBCellRegisterableを実装したクラスの型
    /// - parameter indexPath: インデックパス
    /// - returns: 再利用可能なセル
    public func dequeueReusableCell<T: NBCellRegisterable>(_ registerableType: T.Type, forIndexPath indexPath: IndexPath? = nil) -> T where T: UITableViewCell {
        let id = registerableType.cellIdentifier
        let reusableCell: UITableViewCell?
        if let indexPath = indexPath {
            reusableCell = self.dequeueReusableCell(withIdentifier: id, for: indexPath)
        } else {
            reusableCell = self.dequeueReusableCell(withIdentifier: id)
        }
        guard let ret = reusableCell as? T else {
            return registerableType.init()
        }
        return ret
    }
}

// MARK: - NBTableViewController -

/// テーブルビューを管理するビューコントローラ(UITableViewControllerとは直接継承関係にはない)
open class NBTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// 管理するテーブルビュー
    open var tableView: UITableView? {
        get {
            return self.view as? UITableView
        }
        set(v) {
            if let tv = v {
                tv.delegate = self
                tv.dataSource = self
            }
            self.view = v
        }
    }
    
    /// テーブルビューのセットアップを行う
    /// - parameter tableView: テーブルビュー
    open func setup(_ tableView: UITableView) {
        self.tableView = tableView
    }
    
    // MARK: UITableViewDelegate / UITableViewDataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - NBTableViewCell -

/// UITableViewCellを継承したカスタム用テーブルビューセルクラス
open class NBTableViewCell: UITableViewCell {
    
    /// 生成時に一度だけ呼ばれる初期処理
    open func initialize() {} // expected override implementation.
    
    // MARK: プライベート
    
    fileprivate var initialized = false
    
    fileprivate func initializeIfNeeded() {
        if !self.initialized {
            self.initialize()
            self.initialized = true
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.initializeIfNeeded()
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initializeIfNeeded()
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}

// MARK: - コレクションビュー
// MARK: - UICollectionView拡張 -
public extension UICollectionView {
    
    /// セルを登録する
    /// - parameter registerableType: NBCellRegisterableを実装したクラスの型
    public func register<T: NBCellRegisterable>(_ registerableType: T.Type) where T: UICollectionViewCell {
        let id = registerableType.cellIdentifier
        if let nib = UINib.create(nibName: registerableType.nibName(), bundle: registerableType.cellBundle()) {
            self.register(nib, forCellWithReuseIdentifier: id)
        } else {
            self.register(registerableType, forCellWithReuseIdentifier: id)
        }
    }
    
    /// 再利用可能なセルを取得する
    /// - parameter registerableType: NBCellRegisterableを実装したクラスの型
    /// - parameter indexPath: インデックパス
    /// - returns: 再利用可能なセル
    public func dequeueReusableCell<T: NBCellRegisterable>(_ registerableType: T.Type, forIndexPath indexPath: IndexPath? = nil) -> T where T: UICollectionViewCell {
        let id = registerableType.cellIdentifier
        let reusableCell = self.dequeueReusableCell(withReuseIdentifier: id, for: indexPath ?? IndexPath(0, 0))

        guard let ret = reusableCell as? T else {
            return registerableType.init()
        }
        return ret
    }
}

// MARK: - NBCollectionViewController -

/// コレクションビューを管理するビューコントローラ(UICollectionViewControllerとは直接継承関係にはない)
open class NBCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    /// 管理するコレクションビュー
    open var collectionView: UICollectionView? {
        get {
            return self.view as? UICollectionView
        }
        set(v) {
            if let cv = v {
                cv.delegate = self
                cv.dataSource = self
            }
            self.view = v
        }
    }
    
    /// コレクションビューレイアウト
    open var collectionViewLayout: UICollectionViewLayout? {
        get {
            return self.collectionView?.collectionViewLayout
        }
        set(v) {
            if let cvl = v {
                self.collectionView?.collectionViewLayout = cvl
            }
        }
    }
    
    /// コレクションビューのセットアップを行う
    /// - parameter collectionView: コレクションビュー
    open func setup(_ collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    // MARK: UICollectionViewDelegateFlowLayout / UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - NBCollectionViewCell -

/// UICollectionViewCellを継承したカスタム用コレクションビューセルクラス
open class NBCollectionViewCell: UICollectionViewCell {
    
    /// 生成時に一度だけ呼ばれる初期処理
    open func initialize() {} // expected override implementation.
    
    // MARK: プライベート
    
    fileprivate var initialized = false
    
    fileprivate func initializeIfNeeded() {
        if !self.initialized {
            self.initialize()
            self.initialized = true
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.initializeIfNeeded()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeIfNeeded()
    }
    
    public required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
}

// MARK: - UICollectionViewLayout拡張 -
public extension UICollectionViewLayout {
    
    /// セルをタイル状に並べる UICollectionViewFlowLayout を取得する
    /// - parameter numberOfColumns: 1行に置くセル数(列数)
    /// - parameter interval: 各セル同士の間隔
    /// - parameter margin: 外側のマージン幅
    /// - parameter totalWidth: セルサイズの計算に使用する全体幅(省略時は画面の幅を使用する)
    /// - parameter direction: スクロール方向
    /// - returns: UICollectionViewFlowLayout
    public class func tiledLayout(numberOfColumns column: Int = 4, interval: CGFloat = 1.0, margin: CGFloat = 1.0, totalWidth: CGFloat? = nil, direction: UICollectionViewScrollDirection = .vertical) -> UICollectionViewLayout {
        
        if column <= 0 { fatalError("UICollectionViewLayout#tiledLayout argument of 'column' should not be zero") }
        
        let ret = UICollectionViewFlowLayout()
        ret.scrollDirection = direction
        
        let total = totalWidth ?? App.Dimen.Screen.Width
        
        let intervals = (column - 1).f * interval
        let margins   = margin * 2
        
        let per = (total - (intervals + margins)) / column.f
        ret.itemSize = cs(per, per)
        
        ret.minimumInteritemSpacing = interval
        ret.minimumLineSpacing = interval
        ret.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin)
        
        return ret
    }
}
