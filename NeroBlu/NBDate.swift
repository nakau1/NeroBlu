// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBDateWeek -

/// 曜日
public enum NBDateWeek: Int {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
    
    /// 曜日の数
    public static let count = 7
    
    /// 開始曜日から並べた配列
    /// - parameter startWeek: 開始曜日
    /// - returns: NBDateWeekの配列
    public static func weeks(_ startWeek: NBDateWeek) -> [NBDateWeek] {
        var ret = [NBDateWeek]()
        for i in 0..<NBDateWeek.count {
            let n = startWeek.rawValue + i
            let m = (n < NBDateWeek.count) ? n : n - NBDateWeek.count
            ret.append(NBDateWeek(rawValue: m)!)
        }
        return ret
    }
}

// MARK: - NBDateMonth -

/// 月
public enum NBDateMonth: Int {
    case january, february, march, april, may, june, july, august, september, october, november, december
    
    /// 月の数
    public static let count = 12
    
    /// 月
    public var month: Int { return self.rawValue + 1 }
}

// MARK: - NBDate -

/// 日付クラス
open class NBDate: CustomStringConvertible {
    
    /// 取り扱うNSDateオブジェクト
    fileprivate(set) var date = Date()
    
    /// カレンダーオブジェクト
    open var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    /// デフォルトの出力日付フォーマット
    open static var defaultOutputFormat = "yyyy/MM/dd HH:mm:ss"
    
    /// デフォルトの入力日付フォーマット
    open static var defaultInputFormat = "yyyy-MM-dd HH:mm:ss"
    
    /// イニシャライザ
    /// - parameter date: 日付
    public init(date: Date) {
        self.date = date
    }
}

// MARK: - NBDate: コンビニエンスイニシャライザ -
public extension NBDate {
    
    /// イニシャライザ
    /// - parameter year: 年
    /// - parameter month: 月
    /// - parameter day: 日
    /// - parameter hour: 時
    /// - parameter minute: 分
    /// - parameter second: 秒
    public convenience init(year y: Int? = nil, month m: Int? = nil, day d: Int? = nil, hour h: Int? = nil, minute i: Int? = nil, second s: Int? = nil) {
        self.init(date: Date())
        self.date = self.date(year: y, month: m, day: d, hour: h, minute: i, second: s)
    }
}

// MARK: - NBDate: 日付コンポーネントの取得/設定 -
public extension NBDate {
    
    /// 年
    public var year: Int {
        get    { return (self.calendar as NSCalendar).components(.year, from: self.date).year! }
        set(v) { self.date = self.date(year: v) }
    }
    
    /// 月
    public var month: Int {
        get    { return (self.calendar as NSCalendar).components(.month, from: self.date).month! }
        set(v) { self.date = self.date(month: v) }
    }
    
    /// 日
    public var day: Int {
        get    { return (self.calendar as NSCalendar).components(.day, from: self.date).day! }
        set(v) { self.date = self.date(day: v) }
    }
    
    /// 時
    public var hour: Int {
        get    { return (self.calendar as NSCalendar).components(.hour, from: self.date).hour! }
        set(v) { self.date = self.date(hour: v) }
    }
    
    /// 分
    public var minute: Int {
        get    { return (self.calendar as NSCalendar).components(.minute, from: self.date).minute! }
        set(v) { self.date = self.date(minute: v) }
    }
    
    /// 秒
    public var second: Int {
        get    { return (self.calendar as NSCalendar).components(.second, from: self.date).second! }
        set(v) { self.date = self.date(second: v) }
    }
}

// MARK: - NBDate: 読取専用の日付コンポーネント -
extension NBDate {
    
    /// 曜日
    public var week: NBDateWeek { return NBDateWeek(rawValue: self.weekIndex)! }
    
    /// 曜日インデックス
    public var weekIndex: Int { return (self.calendar as NSCalendar).components(.weekday, from: self.date).weekday! - 1 }
    
    /// 月オブジェクト(enum)
    public var monthObject: NBDateMonth { return NBDateMonth(rawValue: self.monthIndex)! }
    
    /// 月インデックス
    public var monthIndex: Int { return self.month - 1 }
    
    /// 月の最終日
    public var lastDayOfMonth: Int { return NBDate(year: self.year, month: self.month + 1, day: 0).day }
}

// MARK: - NBDate: 日付コンポーネントの文字列取得 -
extension NBDate {
    
    /// 曜日名 ... 月/Mon
    public var weekName: String { return self.localizedName({ fmt in fmt.shortWeekdaySymbols }, index: self.weekIndex) }
    
    /// 曜日名(Long) ... 月曜日/Monday
    public var weekLongName: String { return self.localizedName({ fmt in fmt.weekdaySymbols }, index: self.weekIndex) }
    
    /// 曜日名(Short) ... 月/M
    public var weekShortName: String { return self.localizedName({ fmt in fmt.veryShortWeekdaySymbols }, index: self.weekIndex) }
    
    /// 月名 ... 4月/April
    public var monthName: String { return self.localizedName({ fmt in fmt.monthSymbols }, index: self.monthIndex) }
    
    /// 月名(Short) ... 4月/Apr
    public var monthShortName: String { return self.localizedName({ fmt in fmt.shortMonthSymbols }, index: self.monthIndex) }
    
    /// 和暦
    public var japaneseYearName: String {
        let fmt = DateFormatter()
        fmt.calendar = Calendar(identifier: Calendar.Identifier.japanese)
        fmt.locale = Locale.current
        fmt.formatterBehavior = .behavior10_4
        fmt.dateFormat = "GG"
        var ret = fmt.string(from: self.date)
        
        fmt.dateFormat = "y"
        let year = fmt.string(from: self.date)
        if self.isJapaneseLocale {
            ret += (year == "1") ? "元" : year
            ret += "年"
        } else {
            ret += year
        }
        return ret
    }
}

// MARK: - NBDate: 日付文字列取得 -
public extension NBDate {
    
    /// 日付文字列
    public var string: String {
        return self.string(NBDate.defaultOutputFormat)
    }
    
    /// 指定した日付フォーマットから文字列を生成する
    /// - parameter format: 日付フォーマット
    /// - returns: 日付文字列
    public func string(_ format: String) -> String {
        return self.dateFormatter(format).string(from: self.date)
    }
    
    /// 指定した日付フォーマットから日付フォーマッタを生成する
    /// - parameter format: 日付フォーマット
    /// - returns: 日付フォーマッタ
    public func dateFormatter(_ format: String) -> DateFormatter {
        let fmt = DateFormatter()
        fmt.calendar   = self.calendar
        fmt.dateFormat = format
        fmt.locale     = Locale.current
        fmt.timeZone   = TimeZone.current
        return fmt
    }
    
    public var description: String { return self.string }
}

// MARK: - NBDate: 文字列からのNBDate取得 -
public extension NBDate {
    
    /// 文字列からNBDateを生成する
    /// - parameter format: 日付フォーマット
    /// - parameter format: 日付フォーマット(省略した場合は)
    /// - returns: 日付文字列
    public class func create(string: String, format: String? = nil) -> NBDate? {
        let temp = NBDate()
        let fmt = format ?? NBDate.defaultInputFormat
        guard let d = temp.dateFormatter(fmt).date(from: string) else { return nil }
        return NBDate(date: d)
    }
}

// MARK: - NBDate: ファクトリ -
public extension NBDate {
    
    /// 新しいNBDateオブジェクトを生成する
    /// 
    /// イニシャライザによる生成とは時刻の省略時に0にする点が異なります
    /// - parameter year: 年
    /// - parameter month: 月
    /// - parameter day: 日
    /// - parameter hour: 時(省略した場合は0)
    /// - parameter minute: 分(省略した場合は0)
    /// - parameter second: 秒(省略した場合は0)
    /// - returns: 新しいインスタンス
    public class func create(_ year: Int, _ month: Int, _ day: Int, _ hour: Int? = nil, _ minute: Int? = nil, _ second: Int? = nil) -> NBDate {
        return NBDate(
            year:   year,
            month:  month,
            day:    day,
            hour:   hour   ?? 0,
            minute: minute ?? 0,
            second: second ?? 0
        )
    }
    
    /// 現時刻を指す新しいインスタンス
    public class var now: NBDate {
        return NBDate(date: Date())
    }
    
    /// 今日の00:00の時刻を指す新しいインスタンス
    public class var today: NBDate {
        let ret = self.now
        //ret.oclock()
        return ret
    }
    
    /// 値をコピーした新しいインスタンスを返す
    /// - returns: 新しいインスタンス
    public func clone() -> NBDate {
        return NBDate(date: self.date)
    }
}

// MARK: - NBDate: 日付コンポーネントの変更 -
public extension NBDate {
    
    /// 指定した年に変更する
    /// - parameter value: 設定する年
    /// - returns: 自身の参照
    public func modifyYear(_ value: Int) -> Self {
        self.date = self.date(year: value)
        return self
    }
    
    /// 指定した月に変更する
    /// - parameter value: 設定する月
    /// - returns: 自身の参照
    public func modifyMonth(_ value: Int) -> Self {
        self.date = self.date(month: value)
        return self
    }
    
    /// 指定した日に変更する
    /// - parameter value: 設定する日
    /// - returns: 自身の参照
    public func modifyDay(_ value: Int) -> Self {
        self.date = self.date(day: value)
        return self
    }
    
    /// 指定した時に変更する
    /// - parameter value: 設定する時
    /// - returns: 自身の参照
    public func modifyHour(_ value: Int) -> Self {
        self.date = self.date(hour: value)
        return self
    }
    
    /// 指定した分に変更する
    /// - parameter value: 設定する分
    /// - returns: 自身の参照
    public func modifyMinute(_ value: Int) -> Self {
        self.date = self.date(minute: value)
        return self
    }
    
    /// 指定した秒に変更する
    /// - parameter value: 設定する秒
    /// - returns: 自身の参照
    public func modifySecond(_ value: Int) -> Self {
        self.date = self.date(second: value)
        return self
    }
}

// MARK: - NBDate: 日付コンポーネントの加算 -
public extension NBDate {
    
    /// 指定した年数を足す
    /// - parameter add: 追加する年
    /// - returns: 自身の参照
    public func addYear(_ add: Int = 1) -> Self {
        self.date = self.date(year: self.year + add)
        return self
    }
    
    /// 指定した月数を足す
    /// - parameter add: 追加する月
    /// - returns: 自身の参照
    public func addMonth(_ add: Int = 1) -> Self {
        self.date = self.date(month: self.month + add)
        return self
    }
    
    /// 指定した日数を足す
    /// - parameter add: 追加する日
    /// - returns: 自身の参照
    public func addDay(_ add: Int = 1) -> Self {
        self.date = self.date(day: self.day + add)
        return self
    }
    
    /// 指定した時数を足す
    /// - parameter add: 追加する時
    /// - returns: 自身の参照
    public func addHour(_ add: Int = 1) -> Self {
        self.date = self.date(hour: self.hour + add)
        return self
    }
    
    /// 指定した分数を足す
    /// - parameter add: 追加する分
    /// - returns: 自身の参照
    public func addMinute(_ add: Int = 1) -> Self {
        self.date = self.date(minute: self.minute + add)
        return self
    }
    
    /// 指定した秒数を足す
    /// - parameter add: 追加する分
    /// - returns: 自身の参照
    public func addSecond(_ add: Int = 1) -> Self {
        self.date = self.date(second: self.second + add)
        return self
    }
}

// MARK: - NBDate: 日付コンポーネントの調整 -
public extension NBDate {
    
    /// 時刻をその日の00:00に設定する
    public func oclock() -> Self {
        self.date = self.date(year: self.year, month: self.month, day: self.day, hour: 0, minute: 0, second: 0)
        return self
    }
    
    /// 日付をその月の1日に設定する
    public func toFirstDayOfMonth() -> Self {
        self.date = self.date(year: self.year, month: self.month, day: 1, hour: 0, minute: 0, second: 0)
        return self
    }
    
    /// 日付をその年の1月1日に設定する
    public func toFirstDayOfYear() -> Self {
        self.date = self.date(year: self.year, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        return self
    }
}

// MARK: - NBDate: 比較 -
public extension NBDate {
    
    /// 比較を行う(NSDate#cpmpare(_:)のラッパ)
    /// - parameter date: 比較対象の日付
    /// - returns: 比較結果
    public func compare(_ date: NBDate) -> ComparisonResult {
        return self.date.compare(date.date)
    }
    
    /// 同じ日時かどうかを取得する
    /// - parameter date: 比較対象の日付
    /// - returns: 同じ日時かどうか
    public func isSame(_ date: NBDate) -> Bool {
        return self.compare(date) == .orderedSame
    }
    
    /// 自身が対象の日付よりも未来の日付かどうかを取得する
    /// - parameter date: 比較対象の日付
    /// - returns: 自身が未来かどうか
    public func isFuture(than date: NBDate) -> Bool {
        return self.compare(date) == .orderedDescending
    }
    
    /// 自身が対象の日付よりも過去の日付かどうかを取得する
    /// - parameter date: 比較対象の日付
    /// - returns: 自身が過去かどうか
    public func isPast(than date: NBDate) -> Bool {
        return self.compare(date) == .orderedAscending
    }
    
    /// 日付のみを比較して同じ日付かどうかを取得する
    /// - parameter date: 比較対象の日付
    /// - returns: 同じ日付かどうか(時刻は比較しません)
    public func isSameDay(_ date: NBDate) -> Bool {
        let flags: NSCalendar.Unit = [.year, .month, .day]
        let comps1 = (self.calendar as NSCalendar).components(flags, from: self.date)
        let comps2 = (self.calendar as NSCalendar).components(flags, from: date.date)
        return ((comps1.year == comps2.year) && (comps1.month == comps2.month) && (comps1.day == comps2.day))
    }
    
    /// 時刻のみを比較して同じ時刻かどうかを取得する
    /// - parameter date: 比較対象の日付
    /// - returns: 同じ時刻かどうか(日付は比較しません)
    public func isSameTime(_ date: NBDate) -> Bool {
        let flags: NSCalendar.Unit = [.hour, .minute, .second]
        let comps1 = (self.calendar as NSCalendar).components(flags, from: self.date)
        let comps2 = (self.calendar as NSCalendar).components(flags, from: date.date)
        return ((comps1.hour == comps2.hour) && (comps1.minute == comps2.minute) && (comps1.second == comps2.second))
    }
    
    /// 日付が今日かどうか
    public var isToday: Bool {
        return self.isSameDay(NBDate())
    }
    
    /// 日付が明日かどうか
    public var isTomorrow: Bool {
        return self.isSameDay(NBDate().addDay())
    }
    
    /// 日付が昨日かどうか
    public var isYesterday: Bool {
        return self.isSameDay(NBDate().addDay(-1))
    }
    
    /// 日付が日曜日かどうか
    public var isSunday: Bool {
        return self.week == .sunday
    }
    
    /// 日付が土曜日かどうか
    public var isSaturday: Bool {
        return self.week == .saturday
    }
    
    /// 日付が平日かどうか
    public var isUsualDay: Bool {
        return !self.isSunday && !self.isSaturday
    }
}

// MARK: - NBDate: 配列生成 -
public extension NBDate {
    
    /// 指定した月の日付すべてを配列で取得する
    /// - parameter year: 年
    /// - parameter month: 月
    /// - returns: NBDateの配列
    class func datesInMonth(year: Int, month: Int) -> [NBDate] {
        var ret = [NBDate]()
        
        let lastDay = NBDate.create(year, month, 1).lastDayOfMonth
        for day in 1...lastDay {
            ret.append(NBDate.create(year, month, day))
        }
        
        return ret
    }
    
    /// 指定した月の日付をカレンダー用にすべて配列で取得する
    /// - parameter year: 年
    /// - parameter month: 月
    /// - parameter startWeek: 開始曜日
    /// - returns: NBDateの配列
    class func datesForCalendarInMonth(year: Int, month: Int, startWeek: NBDateWeek = .sunday) -> [NBDate] {
        var ret = [NBDate]()
        
        let lastDay = NBDate.create(year, month, 1).lastDayOfMonth
        let weeks = NBDateWeek.weeks(startWeek)
        
        for day in 1...lastDay {
            let date = NBDate.create(year, month, day)
            
            if day == 1 {
                if let weekIndex = weeks.index(of: date.week) {
                    for j in 0..<weekIndex {
                        ret.append(date.clone().addDay((weekIndex - j) * -1))
                    }
                }
            }
            
            ret.append(date)
            
            if day == lastDay {
                if let weekIndex = weeks.index(of: date.week), weekIndex + 1 < NBDateWeek.count {
                    for _ in (weekIndex + 1)..<NBDateWeek.count {
                        ret.append(date.clone().addDay())
                    }
                }
            }
        }
        return ret
    }
}

// MARK: - NBDate: ブライベート -
private extension NBDate {
    
    func date(year y: Int? = nil, month m: Int? = nil, day d: Int? = nil, hour h: Int? = nil, minute i: Int? = nil, second s: Int? = nil) -> Date {
        var comps = DateComponents()
        comps.year   = y ?? self.year
        comps.month  = m ?? self.month
        comps.day    = d ?? self.day
        comps.hour   = h ?? self.hour
        comps.minute = i ?? self.minute
        comps.second = s ?? self.second
        return self.calendar.date(from: comps)!
    }
    
    func localizedName(_ symbols: (DateFormatter) -> [String]!, index: Int) -> String {
        let fmt = DateFormatter()
        fmt.calendar = self.calendar
        fmt.locale = Locale.current
        return symbols(fmt)[index]
    }
    
    var isJapaneseLocale: Bool { return Locale.current.identifier == "ja_JP" }
}


