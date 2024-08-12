// Check if the two values are Equatable and equal
func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    guard let lhs = lhs as? any Equatable else { return false }
    func f<LHS: Equatable>(_ lhs: LHS) -> Bool {
        guard let rhs = rhs as? LHS else { return false }
        return lhs == rhs
    }
    return f(lhs)
}
