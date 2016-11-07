// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

/// 長押し可能のボタン
open class NBLongPressableButton: UIButton {
    
    public typealias PressingClosure = (UInt64) -> Void
    
    /// 長押しが継続されるごとに呼ばれるクロージャ
    /// - parameter times: 長押しの検知開始からクロージャが呼ばれた回数
    open var pressing: PressingClosure?
    
    /// 長押しが開始された時に呼ばれるクロージャ
    open var started: VoidClosure?
    
    /// 長押しをやめた時に呼ばれるクロージャ
    open var finished: VoidClosure?
    
    /// 最初の長押しを感知するまでに要する秒数
    @IBInspectable open var recognizeDuration : Double = 1.2 { // as CFTimeInterval
        didSet { let v = self.recognizeDuration
            if self.longPressRecognizer != nil {
                self.longPressRecognizer.minimumPressDuration = v
            }
        }
    }
    
    /// 次の長押しを感知するまでの間隔
    @IBInspectable open var continuousInterval: Double = 0.1 // as CFTimeInterval
    
    /// 次の長押しを感知するまでの間隔を変更して加速度を変化させる
    /// - parameter interval: 次の長押しを感知するまでの間隔
    open func accelerate(_ interval: TimeInterval) {
        if self.acceleratedContinuousInterval != interval {
            self.acceleratedContinuousInterval = interval
        }
    }
    
    /// PressingClosureで得た回数の値から適度な加速度間隔を返す
    /// - parameter times: クロージャが呼ばれた回数
    /// - returns: 加速度間隔(acceleratedContinuousIntervalプロパティに渡す)
    open class func templateIntervalForAccelerate(_ times: UInt64) -> TimeInterval {
        switch times {
        case   0...10:  return 0.1
        case  11...20:  return 0.09
        case  21...30:  return 0.08
        case  31...40:  return 0.07
        case  41...50:  return 0.06
        case  51...60:  return 0.05
        case  61...70:  return 0.03
        case  71...80:  return 0.015
        case  81...90:  return 0.012
        case  91...100: return 0.01
        case 101...110: return 0.006
        case 111...120: return 0.003
        default: return 0.001
        }
    }
    
    // MARK: プライベート
    
    fileprivate var times: UInt64 = 0
    fileprivate var acceleratedContinuousInterval: TimeInterval = 0.0
    fileprivate var longPressRecognizer: UILongPressGestureRecognizer!
    fileprivate var longPressTimer: Timer?
    fileprivate var touchesStarted: CFTimeInterval?

    fileprivate func commonInitialize() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(NBLongPressableButton.didRecognizeLongPress(_:)))
        lpgr.cancelsTouchesInView = false
        lpgr.minimumPressDuration = self.recognizeDuration
        self.addGestureRecognizer(lpgr)
        
        self.longPressRecognizer = lpgr
    }
    
    @objc fileprivate func didRecognizeLongPress(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began: self.didBeginPressButton()
        case .ended: self.didEndPressButton()
        default:break
        }
    }
    
    fileprivate func didBeginPressButton() {
        if self.touchesStarted != nil { return }
        
        self.touchesStarted = CACurrentMediaTime()
        self.started?()
        self.startLongPressTimer()
    }
    
    fileprivate func didEndPressButton() {
        if self.touchesStarted != nil {
            self.touchesStarted = nil
            self.stopLongPressTimer()
            self.finished?()
        }
    }

    fileprivate func startLongPressTimer() {
        self.times = 0
        self.acceleratedContinuousInterval = self.continuousInterval
        self.executeNextLongPressTimer()
    }
    
    @objc fileprivate func didFireLongPressTimer(_ timer: Timer) {
        self.times = (self.times < UINT64_MAX) ? self.times + 1 : UINT64_MAX
        self.pressing?(self.times)
        self.executeNextLongPressTimer()
    }
    
    fileprivate func executeNextLongPressTimer() {
        self.longPressTimer = Timer.scheduledTimer(
            timeInterval: self.acceleratedContinuousInterval,
            target:   self,
            selector: #selector(NBLongPressableButton.didFireLongPressTimer(_:)),
            userInfo: nil,
            repeats:  false
        )
    }
    
    fileprivate func stopLongPressTimer() {
        if let timer = self.longPressTimer, timer.isValid {
            timer.invalidate()
        }
        self.longPressTimer = nil
    }
    
    override public init (frame : CGRect) { super.init(frame : frame); commonInitialize() }
    convenience public init () { self.init(frame:CGRect.zero) }
    required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); commonInitialize() }
}
