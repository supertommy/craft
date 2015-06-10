//
//  craftTests.swift
//  craftTests
//
//  Created by Tommy Leung on 6/28/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import XCTest
import craft

/**
 * custom infix operator as a shorthand for GCD operation where 'lhs' is an async
 * task that is followed by 'rhs' which a task on the main thread
 *
 * uses @autoclosure so that statement can be as concise as:
 *
 * usleep(250 * 1000) ~> resolve(value: value)
 * 
 * which is to sleep in the background and then resolve on the main thread
 */
infix operator ~> {}
func ~> (lhs: () -> Any, rhs: () -> ())
{
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    dispatch_async(queue, {
        lhs()
        dispatch_sync(dispatch_get_main_queue(), rhs)
    })
}

//Promises/A+ spec: http://promises-aplus.github.io/promises-spec/
class craftTests: XCTestCase
{
    
    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreatePromise()
    {
        let p : Promise = Craft.promise()
        
        XCTAssertNotNil(p, "promise was not created")
    }
    
    //spec 2.2.4
    func testResolveAsync()
    {
        let expectation = expectationWithDescription("resolveAsync");
        
        let p : Promise = createImmediateResolvePromise()
        p.then {
            (value: Value) -> Value in
            
            expectation.fulfill()
            
            return nil;
        }
        
        /**
         * proceeding uses of waitForExpectationsWithTimeout will use trailing closure syntax
         * and shorthand argument names for conciseness
         */
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    //spec 2.2.4
    func testRejectAsync()
    {
        let expectation = expectationWithDescription("rejectAsync");
        
        let p : Promise = createImmediateRejectPromise()
        p.then(nil, reject: {
            (value: Value) -> Value in
            
            expectation.fulfill()
            
            return nil;
        })
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    func testThenable()
    {
        let expectation = expectationWithDescription("thenable");
        
        let p : Promise = createImmediateResolvePromise()
        p.then({
            (value: Value) -> Value in
            expectation.fulfill()
            return nil;
        },
        reject: {
            (value: Value) -> Value in
            return nil;
        })
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    func testThenableNoReject()
    {
        let expectation = expectationWithDescription("thenableNoReject");
        
        let p : Promise = createImmediateResolvePromise()
        p.then {
            (value: Value) -> Value in
            expectation.fulfill()
            return nil;
        }
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    //spec 2.2.6
    func testMultiThenResolve()
    {
        let expectation1 = expectationWithDescription("multiThenResolve1");
        let expectation2 = expectationWithDescription("multiThenResolve2");
        
        let p : Promise = createImmediateResolvePromise()
        
        p.then {
            (value: Value) -> Value in
            expectation1.fulfill()
            return nil
        }
        
        p.then {
            (value: Value) -> Value in
            expectation2.fulfill()
            return nil
        }
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    //spec 2.2.6
    func testMultiThenReject()
    {
        let expectation1 = expectationWithDescription("multiThenReject1");
        let expectation2 = expectationWithDescription("multiThenReject2");
        
        let p : Promise = createImmediateRejectPromise()
        
        p.`catch` {
            (value: Value) -> Value in
            expectation1.fulfill()
            return nil
        }
        
        p.`catch` {
            (value: Value) -> Value in
            expectation2.fulfill()
            return nil
        }
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    func testChainable()
    {
        let expectation = expectationWithDescription("chainable");
        
        let p : Promise = createWillResolvePromise()
        p.then {
            (value: Value) -> Value in
            return "hello"
        }
        .then {
            (value: Value) -> Value in
            let v: String = value as! String
            return v + " world"
        }
        .then {
            (value: Value) -> Value in
            
            expectation.fulfill()
            
            return nil;
        }
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    //spec 2.2.7.3
    func testChainableResolveWithHole()
    {
        let expectation = expectationWithDescription("chainableResolveWithHole");
        
        let p : Promise = createWillResolvePromise()
        let p2 = p.then()
        
        p2.then {
            (value: Value) -> Value in
            
            print(value)
            expectation.fulfill()
            
            return nil
        }
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    //spec 2.2.7.4
    func testChainableRejectWithHole()
    {
        let expectation = expectationWithDescription("chainableRejectWithHole");
        
        let p : Promise = createWillRejectPromise()
        let p2 = p.then()
        
        p2.`catch` {
            (value: Value) -> Value in
            
            print(value)
            expectation.fulfill()
            
            return nil
        }
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    //spec 2.3.2
    func testChainablePromise()
    {
        let expectation = expectationWithDescription("chainablePromise");
        
        let p : Promise = createWillResolvePromise()
        p.then {
            (value: Value) -> Value in
            return self.createWillResolvePromise("promise value")
        }
        .then {
            (value: Value) -> Value in
            
            print(value)
            
            expectation.fulfill()
            
            return nil;
        }
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    func testChainTypeError()
    {
        let expectation = expectationWithDescription("chainTypeError");
        
        let p : Promise = createWillResolvePromise()
        p.then {
            (value: Value) -> Value in
            return p
        }
        .`catch` {
            (value: Value) -> Value in
            
            print(value)
            
            expectation.fulfill()
            
            return nil;
        }
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    func testPromiseResolve()
    {
        let expectation = expectationWithDescription("resolve");
        
        let p = createWillResolvePromise()
        
        p.then {
            (value: Value) -> Value in
            
            print(value)
            expectation.fulfill()
            
            return nil;
        }
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    func testPromiseReject()
    {
        let expectation = expectationWithDescription("reject");
        
        let p = createWillRejectPromise()
        
        p.then({
            (value: Value) -> Value in
                return nil;
        }, reject: {
            (value: Value) -> Value in
            
            print(value)
            expectation.fulfill()
            
            return nil
        })
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    func testPromiseCatch()
    {
        let expectation = expectationWithDescription("catch")
        
        let p = createWillRejectPromise()
        
        p.`catch` {
            (value: Value) -> Value in
            
            print(value)
            expectation.fulfill()
            
            return nil
        }
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    func testAllResolve()
    {
        let expectation = expectationWithDescription("allResolve");
        
        let a = [
            createImmediateResolvePromise(),
            createImmediateResolvePromise(),
            createImmediateResolvePromise()
        ]
        
        Craft.all(a).then {
            (value: Value) -> Value in
            
            if let v: [Value] = value as? [Value]
            {
                XCTAssertEqual(a.count, v.count)
                
                for var i = 0; i < v.count; ++i
                {
                    if let result = v[i]
                    {
                        //createImmediateResolvePromise resolves with String
                        XCTAssertTrue(result is String)
                    }
                }
                expectation.fulfill()
            }
            
            return nil
        }
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    func testAllReject()
    {
        let expectation = expectationWithDescription("allReject");
        
        let a = [
            createImmediateResolvePromise(),
            createImmediateRejectPromise(),
            createImmediateResolvePromise()
        ]
        
        Craft.all(a).`catch` {
            (value: Value) -> Value in
            
            expectation.fulfill()
            
            return nil
        }
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    func testAllSettled()
    {
        let expectation = expectationWithDescription("allSettled");
        
        let a = [
            createImmediateResolvePromise(),
            createImmediateRejectPromise(),
            createImmediateResolvePromise()
        ]
        
        Craft.allSettled(a).then {
            if let v: [Value] = $0 as? [Value]
            {
                XCTAssertEqual(a.count, v.count)
                
                for var i = 0; i < v.count; ++i
                {
                    if let result = v[i]
                    {
                        //allSettled resolutions are wrapped in SettleResult to determine state
                        XCTAssertTrue(result is SettledResult)
                        
                        //createImmediate[Resolve|Reject]Promise resolves/rejects with String
                        XCTAssertTrue((result as! SettledResult).value is String)
                    }
                }
                expectation.fulfill()
            }
            
            return nil
        }
        
        waitForExpectationsWithTimeout(5.0) { print($0) };
    }
    
    //MARK: helpers
    func createImmediateResolvePromise() -> Promise
    {
        return Craft.promise {
            (resolve: (value: Value) -> (), reject: (value: Value) -> ()) -> () in
            
            resolve(value: "immediate resolve")
        }
    }
    
    func createImmediateRejectPromise() -> Promise
    {
        return Craft.promise {
            (resolve: (value: Value) -> (), reject: (value: Value) -> ()) -> () in
            
            reject(value: "immediate reject")
        }
    }
    
    func createWillResolvePromise() -> Promise
    {
        return createWillResolvePromise("resolved")
    }
    
    func createWillResolvePromise(value: Value) -> Promise
    {
        return Craft.promise {
            (resolve: (value: Value) -> (), reject: (value: Value) -> ()) -> () in
            
            //some async action
            { usleep(250 * 1000) } ~> { resolve(value: value) }
        };
    }
    
    func createWillRejectPromise() -> Promise
    {
        return createWillRejectPromise("rejected")
    }
    
    func createWillRejectPromise(value: Value) -> Promise
    {
        return Craft.promise {
            (resolve: (value: Value) -> (), reject: (value: Value) -> ()) -> () in
            
            //some async action
            { usleep(250 * 1000) } ~> { reject(value: value) }
        }
    }
}
