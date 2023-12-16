func ==<A, B: Equatable>(
	lhs: KeyPath<A, B>,
	rhs: B
) -> (A) -> Bool {
	return { a in
		a[keyPath: lhs] == rhs
	}
}

func !=<A, B: Equatable>(
	lhs: KeyPath<A, B>,
	rhs: B
) -> (A) -> Bool {
	return { a in
		a[keyPath: lhs] != rhs
	}
}

func ||<A>(
	lhs: @escaping (A) -> Bool,
	rhs: @escaping (A) -> Bool
) -> (A) -> Bool {
	return { a in
		lhs(a) || rhs(a)
	}
}

func &&<A>(
	lhs: @escaping (A) -> Bool,
	rhs: @escaping (A) -> Bool
) -> (A) -> Bool {
	return { a in
		lhs(a) && rhs(a)
	}
}

prefix func !<A>(
	f: @escaping (A) -> Bool
) -> (A) -> Bool {
	return { a in
		!f(a)
	}
}
