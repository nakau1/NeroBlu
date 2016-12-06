// =============================================================================
// NBRealm
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - String拡張 -
public extension String {
    
    /// Realm用にエスケープした文字列
    public var realmEscaped: String {
        let reps = [
            "\\" : "\\\\",
            "'"  : "\\'",
            ]
        var ret = self
        for rep in reps {
            ret = self.replacingOccurrences(of: rep.0, with: rep.1)
        }
        return ret
    }
}
