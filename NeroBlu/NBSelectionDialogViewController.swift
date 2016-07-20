// =============================================================================
// NeroBluCustomizeDialog
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBSelectionDialogOption -

/// 選択ダイアログビューのオプション設定
public struct NBSelectionDialogOption {
    
    /// 選択肢を選択した時点で選択完了とするかどうか
    /// - remark: true で OK/キャンセル ボタンを非表示にします
    public var shouldCommitWhenSelectedItem = false
    
    /// タイトルがnilの場合にタイトル部分をビューから削除するかどうか
    public var shouldRemoveTitleLabelIfGivenNil = false
    
    /// 選択肢アイテムの高さ
    public var itemHeight: CGFloat = 44.0
    
    /// 選択肢アイテムの文字色
    public var itemColor: UIColor = UIColor.darkTextColor()
    
    /// 選択肢アイテムのフォント
    public var itemFont: UIFont = UIFont.systemFontOfSize(16.0)
    
    /// 選択肢の選択スタイル(チェックマークを付ける時)
    public var itemCheckingSelectionStyle: UITableViewCellSelectionStyle = .None
    
    /// 選択肢の選択スタイル(選択によって確定させる時)
    public var itemSelectingSelectionStyle: UITableViewCellSelectionStyle = .Default
    
    /// 上部タイトル部分の高さ
    public var titleHeight: CGFloat = 44.0
    
    /// 上部タイトルの文字色
    public var titleColor: UIColor = UIColor.darkTextColor()
    
    /// 上部タイトルのフォント
    public var titleFont: UIFont = UIFont.systemFontOfSize(12.0)
    
    /// OKボタンの文言
    public var commitButtonText = "OK"
    
    /// キャンセルボタの文言
    public var cancelButtonText = "Cancel"
    
    /// 下部ボタンの高さ
    public var controlButtonHeight: CGFloat = 44.0
    
    /// 下部ボタンの文字色
    public var controlButtonColor: UIColor = UIColor.blueColor()
    
    /// 下部ボタンのフォント
    public var controlButtonFont: UIFont = UIFont.systemFontOfSize(16.0)
    
    /// セパレータの幅
    public var separatorWidth: CGFloat = 1.0
    
    /// セパレータの色
    public var separatorColor: UIColor = UIColor.lightGrayColor()
    
    /// 全体背景色
    public var backgroundColor: UIColor = UIColor.whiteColor()
    
    /// コーナーの丸み
    public var cornerRadius: CGFloat = 6.0
    
    /// 左右両端のマージン
    public var horizontalSideMargin: CGFloat = 64.0
    
    /// チェック済みの画像
    public var checkedImage: UIImage?
    
    /// 未チェックの画像
    public var uncheckedImage: UIImage?
    
    /// 一度に表示する選択肢の数(渡したitemsの数がこの値以上ならばスクロールする)
    public var maximumItemNumber: Int = 5
}

/// 選択ダイアログのセットアップ用デリゲート
@objc public protocol NBSelectionDialogSetupDelegate {
    
    /// セットアップが始まる直前に呼ばれる
    /// - parameter dialog: 選択ダイアログの参照
    optional func selectionDialogWillSetup(dialog: NBSelectionDialogViewController)
    
    /// タイトル用ラベルがセットアップされた直後に呼ばれる
    /// - parameter dialog: 選択ダイアログの参照
    /// - parameter titleLabel: タイトル用ラベルの参照
    optional func selectionDialog(dialog: NBSelectionDialogViewController, didSetupTitleLabel titleLabel: UILabel)
    
    /// 選択肢用テーブルビューがセットアップされた直後に呼ばれる
    /// - parameter dialog: 選択ダイアログの参照
    /// - parameter itemsTableView: 選択肢用テーブルビュー
    optional func selectionDialog(dialog: NBSelectionDialogViewController, didSetupItemsTableView itemsTableView: UITableView)
    
    /// 確定用ボタンがセットアップされた直後に呼ばれる
    /// - parameter dialog: 選択ダイアログの参照
    /// - parameter commitButton: 確定用ボタンの参照
    optional func selectionDialog(dialog: NBSelectionDialogViewController, didSetupCommitButton commitButton: UIButton)
    
    /// キャンセル用ボタンがセットアップされた直後に呼ばれる
    /// - parameter dialog: 選択ダイアログの参照
    /// - parameter cancelButton: キャンセル用ボタンの参照
    optional func selectionDialog(dialog: NBSelectionDialogViewController, didSetupCancelButton cancelButton: UIButton)
    
    /// 選択肢用テーブルビューセルが生成された直後に呼ばれる
    /// - parameter dialog: 選択ダイアログの参照
    /// - parameter cell: テーブルビューセルの参照
    optional func selectionDialog(dialog: NBSelectionDialogViewController, didCreateItemTableViewCell cell: UITableViewCell)
    
    /// 選択肢用テーブルビューセルがセットアップされた直後に呼ばれる
    /// - parameter dialog: 選択ダイアログの参照
    /// - parameter cell: テーブルビューセルの参照
    /// - parameter index: インデックス
    optional func selectionDialog(dialog: NBSelectionDialogViewController, didSetupItemTableViewCell cell: UITableViewCell, atIndex index: Int)
    
    /// セットアップされた直後に呼ばれる
    /// - parameter dialog: 選択ダイアログの参照
    optional func selectionDialogDidSetup(dialog: NBSelectionDialogViewController)
}

// MARK: - NBSelectionDialogViewController -
public class NBSelectionDialogViewController: NBCustomizedDialogViewController {//, UITableViewDelegate, UITableViewDataSource {
    
    public typealias NBSelectionDialogHandler = (Int) -> Void
    
    private let CellID = "cell"
    
    // MARK: プライベートプロパティ
    private var itemsTableView = UITableView()
    private var titleLabel     = UILabel()
    private var commitButton   = UIButton()
    private var cancelButton   = UIButton()
    
    /// 選択肢文字列の配列
    public var items = [String]()
    
    /// インデックス
    public var index = 0
    
    /// 選択時のハンドラ
    public var handler: NBSelectionDialogHandler? = nil
    
    /// 選択時のハンドラ
    public var selectionOption: NBSelectionDialogOption? = NBSelectionDialogOption()
    
    /// 選択ダイアログビューを表示する
    /// - parameter items: 選択肢文字列の配列
    /// - parameter defaultIndex: 初期で選択されているインデックス番号
    /// - parameter option: 選択ダイアログビューオプション
    /// - parameter handler: 選択された時の処理
    public class func show(controller: UIViewController, items: [String], defaultIndex: Int = 0, selectionOption: NBSelectionDialogOption? = nil, dialogOption: NBCustomizedDialogOption? = nil, handler: NBSelectionDialogHandler? = nil) {
        let dialog = NBSelectionDialogViewController()
        dialog.items           = items
        dialog.index           = defaultIndex
        dialog.handler         = handler
        dialog.dialogOption    = dialogOption    ?? NBCustomizedDialogOption(cancellable: true)
        dialog.selectionOption = selectionOption ?? NBSelectionDialogOption()
        controller.presentDialog(dialog)
    }
    
    // MARK: セットアップ
    
    private var initialized = false
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.initialized {
            self.initialize()
            self.initialized = true
        }
    }
    
    private func initialize() {
        
    }
    
    /*
    private func setup() {
        let opt = self.option
        let w = App.Dimen.Screen.Width - (opt.horizontalSideMargin * 2)
        var h: CGFloat = 0, y: CGFloat = 0
        
        opt.setupDelegate?.selectionDialogViewWillSetup?(self)
        
        // タイトルがnilであり、オプション「shouldRemoveTitleLabelIfGivenNil」がtrueの場合は、ラベルを生成しない
        if opt.title != nil || !opt.shouldRemoveTitleLabelIfGivenNil {
            // タイトル
            h = opt.titleHeight
            self.titleLabel.frame = cr(0, y, w, h)
            self.setupTitleLabel(self.titleLabel, opt: opt)
            opt.setupDelegate?.selectionDialogView?(self, didSetupTitleLabel: self.titleLabel)
            self.addSubview(self.titleLabel)
            y += h
            
            // セパレータ
            h = self.drawHorizontalSeparator(w, y, opt)
            y += h
        }
        
        // 選択肢用テーブルビュー
        h = opt.itemHeight * CGFloat(self.displayedItemNumber)
        self.itemsTableView.frame = cr(0, y, w, h)
        self.itemsTableView.layer.cornerRadius = opt.cornerRadius
        self.setupTableView(self.itemsTableView, opt: opt)
        opt.setupDelegate?.selectionDialogView?(self, didSetupItemsTableView: self.itemsTableView)
        self.addSubview(self.itemsTableView)
        y += h
        
        // オプション「shouldCommitWhenSelectedItem」がtrueならば、ボタンは設置しない
        if !opt.shouldCommitWhenSelectedItem {
            // セパレータ
            h = self.drawHorizontalSeparator(w, y, opt)
            y += h
            
            // ボタン
            h = opt.controlButtonHeight
            let controlButtons = [self.commitButton, self.cancelButton]
            for (i, controlButton) in controlButtons.enumerate() {
                let bw = w / CGFloat(controlButtons.count)
                let bx = bw * CGFloat(i)
                controlButton.frame = CGRectMake(bx, y, bw, h)
                
                if controlButton == self.commitButton {
                    self.setupControlButton(controlButton, opt: opt, text: opt.commitButtonText, action: "didTapCommitButton")
                    opt.setupDelegate?.selectionDialogView?(self, didSetupCommitButton: controlButton)
                } else if controlButton == self.cancelButton {
                    self.setupControlButton(controlButton, opt: opt, text: opt.cancelButtonText, action: "didTapCancelButton")
                    opt.setupDelegate?.selectionDialogView?(self, didSetupCancelButton: controlButton)
                }
                self.addSubview(controlButton)
            }
            y += h
        }
        
        self.backgroundColor    = opt.backgroundColor
        self.layer.cornerRadius = opt.cornerRadius
        self.frame = cr(0, 0, w, y)
        
        opt.setupDelegate?.selectionDialogViewDidSetup?(self)
    }
    
    // MARK: コンポーネントのセットアップ
    
    /// タイトル用ラベル
    private func setupTitleLabel(label: UILabel, opt: NBSelectionDialogViewOption) {
        label.text          = opt.title
        label.textColor     = opt.titleColor
        label.font          = opt.titleFont
        label.textAlignment = .Center
    }
    
    /// 選択肢用テーブルビュー
    private func setupTableView(table: UITableView, opt: NBSelectionDialogViewOption) {
        table.delegate       = self
        table.dataSource     = self
        table.separatorStyle = .None
        table.rowHeight      = opt.itemHeight
        table.userInteractionEnabled = true
        if self.items.count <= opt.maximumItemNumber {
            table.scrollEnabled = false
        }
    }
    
    /// ボタン
    private func setupControlButton(button: UIButton, opt: NBSelectionDialogViewOption, text: String, action: String) {
        button.addTarget(self, action: Selector(action), forControlEvents: .TouchUpInside)
        button.setTitle(text, forState: .Normal)
        button.setTitleColor(opt.controlButtonColor, forState: .Normal)
        button.setTitleColor(opt.controlButtonColor.colorWithAlphaComponent(0.2), forState: .Highlighted)
    }
    
    // MARK: 汎用プライベート処理(メソッド/プロパティ)
    
    /// デフォルトのオプション
    private var defaultOption: NBSelectionDialogViewOption {
        var ret = NBSelectionDialogViewOption()
        ret.dialogOption.cancellable = true
        return ret
    }
    
    /// 表示される選択肢の数(選択肢がこの数以上あればスクロールされる)
    private var displayedItemNumber: Int {
        let num = self.items.count
        let max = self.option.maximumItemNumber
        return num > max ? max : num
    }
    
    /// 水平線(セパレータ)を描画する共通処理
    private func drawHorizontalSeparator(w: CGFloat, _ y: CGFloat, _ opt: NBSelectionDialogViewOption) -> CGFloat {
        let separator = UIView(frame: cr(0, y, w, opt.separatorWidth))
        separator.backgroundColor = opt.separatorColor
        self.addSubview(separator)
        return opt.separatorWidth
    }
    
    /// デフォルトのオプション
    private var properDialogOption: NBDialogPresentationOption {
        var opt = self.option
        if opt.shouldCommitWhenSelectedItem {
            opt.dialogOption.cancellable = true
        } else {
            opt.dialogOption.cancellable = false
        }
        return opt.dialogOption
    }
    
    // MARK: ボタンイベント
    
    /// 確定ボタン押下時
    @objc private func didTapCommitButton() {
        self.handler?(self.index)
        UIView.dismissPresentedDialog(self.option.dialogOption, completionHandler: nil)
    }
    
    /// キャンセルボタン押下時
    @objc private func didTapCancelButton() {
        UIView.dismissPresentedDialog(self.option.dialogOption, completionHandler: nil)
    }
    
    // MARK: テーブルビュー
    
    /// 行数
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    /// セル返却
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let opt = self.option
        let cell = tableView.dequeueReusableCellWithIdentifier(self.CellID) ?? self.createCell(opt)
        
        self.setupCell(opt, index: indexPath.row, cell: cell)
        return cell
    }
    
    /// 選択時
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.index = indexPath.row
        
        if self.option.shouldCommitWhenSelectedItem {
            self.didTapCommitButton()
        } else {
            tableView.reloadData()
        }
    }
    
    /// セル生成
    private func createCell(opt: NBSelectionDialogViewOption) -> UITableViewCell {
        let cell =  UITableViewCell(style: .Default, reuseIdentifier: self.CellID)
        cell.selectionStyle       = opt.shouldCommitWhenSelectedItem ? opt.itemSelectingSelectionStyle : opt.itemCheckingSelectionStyle
        cell.textLabel!.font      = opt.itemFont
        cell.textLabel!.textColor = opt.itemColor
        opt.setupDelegate?.selectionDialogView?(self, didCreateItemTableViewCell: cell)
        return cell
    }
    
    /// セルのセットアップ
    private func setupCell(opt: NBSelectionDialogViewOption, index: Int, cell: UITableViewCell) {
        cell.textLabel!.text = self.items[index]
        
        cell.accessoryView = nil
        if index == self.index { // if selected
            if let checkedImage = opt.checkedImage {
                cell.accessoryView = UIImageView(image: checkedImage)
            } else {
                cell.accessoryType = .Checkmark
            }
        } else {
            if let uncheckedImage = opt.uncheckedImage {
                cell.accessoryView = UIImageView(image: uncheckedImage)
            } else {
                cell.accessoryType = .None
            }
        }
        
        opt.setupDelegate?.selectionDialogView?(self, didSetupItemTableViewCell: cell, atIndex: index)
    }
    */
}
