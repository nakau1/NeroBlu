// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NSIndexPath拡張 -
public extension NSIndexPath {
    
    /// イニシャライザ
    /// - parameter row: 行インデックス
    /// - parameter section: セクションインデックス
    public convenience init(_ row: Int, _ section: Int = 0) {
        self.init(forRow: row, inSection: section)
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
    public static func cellBundle() -> NSBundle? { return nil }
    
    public static var cellIdentifier: String { return NBCellDefaultIdentifier }
}

// MARK: - テーブルビュー
// MARK: - UITableView拡張 -
public extension UITableView {
    
    /// セルを登録する
    /// - parameter registerableType: NBCellRegisterableを実装したクラスの型
    public func register<T: NBCellRegisterable where T: UITableViewCell>(registerableType: T.Type) {
        let id = registerableType.cellIdentifier
        if let nib = UINib.create(nibName: registerableType.nibName(), bundle: registerableType.cellBundle()) {
            self.registerNib(nib, forCellReuseIdentifier: id)
        } else {
            self.registerClass(registerableType, forCellReuseIdentifier: id)
        }
    }
    
    /// 再利用可能なセルを取得する
    /// - parameter registerableType: NBCellRegisterableを実装したクラスの型
    /// - parameter indexPath: インデックパス
    /// - returns: 再利用可能なセル
    public func dequeueReusableCell<T: NBCellRegisterable where T: UITableViewCell>(registerableType: T.Type, forIndexPath indexPath: NSIndexPath? = nil) -> T {
        let id = registerableType.cellIdentifier
        let reusableCell: UITableViewCell?
        if let indexPath = indexPath {
            reusableCell = self.dequeueReusableCellWithIdentifier(id, forIndexPath: indexPath)
        } else {
            reusableCell = self.dequeueReusableCellWithIdentifier(id)
        }
        guard let ret = reusableCell as? T else {
            return registerableType.init()
        }
        return ret
    }
}

// MARK: - NBTableViewController -

/// テーブルビューを管理するビューコントローラ(UITableViewControllerとは直接継承関係にはない)
public class NBTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// 管理するテーブルビュー
    public var tableView: UITableView? {
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
    public func setup(tableView: UITableView) {
        self.tableView = tableView
    }
    
    // MARK: UITableViewDelegate / UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: - NBTableViewCell -

/// UITableViewCellを継承したカスタム用テーブルビューセルクラス
public class NBTableViewCell: UITableViewCell {
    
    /// 生成時に一度だけ呼ばれる初期処理
    public func initialize() {} // expected override implementation.
    
    // MARK: プライベート
    
    private var initialized = false
    
    private func initializeIfNeeded() {
        if !self.initialized {
            self.initialize()
            self.initialized = true
        }
    }
    
    public override func awakeFromNib() {
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
    public func register<T: NBCellRegisterable where T: UICollectionViewCell>(registerableType: T.Type) {
        let id = registerableType.cellIdentifier
        if let nib = UINib.create(nibName: registerableType.nibName(), bundle: registerableType.cellBundle()) {
            self.registerNib(nib, forCellWithReuseIdentifier: id)
        } else {
            self.registerClass(registerableType, forCellWithReuseIdentifier: id)
        }
    }
    
    /// 再利用可能なセルを取得する
    /// - parameter registerableType: NBCellRegisterableを実装したクラスの型
    /// - parameter indexPath: インデックパス
    /// - returns: 再利用可能なセル
    public func dequeueReusableCell<T: NBCellRegisterable where T: UICollectionViewCell>(registerableType: T.Type, forIndexPath indexPath: NSIndexPath? = nil) -> T {
        let id = registerableType.cellIdentifier
        let reusableCell = self.dequeueReusableCellWithReuseIdentifier(id, forIndexPath: indexPath ?? NSIndexPath(0, 0))

        guard let ret = reusableCell as? T else {
            return registerableType.init()
        }
        return ret
    }
}

// MARK: - NBCollectionViewController -

/// コレクションビューを管理するビューコントローラ(UICollectionViewControllerとは直接継承関係にはない)
public class NBCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    /// 管理するコレクションビュー
    public var collectionView: UICollectionView? {
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
    public var collectionViewLayout: UICollectionViewLayout? {
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
    public func setup(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    // MARK: UICollectionViewDelegateFlowLayout / UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
}

// MARK: - NBCollectionViewCell -

/// UICollectionViewCellを継承したカスタム用コレクションビューセルクラス
public class NBCollectionViewCell: UICollectionViewCell {
    
    /// 生成時に一度だけ呼ばれる初期処理
    public func initialize() {} // expected override implementation.
    
    // MARK: プライベート
    
    private var initialized = false
    
    private func initializeIfNeeded() {
        if !self.initialized {
            self.initialize()
            self.initialized = true
        }
    }
    
    public override func awakeFromNib() {
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
    public class func tiledLayout(numberOfColumns column: Int = 4, interval: CGFloat = 1.0, margin: CGFloat = 1.0, totalWidth: CGFloat? = nil, direction: UICollectionViewScrollDirection = .Vertical) -> UICollectionViewLayout {
        
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
