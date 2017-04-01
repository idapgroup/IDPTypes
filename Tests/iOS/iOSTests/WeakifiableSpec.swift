//
//  IDPCastableTests.swift
//  IDPCastableTests
//
//  Created by Oleksa 'trimm' Korin on 12/12/16.
//  Copyright © 2016 Oleksa 'trimm' Korin. All rights reserved.
//

import Quick
import Nimble

@testable import IDPTypes

fileprivate func async(_ f: @escaping () -> ()) {
    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1, execute: f)
}

fileprivate class Object: Weakifiable {
    func f() {}
}

// print (Weak(User()) == Weak(User()))
//
// let u = User()
//
// print(Weak(u) == Weak(u))
//
// async {
//     let user = User()
//     weak var weakUser = user
//     let value = doSomethingOptional(weakUser)
//
//     async {
//         if let user = value {
//             print("outer let capture form weak yes")
//         } else {
//             print("outer let capture form weak no")
//         }
//
//         async {
//             let value = weakUser
//             if let user = value {
//                 print("inner let capture form weak yes")
//             } else {
//                 print("inner let capture form weak no")
//             }
//         }
//
//         async {
//             if let user = weakUser {
//                 print("weak capture yes")
//             } else {
//                 print("weak cpature no")
//             }
//         }
//
//         async {
//             let value = doSomethingOptional(weakUser)
//             if let user = value {
//                 print("inner weak capture with function form weak yes")
//             } else {
//                 print("inner weak capture with function form weak no")
//             }
//         }
//
//         async {
//             let user = User()
//             let weak = user.weak
//             print("\(weak.value)")
//             async {
//                 weak.strongify { print("strongify success from weak \($0)") }
//                 print("value from weak = \(weak.value)")
//
//                 async {
//                     let user = User()
//
//                     let w = weakify(user) { weak in
//                         async {
//                             weak.strongify { value in
//                                 print("strongify success from weakify \(value)")
//                             }
//
//                             print("value from weakify = \(weak.value)")
//                         }
//                     }
//                 }
//             }
//         }
//     }
// }

class WeakifiableSpec: QuickSpec {
    override func spec() {
        describe("Weakifiable") {
            context("NSString") {
                let object = NSString()
                let weak = object.weak
                
                it("should return Weak<NSString>") {
                    expect(type(of:weak) == Weak<NSString>.self).to(beTruthy())
                }
                
                it("should wrap an object") {
                    expect(weak.value).to(beIdenticalTo(object))
                }
            }
            
            context("Object") {
                let object = Object()
                let weak = object.weak
                
                it("should return Weak<Object>") {
                    expect(type(of:weak) == Weak<Object>.self).to(beTruthy())
                }
                
                it("should wrap an object") {
                    expect(weak.value).to(beIdenticalTo(object))
                }
            }
        }
        
        context("func weakify<Wrapped: AnyObject>(_ value: Wrapped) -> Weak<Wrapped>") {
            it("should wrap an object") {
                let object = Object()
                expect(weakify(object).value).to(beIdenticalTo(object))
            }
        }
        
        describe("Weak<Object>") {
//            public func weakify<Wrapped: AnyObject>(_ value: Wrapped) -> Weak<Wrapped>
//            public func weakify<Wrapped: AnyObject>(_ value: Wrapped, execute: (Weak<Wrapped>) -> ()) -> Weak<Wrapped>
            context("init") {
                it("should wrap an object") {
                    let object = Object()
                    expect(Weak(object).value).to(beIdenticalTo(object))
                }
            }

            context("Equatable") {
                it("should be equal for two Weak<Object> wrapping same object") {
                    let object = Object()
                    expect(Weak(object)).to(equal(Weak(object)))
                }
                
                it("should not be equal for two Weak<Object> wrapping different objects") {
                    expect(Weak(Object())).toNot(equal(Weak(Object())))
                }
            }
            
            context("when weak is deallocated") {
                it("should contain nil value") {
                    var object: Object? = Object()
                    let weak = object.map(Weak.init)
                    object = nil
                    
                    expect(weak?.value).to(beNil())
                }
            }
            
            describe("func strongify<Result>(transform: (Wrapped) -> Result?) -> Result?") {
                context("when value is deallocated") {
                    it("transform should not be called") {
                        var called = false
                        
                        async {
                            let object = Object()
                            let weak = Weak(object)
                            
                            async {
                                weak.strongify { _ in
                                    called = false
                                }
                            }
                        }
                        
                        expect(called).toEventuallyNot(beTruthy())
                    }
                }
            }
        }
    }
}
