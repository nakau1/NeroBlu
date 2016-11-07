// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBLandingItem -

/// NBLandingViewControllerの項目クラス
open class NBLandingItem {
    
    fileprivate var title:   String
    fileprivate var handler: VoidClosure
    
    /// イニシャライザ
    /// - parameter title: 項目タイトル
    /// - parameter handler: 項目選択時の処理
    public init(_ title: String, _ handler: @escaping VoidClosure) {
        self.title   = title
        self.handler = handler
    }
}

// MARK: - NBLandingViewController -

/// ランディング画面ビューコントローラ
open class NBLandingViewController: UIViewController {
    
    /// テーブルビュー
    @IBOutlet open weak var tableView: UITableView!
    
    /// ランディング画面の項目の定義を返す
    /// - returns: title: セクションのタイトル, rows: 項目の配列
    open var items: [(title: String, rows: [NBLandingItem])] {
        return []
    }
    
    fileprivate var table: Table!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableViewIfNeeded()
        self.table = Table(controller: self)
    }
    
    fileprivate class Table: NSObject, UITableViewDelegate, UITableViewDataSource {
        
        fileprivate let controller: NBLandingViewController
        
        fileprivate let cellIdentifier = "item"
        
        init(controller: NBLandingViewController) {
            self.controller = controller
            super.init()
            
            controller.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
            controller.tableView.delegate = self
            controller.tableView.dataSource = self
        }
        
        @objc fileprivate func numberOfSections(in tableView: UITableView) -> Int {
            return self.controller.items.count
        }
        
        @objc fileprivate func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.controller.items[section].rows.count
        }
        
        @objc fileprivate func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
            let item = self.controller.items[indexPath.section].rows[indexPath.row]
            cell.textLabel?.text = item.title
            return cell
        }
        
        @objc fileprivate func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return self.controller.items[section].title
        }
        
        @objc fileprivate func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let item = self.controller.items[indexPath.section].rows[indexPath.row]
            item.handler()
        }
    }
    
    fileprivate func setupTableViewIfNeeded() {
        if self.tableView != nil { return }
        
        let v = UITableView(frame: CGRect.zero, style: .grouped)
        self.view.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        
        func constraint(_ attr: NSLayoutAttribute, _ toItem: AnyObject? = nil) -> NSLayoutConstraint {
            return NSLayoutConstraint(
                item: v, attribute: attr, relatedBy: .equal,
                toItem: toItem ?? self.view, attribute: attr, multiplier: 1, constant: 0)
        }
        
        self.view.addConstraints([
            constraint(.leading),
            constraint(.trailing),
            constraint(.top, self.topLayoutGuide),
            constraint(.bottom, self.bottomLayoutGuide),
        ])
        
        self.tableView = v
    }
}
