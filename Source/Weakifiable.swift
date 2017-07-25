//
//  Weakifiable.swift
//  Pods
//
//  Created by Oleksa 'trimm' Korin on 12/12/16.
//
//

/**
 Generic wrapper type representing weak variable.
 */
public struct Weak<Wrapped: AnyObject> {
    /// Weak value
    private(set) weak var value: Wrapped?

    /**
     Initializes new Weak entity.
     - Parameter value:   AnyObject value to be weakified
    */
    public init(_ value: Wrapped) {
        self.value = value
    }
    
    /**
     Strongifies a value and calls a function if it's still available.
     - Parameter transform:    Function to call, if the value wasn't deallocated.
     
     - Returns: Strong value or nil
     */
    @discardableResult
    public func strongify<Result>(transform: (Wrapped) -> Result?) -> Result? {
        return self.value.flatMap(transform)
    }
}

extension Weak: Equatable { }

/** Compare two Weak entities by wrapped value
 - Parameters:
    - lhs: Weak entiy
    - rhs: Weak entiy
 - Returns: Compare two Weak values by reference. *true*, if both values weren't deallocated and are equal be reference, *false* otherwise.
 */
public func ==<Wrapped: AnyObject>(lhs: Weak<Wrapped>, rhs: Weak<Wrapped>) -> Bool {
    return lhs.strongify { lhs in
        rhs.strongify { lhs === $0 }
        }
        ?? false
}

/** Wraps a value in Weak.
 - Parameter value: object to weakify
 - Returns: value wrapped into Weak.
 */
public func weakify<Wrapped: AnyObject>(_ value: Wrapped) -> Weak<Wrapped> {
    return weakify(value) { _ in }
}

/** Wraps a value in Weak.
 - Parameters:
    - value: object to weakify
    - execute: calls a function with wekified entity as a parameter
 - Returns: value wrapped into Weak.
 */
@discardableResult
public func weakify<Wrapped: AnyObject>(_ value: Wrapped, execute: (Weak<Wrapped>) -> ()) -> Weak<Wrapped> {
    let weak = Weak(value)
    execute(weak)
    
    return weak
}

/// Class protocol for weakification.
public protocol Weakifiable: class { }

extension Weakifiable {
    /// Returns weakified self
    var weak: Weak<Self> {
        return weakify(self)
    }
}

extension NSObject: Weakifiable { }

/**
 Weakifies type function call.
 
 - Parameters:
    - function: Type function of type (Type) -> (Tuple) -> Result, where Tuple is arguments for object function call.
    - object: Object to pass to type function for weakification.
    - default: Value to return in case object was deallocated.
 
 - Returns: Function, capturing weakified object type function call.
 */
public func weakify<Value: AnyObject, Arguments, Result>(
    _ function: @escaping (Value) -> (Arguments) -> Result,
    object: Value,
    default value: Result
)
    -> (Arguments) -> Result
{
    return { [weak object] arguments in
        object.map { function($0)(arguments) } ?? value
    }
}

/**
 Weakifies type function call.
 
 - Parameters:
    - function: Type function of type (Type) -> (Tuple) -> Result, where Tuple is arguments for object function call.
    - object: Object to pass to type function for weakification.
 
 - Returns: Function, capturing weakified object type function call.
 */
public func weakify<Value: AnyObject, Arguments>(
    _ function: @escaping (Value) -> (Arguments) -> (),
    object: Value
)
    -> (Arguments) -> ()
{
    return weakify(function, object: object, default: ())
}

