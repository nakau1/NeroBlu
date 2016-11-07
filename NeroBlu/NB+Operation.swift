// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

/// CGSizeを等倍で拡大する演算子
public func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(lhs.width * rhs, lhs.height * rhs)
}

/// CGPointを等倍で拡大する演算子
public func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(lhs.x * rhs, lhs.y * rhs)
}

/// CGSizeを等倍で拡大する演算子
public func *= (lhs: inout CGSize, rhs: CGFloat) {
    lhs = lhs * rhs
}

/// CGPointを等倍で拡大する演算子
public func *= (lhs: inout CGPoint, rhs: CGFloat) {
    lhs = lhs * rhs
}
