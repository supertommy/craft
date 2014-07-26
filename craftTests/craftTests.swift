//
//  craftTests.swift
//  craftTests
//
//  Created by Tommy Leung on 6/28/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import XCTest
import craft

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
        p.then({
            (value: Any?) -> Any? in
            
            expectation.fulfill()
            
            return nil;
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    //spec 2.2.4
    func testRejectAsync()
    {
        let expectation = expectationWithDescription("rejectAsync");
        
        let p : Promise = createImmediateRejectPromise()
        p.then(nil, reject: {
            (value: Any?) -> Any? in
            
            expectation.fulfill()
            
            return nil;
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    func testThenable()
    {
        let expectation = expectationWithDescription("thenable");
        
        let p : Promise = createImmediateResolvePromise()
        p.then({
            (value: Any?) -> Any? in
            expectation.fulfill()
            return nil;
        },
        reject: {
            (value: Any?) -> Any? in
            return nil;
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    func testThenableNoReject()
    {
        let expectation = expectationWithDescription("thenableNoReject");
        
        let p : Promise = createImmediateResolvePromise()
        p.then({
            (value: Any?) -> Any? in
            expectation.fulfill()
            return nil;
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    //spec 2.2.6
    func testMultiThenResolve()
    {
        let expectation1 = expectationWithDescription("multiThenResolve1");
        let expectation2 = expectationWithDescription("multiThenResolve2");
        
        let p : Promise = createImmediateResolvePromise()
        
        p.then({
            (value: Any?) -> Any? in
            expectation1.fulfill()
            return nil
        })
        
        p.then({
            (value: Any?) -> Any? in
            expectation2.fulfill()
            return nil
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    //spec 2.2.6
    func testMultiThenReject()
    {
        let expectation1 = expectationWithDescription("multiThenReject1");
        let expectation2 = expectationWithDescription("multiThenReject2");
        
        let p : Promise = createImmediateRejectPromise()
        
        p.catch({
            (value: Any?) -> Any? in
            expectation1.fulfill()
            return nil
        })
        
        p.catch({
            (value: Any?) -> Any? in
            expectation2.fulfill()
            return nil
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    func testChainable()
    {
        let expectation = expectationWithDescription("chainable");
        
        let p : Promise = createWillResolvePromise()
        p.then({
            (value: Any?) -> Any? in
            return "hello"
        })
        .then({
            (value: Any?) -> Any? in
            let v: String = value as String
            return v + " world"
        })
        .then({
            (value: Any?) -> Any? in
            let v: String = value as String
            let s = v + ", swift"
            
            expectation.fulfill()
            
            return nil;
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    //spec 2.2.7.3
    func testChainableResolveWithHole()
    {
        let expectation = expectationWithDescription("chainableResolveWithHole");
        
        let p : Promise = createWillResolvePromise()
        let p2 = p.then()
        
        p2.then({
            (value: Any?) -> Any? in
            
            println(value)
            expectation.fulfill()
            
            return nil
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    //spec 2.2.7.4
    func testChainableRejectWithHole()
    {
        let expectation = expectationWithDescription("chainableRejectWithHole");
        
        let p : Promise = createWillRejectPromise()
        let p2 = p.then()
        
        p2.catch({
            (value: Any?) -> Any? in
            
            println(value)
            expectation.fulfill()
            
            return nil
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    //spec 2.3.2
    func testChainablePromise()
    {
        let expectation = expectationWithDescription("chainablePromise");
        
        let p : Promise = createWillResolvePromise()
        p.then({
            (value: Any?) -> Any? in
            return self.createWillResolvePromise("promise value")
        })
        .then({
            (value: Any?) -> Any? in
            
            println(value)
            
            expectation.fulfill()
            
            return nil;
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    func testChainTypeError()
    {
        let expectation = expectationWithDescription("chainTypeError");
        
        let p : Promise = createWillResolvePromise()
        p.then({
            (value: Any?) -> Any? in
            return p
        })
        .catch({
            (value: Any?) -> Any? in
            
            println(value)
            
            expectation.fulfill()
            
            return nil;
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    func testPromiseResolve()
    {
        let expectation = expectationWithDescription("resolve");
        
        let p = createWillResolvePromise()
        
        p.then({
            (value: Any?) -> Any? in
            
            println(value)
            expectation.fulfill()
            
            return nil;
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    func testPromiseReject()
    {
        let expectation = expectationWithDescription("reject");
        
        let p = createWillRejectPromise()
        
        p.then({
            (value: Any?) -> Any? in
                return nil;
        }, reject: {
            (value: Any?) -> Any? in
            
            println(value)
            expectation.fulfill()
            
            return nil
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    func testPromiseCatch()
    {
        let expectation = expectationWithDescription("catch")
        
        let p = createWillRejectPromise()
        
        p.catch({
            (value: Any?) -> Any? in
            
            println(value)
            expectation.fulfill()
            
            return nil
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    func testAllResolve()
    {
        let expectation = expectationWithDescription("allResolve");
        
        let a = [
            createImmediateResolvePromise(),
            createImmediateResolvePromise(),
            createImmediateResolvePromise()
        ]
        
        Craft.all(a).then({
            (value: Any?) -> Any? in
            
            if let v: [Any?] = value as? [Any?]
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
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
    
        });
    }
    
    func testAllReject()
    {
        let expectation = expectationWithDescription("allReject");
        
        let a = [
            createImmediateResolvePromise(),
            createImmediateRejectPromise(),
            createImmediateResolvePromise()
        ]
        
        Craft.all(a).catch({
            (value: Any?) -> Any? in
            
            expectation.fulfill()
            
            return nil
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    func testAllSettled()
    {
        let expectation = expectationWithDescription("allSettled");
        
        let a = [
            createImmediateResolvePromise(),
            createImmediateRejectPromise(),
            createImmediateResolvePromise()
        ]
        
        Craft.allSettled(a).then({
            (value: Any?) -> Any? in
            
            if let v: [Any?] = value as? [Any?]
            {
                XCTAssertEqual(a.count, v.count)
                
                for var i = 0; i < v.count; ++i
                {
                    if let result = v[i]
                    {
                        //allSettled resolutions are wrapped in SettleResult to determine state
                        XCTAssertTrue(result is SettledResult)
                        
                        //createImmediate[Resolve|Reject]Promise resolves/rejects with String
                        XCTAssertTrue((result as SettledResult).value is String)
                    }
                }
                expectation.fulfill()
            }
            
            return nil
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    //MARK: helpers
    func createImmediateResolvePromise() -> Promise
    {
        return Craft.promise({
            (resolve: (value: Any?) -> (), reject: (value: Any?) -> ()) -> () in
            
            resolve(value: "immediate resolve")
        })
    }
    
    func createImmediateRejectPromise() -> Promise
    {
        return Craft.promise({
            (resolve: (value: Any?) -> (), reject: (value: Any?) -> ()) -> () in
            
            reject(value: "immediate reject")
        })
    }
    
    func createWillResolvePromise() -> Promise
    {
        return createWillResolvePromise("resolved")
    }
    
    func createWillResolvePromise(value: Any?) -> Promise
    {
        return Craft.promise({
            (resolve: (value: Any?) -> (), reject: (value: Any?) -> ()) -> () in
            
            //some async action
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(queue, {
                usleep(250 * 1000)
                
                dispatch_sync(dispatch_get_main_queue(), {
                    resolve(value: value)
                })
            })
        });
    }
    
    func createWillRejectPromise() -> Promise
    {
        return createWillRejectPromise("rejected")
    }
    
    func createWillRejectPromise(value: Any?) -> Promise
    {
        return Craft.promise({
            (resolve: (value: Any?) -> (), reject: (value: Any?) -> ()) -> () in
            
            //some async action
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(queue, {
                usleep(250 * 1000)
                
                dispatch_sync(dispatch_get_main_queue(), {
                    reject(value: value)
                })
            })
        });
    }
}
