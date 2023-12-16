import FunctionalKeyPath

extension Resettable where Object: Collection {
	public var collection: WritableCollectionProxy<Object> {
		WritableCollectionProxy(
			resettable: self,
			keyPath: .init(
				embed: { value, root in
					return value
				}, extract: { root in
					return root
				}
			)
		)
	}
}

extension Resettable {
	public struct WritableCollectionProxy<Collection> where Collection: Swift.Collection {
		@usableFromInline
		internal init(
			resettable: Resettable<Object>,
			keyPath: FunctionalKeyPath<Object, Collection>
		) {
			self.resettable = resettable
			self.keyPath = keyPath
		}

		var resettable: Resettable
		var keyPath: FunctionalKeyPath<Object, Collection>

		public subscript(_ idx: Collection.Index) -> KeyPathContainer<Collection.Element> {
			return KeyPathContainer(
				resettable: resettable,
				keyPath: keyPath.appending(path: .getonlyIndex(idx))
			)
		}

		public subscript(_ idx: Collection.Index) -> WritableKeyPathContainer<Collection.Element>
		where Collection: Swift.MutableCollection {
			return WritableKeyPathContainer(
				resettable: resettable,
				keyPath: keyPath.appending(path: .index(idx))
			)
		}

		public subscript<T>(safe idx: Collection.Index) -> WritableKeyPathContainer<Collection.Element?>
		where Collection == Array<T> {
			return WritableKeyPathContainer(
				resettable: resettable,
				keyPath: keyPath.appending(path: FunctionalKeyPath.safeIndex(idx))
			)
		}
	}

	public struct CollectionProxy<Collection> where Collection: Swift.Collection {
		@usableFromInline
		internal init(
			resettable: Resettable<Object>,
			keyPath: FunctionalKeyPath<Object, Collection>
		) {
			self.resettable = resettable
			self.keyPath = keyPath
		}

		var resettable: Resettable
		var keyPath: FunctionalKeyPath<Object, Collection>

		public subscript(_ idx: Collection.Index) -> KeyPathContainer<Collection.Element> {
			return KeyPathContainer(
				resettable: resettable,
				keyPath: keyPath.appending(path: .getonlyIndex(idx))
			)
		}

		public subscript<T>(safe idx: Collection.Index) -> KeyPathContainer<Collection.Element?>
		where Collection == Array<T> {
			return KeyPathContainer(
				resettable: resettable,
				keyPath: keyPath.appending(path: FunctionalKeyPath.safeIndex(idx))
			)
		}
	}
}

extension Resettable.WritableCollectionProxy {
	@discardableResult
	public func swapAt<T>(_ idx1: Collection.Index, _ idx2: Collection.Index, operation: Resettable.OperationBehavior = .default) -> Resettable
	where Collection == Array<T> {
		resettable._modify(
			operation: operation,
			keyPath,
			using: { $0.swapAt(idx1, idx2) },
			undo: { $0.swapAt(idx1, idx2) }
		)
	}

	@discardableResult
	public func remove<T>(at idx: Collection.Index, operation: Resettable.OperationBehavior = .default) -> Resettable
	where Collection == Array<T> {
		let valueSnapshot = keyPath.extract(from: resettable.wrappedValue)[idx]
		return resettable._modify(
			operation: operation,
			keyPath,
			using: { $0.remove(at: idx) },
			undo: { $0.insert(valueSnapshot, at: idx) }
		)
	}

	@discardableResult
	public func insert<T>(_ element: Collection.Element, at idx: Collection.Index, operation: Resettable.OperationBehavior = .default) -> Resettable
	where Collection == Array<T> {
		return resettable._modify(
			operation: operation,
			keyPath,
			using: { $0.insert(element, at: idx) },
			undo: { $0.remove(at: idx) }
		)
	}

	@discardableResult
	public func append<T>(_ element: Collection.Element, operation: Resettable.OperationBehavior = .default) -> Resettable
	where Collection == Array<T> {
		return resettable._modify(
			operation: operation,
			keyPath,
			using: { $0.append(element) },
			undo: { $0.removeLast() }
		)
	}
}
