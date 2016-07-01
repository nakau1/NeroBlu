// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

/// タイマークラス
public class NBTimer: NSObject {
    
    /// タイマーを開始する
    /// - parameter time: タイマー時間
    /// - parameter completion: タイマー発火時の処理
    /// - returns: 動作中のNSTimerオブジェクト
    public class func start(time: NSTimeInterval, completion: CompletionHandler) -> NSTimer {
        let timer = NBTimer()
        NBTimer.timers.append(timer)
        
        timer.completion = completion
        timer.timer = NSTimer.scheduledTimerWithTimeInterval(
            time,
            target:   timer,
            selector: #selector(NBTimer.didFireTimer),
            userInfo: nil,
            repeats:  false
        )
        return timer.timer!
    }
    
    private static var timers: [NBTimer] = []
    
    private var completion: CompletionHandler!
    
    private weak var timer: NSTimer?
    
    @objc private func didFireTimer() {
        self.completion()
        self.timer = nil
        
        if let index = NBTimer.timers.indexOf(self) {
            NBTimer.timers.removeAtIndex(index.hashValue)
        }
    }
}
