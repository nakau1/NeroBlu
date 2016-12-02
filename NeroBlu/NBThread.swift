// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

/// メインスレッド(キュー)との同期をとって処理を実行する
/// - parameter block: メインスレッドで行う処理
public func onMainThread(_ block: @escaping VoidClosure) {
    DispatchQueue.main.async(execute: block)
}

/// 新しいスレッド(キュー)との同期をとって処理を実行する
/// - parameter block: 新しいスレッドで行う処理
public func onNewThread(_ block: @escaping VoidClosure) {
   DispatchQueue.global(qos: .default).async(execute: block)
}

/// 非同期処理を行う
/// - parameter async: 非同期処理(別スレッドで実行する処理)
/// - parameter completed: 非同期処理完了時に行う処理
public func async(async asynchronousProcess: @escaping VoidClosure, completed completionHandler: @escaping VoidClosure) {
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
public func asyncSleep(seconds: UInt32, completed: @escaping VoidClosure) {
    async(async: { sleep(seconds) }, completed: completed)
}

/// ミリ秒を指定して非同期処理でスリープを行う
/// - parameter milliseconds: スリープのミリ秒数
/// - parameter completed: スリープ完了時に行う処理
public func asyncSleep(_ milliseconds: useconds_t, completed: @escaping VoidClosure) {
    async(async: { usleep(milliseconds) }, completed: completed)
}

/// スリープ間隔を指定して非同期処理でスリープを行う
/// - parameter duration: スリープ間隔
/// - parameter completed: スリープ完了時に行う処理
public func asyncSleep(_ duration: TimeInterval, completed: @escaping VoidClosure) {
    async(async: { usleep(useconds_t(duration * 1000000)) }, completed: completed)
}
