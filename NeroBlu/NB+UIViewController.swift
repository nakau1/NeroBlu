// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - UIViewController + Navigatable -

/// UIViewControllerのナビゲーション処理をラップするプロトコル
public protocol Navigatable {}

extension UIViewController: Navigatable {
    
    /// ナビゲーションスタックにビューコントローラをプッシュして表示を更新する
    /// - parameter viewController: ビューコントローラ
    /// - parameter animated: アニメーションの有無
    open func push(_ viewController: UIViewController, animated: Bool = true) {
        self.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    /// ナビゲーションスタックからトップビューコントローラをポップして表示を更新する
    /// - parameter animated: アニメーションの有無
    /// - returns: ポップしたトップビューコントローラ
    open func pop(animated: Bool = true) -> UIViewController? {
        return self.navigationController?.popViewController(animated: animated)
    }
    
    /// ルートビューコントローラを除いて、スタック上のすべてのビューコントローラをポップして表示を更新する
    /// - parameter animated: アニメーションの有無
    /// - returns: ポップされたビューコントローラの配列
    open func popToRoot(animated: Bool = true) -> [UIViewController]? {
        return self.navigationController?.popToRootViewController(animated: animated)
    }
    
    /// 指定されたビューコントローラがナビゲーションスタックの最上位に位置するまでポップして表示を更新する
    /// - parameter viewController: ビューコントローラ
    /// - parameter animated: アニメーションの有無
    /// - returns: ポップされたビューコントローラの配列
    open func popTo(_ viewController: UIViewController, animated: Bool = true) -> [UIViewController]? {
        return self.navigationController?.popToViewController(viewController, animated: animated)
    }
}

// MARK: - UIViewController + Presentable -

/// UIViewControllerのモーダル表示処理をラップするプロトコル
public protocol Presentable {}

extension UIViewController: Presentable {
    
    /// モーダルでビューコントローラを表示する
    /// - parameter viewController: ビューコントローラ
    /// - parameter transitionStyle: 表示エフェクトスタイル
    /// - parameter completion: 表示完了時の処理
    open func present(_ viewController: UIViewController, transitionStyle: UIModalTransitionStyle? = nil, completion: CompletionHandler? = nil) {
        if let transition = transitionStyle {
            viewController.modalTransitionStyle = transition
        }
        self.present(viewController, animated: true, completion: completion)
    }
    
    /// モーダルで表示されたビューコントローラを閉じる
    /// - parameter completion: 閉じ終えた時の処理
    open func dismiss(_ completion: CompletionHandler? = nil) {
        self.dismiss(animated: true, completion: completion)
    }
}

// MARK: - App.System拡張 -
public extension App.System {
    
    /// 現在の表示上で最も上層にいるビューコントローラ
    public static var TopViewController: UIViewController? {
        var vc: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc!.presentedViewController!
        }
        while vc as? UINavigationController != nil {
            let nvc = vc as! UINavigationController
            vc = nvc.topViewController
        }
        while vc as? UITabBarController != nil {
            let tvc = vc as! UITabBarController
            vc = tvc.selectedViewController
        }
        return vc
    }
}
