//
//  ViewController.swift
//  NeroBluDemo
//
import UIKit
import NeroBlu

class ViewController: NBLandingViewController {
    
    override var items: [(title: String, rows: [NBLandingItem])] {
        return [
            (title:"動作確認", rows:[
                NBLandingItem("動作確認(1)") {
                    var arr = [3, 8, 11, 23, 45, 62, 95]
                    print(arr.indexInRange(for: -1)) // 0
                    print(arr.indexInRange(for: 4))  // 4
                    print(arr.indexInRange(for: 7))  // 6
                    print(arr.indexInRange(for: 12)) // 6
                    
                    print(arr.elementInRange(for: 10))  // 95
                    print(arr.elementInRange(for: -2))  // 3
                    
                    print(arr.nextLoopIndex(of: 4)) // 5
                    print(arr.nextLoopIndex(of: 5)) // 6
                    print(arr.nextLoopIndex(of: 6)) // 0
                    
                    print(arr.previousLoopIndex(of: 2)) // 1
                    print(arr.previousLoopIndex(of: 1)) // 0
                    print(arr.previousLoopIndex(of: 0)) // 6
                    
                    let _ = arr.exchange(from: 3, to: 0)
                    print(arr) // [23, 8, 11, 3, 45, 62, 95]
                },
                ]),
            (title:"NB+CGGeometry", rows:[
                NBLandingItem("CGRect(1) - 反転") {
                    var r = cr0
                    r.update(w: 100, h: 50)
                    r.p = cp(30, 60)
                    print(r.p.reverse()) // (60.0, 30.0, 100.0, 50.0)
                },
                NBLandingItem("CGRect(2) - 四辺取得") {
                    let r = cr(origin: cp(10, 20), size: cs(30, 40))
                    print(r.x, r.y, r.r, r.b) // (10.0, 20.0, 40.0, 60.0)
                },
                NBLandingItem("CGRect(3) - 文字列での指定可能") {
                    let r = CGRect(12, 34, 56.0, 78.9)
                    print(r) // (12.0, 34.0, 56.0, 78.9)
                },
                NBLandingItem("CGRect(4) - 中央位置指定") {
                    let r = CGRect(center: cp(100, 40), size: cs(50, 50))
                    print(r) // (75.0, 15.0, 50.0, 50.0)
                },
                ]),
            (title:"NB+Collection", rows:[
                NBLandingItem("Array First/Last Index") {
                    let arr = [1, 2, 3, 4, 5, 6]
                    print(arr.firstIndex!) // 0
                    print(arr.lastIndex!) // 5
                },
                NBLandingItem("Array Random") {
                    let arr1 = [12, 24, 32, 45, 56, 67]
                    print(arr1.random)
                    
                    let arr2 = ["あ", "い", "う", "え", "お"]
                    print(arr2.random)
                },
                NBLandingItem("Dictionary Merge") {
                    var dic = ["A": 1, "B": 2, "C": 3]
                    dic.merge(dictionary: ["D": 4, "E": 5])
                    print(dic)
                },
                NBLandingItem("Dictionary Merged") {
                    let dic = ["A": 1, "B": 2, "C": 3]
                    let dic2 = dic.merged(dictionary: ["D": 4, "E": 5])
                    print(dic)
                    print(dic2)
                },
                ]),
            (title:"NB+NSError", rows:[
                NBLandingItem("Error Function") {
                    let err = Error("This is NG", 100, "Hoge")
                    print(err) // Error Domain=Hoge Code=100 "This is NG" UserInfo={NSLocalizedDescription=This is NG}
                    print(err.message) // "This is NG"
                },
                ]),
            (title:"NB+Number", rows:[
                NBLandingItem("Random And Format") {
                    let i = Int.random(min: 800, max: 10000)
                    print(i.formatted)
                },
                NBLandingItem("Int to Float") {
                    print(12345.f)
                },
                NBLandingItem("Double to String") {
                    print(324.34.string + "%")
                },
                ]),
            (title:"NB+String", rows:[
                NBLandingItem("Length") {
                    let str = "ABC🆎✊あああ"
                    print(str.length) // 8
                },
                NBLandingItem("Localize") {
                    print("Hello".localize())
                },
                NBLandingItem("Format") {
                    let n = Int.random(min: 0, max: 10)
                    print("Random: %02d".format(n))
                },
                NBLandingItem("Empty To Nil") {
                    print("AB".emptyToNil)
                    print("A".emptyToNil)
                    print("".emptyToNil)
                },
                NBLandingItem("Empty To Substitute") {
                    print("AB".emptyTo("This is Empty"))
                    print("A".emptyTo("This is Empty"))
                    print("".emptyTo("This is Empty"))
                },
                NBLandingItem("Replace") {
                    let str = "He is Taro"
                    print(str.replace("Taro", "Jiro")) // He is Jiro
                    print(str.replace(NSMakeRange(0, 2), "She")) // She is Taro
                },
                NBLandingItem("Split And Join") {
                    let str = "He is Taro"
                    let arr = str.splitByWhitespace()
                    
                    print(arr) // ["He", "is", "Taro"]
                    print(join(arr, "-")) //"He-is-Taro"
                },
                NBLandingItem("Substring") {
                    print("abcdef".substring(location: 1))              // bcdef
                    print("abcdef".substring(location: 1, length: 3))   // bcd
                    print("abcdef".substring(location: 0, length: 4))   // abcd
                    print("abcdef".substring(location: 0, length: 8))   // abcdef
                    print("abcdef".substring(location: -1, length: 1))  // f
                    print("abcdef".substring(location: -1))             // f
                    print("abcdef".substring(location: -2))             // ef
                    print("abcdef".substring(location: -3, length: 1))  // d
                    print("abcdef".substring(location: 0, length: -1))  // abcde
                    print("abcdef".substring(location: 2, length: -1))  // cde
                    print("abcdef".substring(location: 4, length: -4))  //
                    print("abcdef".substring(location: -3, length: -1)) // de
                },
                NBLandingItem("Substring with Range") {
                    print("abcdef".substring(range: NSMakeRange(2, 2))) // cd
                },
                NBLandingItem("Regular Expression") {
                    let ptn = "[a-z]+@[a-z]+\\.[a-z]{3}"
                    print("abc@efg.com".isMatched(ptn))      // true
                    print("abcdef@efghi.org".isMatched(ptn)) // true
                    print("abc@efg.jp".isMatched(ptn))       // false
                    print("abc@efg".isMatched(ptn))          // false
                    print("abc".isMatched(ptn))              // false
                },
                NBLandingItem("Transform") {
                    print("ABCdefg".fullWidth)
                    print("ABCdefg".halfWidth)
                    print("ABCdefg".latinToHiragana)
                    print("ABCdefg".latinToKatakana)
                    print("アイウえお".katakanaToHiragana)
                },
                ]),
        ]
    }
    
    // MARK: NB+NSNotification
    
    let notificationsAndSelectors = ["TestNotification" : "didNotify:"]
    
    func didNotify(_ notify: Notification) {
        print("Notified!")
    }
}
