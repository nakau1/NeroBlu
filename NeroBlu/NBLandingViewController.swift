// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBLandingItem -

/// NBLandingViewControllerの項目クラス
public class NBLandingItem {
    
    private var title:   String
    private var handler: VoidClosure
    
    /// イニシャライザ
    /// - parameter title: 項目タイトル
    /// - parameter handler: 項目選択時の処理
    public init(_ title: String, _ handler: VoidClosure) {
        self.title   = title
        self.handler = handler
    }
}

// MARK: - NBLandingViewController -

/// ランディング画面ビューコントローラ
public class NBLandingViewController: UIViewController {
    
    /// テーブルビュー
    @IBOutlet public weak var tableView: UITableView!
    
    /// ランディング画面の項目の定義を返す
    /// - returns: title: セクションのタイトル, rows: 項目の配列
    public var items: [(title: String, rows: [NBLandingItem])] {
        return []
    }
    
    private var table: Table!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableViewIfNeeded()
        self.table = Table(controller: self)
    }
    
    private class Table: NSObject, UITableViewDelegate, UITableViewDataSource {
        
        private let controller: NBLandingViewController
        
        private let cellIdentifier = "item"
        
        init(controller: NBLandingViewController) {
            self.controller = controller
            super.init()
            
            controller.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
            controller.tableView.delegate = self
            controller.tableView.dataSource = self
        }
        
        @objc private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return self.controller.items.count
        }
        
        @objc private func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.controller.items[section].rows.count
        }
        
        @objc private func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath)
            let item = self.controller.items[indexPath.section].rows[indexPath.row]
            cell.textLabel?.text = item.title
            return cell
        }
        
        @objc private func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return self.controller.items[section].title
        }
        
        @objc private func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let item = self.controller.items[indexPath.section].rows[indexPath.row]
            item.handler()
        }
    }
    
    private func setupTableViewIfNeeded() {
        if self.tableView != nil { return }
        
        let v = UITableView(frame: CGRectZero, style: .Grouped)
        self.view.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        
        func constraint(attr: NSLayoutAttribute, _ toItem: AnyObject? = nil) -> NSLayoutConstraint {
            return NSLayoutConstraint(
                item: v, attribute: attr, relatedBy: .Equal,
                toItem: toItem ?? self.view, attribute: attr, multiplier: 1, constant: 0)
        }
        
        self.view.addConstraints([
            constraint(.Leading),
            constraint(.Trailing),
            constraint(.Top, self.topLayoutGuide),
            constraint(.Bottom, self.bottomLayoutGuide),
        ])
        
        self.tableView = v
    }
}
