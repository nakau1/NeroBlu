// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - App -

/// アプリケーション
open class App {}

// MARK: - App.System -
public extension App {
    
    /// システム
    public struct System {
        
        /// UIApplicationの共有オブジェクト
        public static var Shared: UIApplication { return UIApplication.shared }
        
        /// ルートビューコントローラ
        public static var Root: UIViewController? {
            get    { return App.System.Shared.delegate?.window??.rootViewController }
            set(v) { App.System.Shared.delegate?.window??.rootViewController = v }
        }
        
        /// アプリケーションID
        public static var ApplicationID: String {
            return Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? ""
        }
        
        /// iPadかどうか
        public static var isiPad: Bool {
            return UIDevice.current.model.hasPrefix("iPad")
        }
        
        /// シミュレータかどうか
        public static var isSimulator: Bool {
            return TARGET_OS_SIMULATOR != 0
        }
    }
}

// MARK: - App.Const -
public extension App {
    
    /// 共通定数定義
    public struct Const {}
}

// MARK: - App.Dimen -
public extension App {
    
    /// サイズ定義
    public struct Dimen {
        /// 画面
        public struct Screen {
            /// 画面のサイズ
            public static var Size: CGSize { return UIScreen.main.bounds.size }
            /// 画面の幅
            public static var Width: CGFloat { return self.Size.width }
            /// 画面の高さ
            public static var Height: CGFloat { return self.Size.height }
            /// 画面のスケール
            public static var Scale: CGFloat { return UIScreen.main.scale }
            /// Retinaを考慮した画面サイズ
            public static var RetinaSize: CGSize { return self.Size * self.Scale }
        }
    }
}
