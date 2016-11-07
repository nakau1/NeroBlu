// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

/// タイマークラス
open class NBTimer: NSObject {
    
    /// タイマーを開始する
    /// - parameter time: タイマー時間
    /// - parameter completion: タイマー発火時の処理
    /// - returns: 動作中のNSTimerオブジェクト
    open class func start(_ time: TimeInterval, completion: @escaping CompletionHandler) -> Timer {
        let timer = NBTimer()
        NBTimer.timers.append(timer)
        
        timer.completion = completion
        timer.timer = Timer.scheduledTimer(
            timeInterval: time,
            target:   timer,
            selector: #selector(NBTimer.didFireTimer),
            userInfo: nil,
            repeats:  false
        )
        return timer.timer!
    }
    
    fileprivate static var timers: [NBTimer] = []
    
    fileprivate var completion: CompletionHandler!
    
    fileprivate weak var timer: Timer?
    
    @objc fileprivate func didFireTimer() {
        self.completion()
        self.timer = nil
        
        if let index = NBTimer.timers.index(of: self) {
            NBTimer.timers.remove(at: index.hashValue)
        }
    }
}
