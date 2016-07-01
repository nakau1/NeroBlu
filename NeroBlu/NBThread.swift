// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

/// メインスレッド(キュー)との同期をとって処理を実行する
/// - parameter block: メインスレッドで行う処理
public func onMainThread(block: VoidClosure) {
    dispatch_async(dispatch_get_main_queue(), block)
}

/// 新しいスレッド(キュー)との同期をとって処理を実行する
/// - parameter block: 新しいスレッドで行う処理
public func onNewThread(block: VoidClosure) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
}

/// 非同期処理を行う
/// - parameter async: 非同期処理(別スレッドで実行する処理)
/// - parameter completed: 非同期処理完了時に行う処理
public func async(async asynchronousProcess: VoidClosure, completed completionHandler: VoidClosure) {
    onNewThread {
        asynchronousProcess()
        onMainThread {
            completionHandler()
        }
    }
}

/// 秒を指定して非同期処理でスリープを行う
/// - parameter seconds: スリープ秒数
/// - parameter completed: スリープ完了時に行う処理
public func asyncSleep(seconds seconds: UInt32, completed: VoidClosure) {
    async(async: { sleep(seconds) }, completed: completed)
}

/// ミリ秒を指定して非同期処理でスリープを行う
/// - parameter milliseconds: スリープのミリ秒数
/// - parameter completed: スリープ完了時に行う処理
public func asyncSleep(milliseconds: useconds_t, completed: VoidClosure) {
    async(async: { usleep(milliseconds) }, completed: completed)
}

/// スリープ間隔を指定して非同期処理でスリープを行う
/// - parameter duration: スリープ間隔
/// - parameter completed: スリープ完了時に行う処理
public func asyncSleep(duration: NSTimeInterval, completed: VoidClosure) {
    async(async: { usleep(useconds_t(duration * 1000000)) }, completed: completed)
}
