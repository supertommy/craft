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
            (value: AnyObject?) -> AnyObject? in
            
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
            (value: AnyObject?) -> AnyObject? in
            
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
            (value: AnyObject?) -> AnyObject? in
            expectation.fulfill()
            return nil;
        },
        reject: {
            (value: AnyObject?) -> AnyObject? in
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
            (value: AnyObject?) -> AnyObject? in
            expectation.fulfill()
            return nil;
        })
        
        waitForExpectationsWithTimeout(5.0, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    func testMultiThen()
    {
        let expectation1 = expectationWithDescription("multiThen1");
        let expectation2 = expectationWithDescription("multiThen2");
        
        let p : Promise = createImmediateResolvePromise()
        
        p.then({
            (value: AnyObject?) -> AnyObject? in
            expectation1.fulfill()
            return nil
        })
        
        p.then({
            (value: AnyObject?) -> AnyObject? in
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
            (value: AnyObject?) -> AnyObject? in
            return "hello"
        })?
        .then({
            (value: AnyObject?) -> AnyObject? in
            let v: String = value as String
            return v + " world"
        })?
        .then({
            (value: AnyObject?) -> AnyObject? in
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
        let p2 = p.then()!
        
        p2.then({
            (value: AnyObject?) -> AnyObject? in
            
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
        let p2 = p.then()!
        
        p2.catch({
            (value: AnyObject?) -> AnyObject? in
            
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
            (value: AnyObject?) -> AnyObject? in
            return self.createWillResolvePromise("promise value")
        })?
        .then({
            (value: AnyObject?) -> AnyObject? in
            
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
            (value: AnyObject?) -> AnyObject? in
            
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
            (value: AnyObject?) -> AnyObject? in
                return nil;
        }, reject: {
            (value: AnyObject?) -> AnyObject? in
            
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
        let expectation = expectationWithDescription("catch");
        
        let p = createWillRejectPromise()
        
        p.catch({
            (value: AnyObject?) -> AnyObject? in
            
            println(value)
            expectation.fulfill()
            
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
            (resolve: (value: AnyObject?) -> (), reject: (value: AnyObject?) -> ()) -> () in
            
            resolve(value: "immediate resolve")
        })
    }
    
    func createImmediateRejectPromise() -> Promise
    {
        return Craft.promise({
            (resolve: (value: AnyObject?) -> (), reject: (value: AnyObject?) -> ()) -> () in
            
            reject(value: "immediate reject")
        })
    }
    
    func createWillResolvePromise() -> Promise
    {
        return createWillResolvePromise("resolved")
    }
    
    func createWillResolvePromise(value: AnyObject?) -> Promise
    {
        return Craft.promise({
            (resolve: (value: AnyObject?) -> (), reject: (value: AnyObject?) -> ()) -> () in
            
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
    
    func createWillRejectPromise(value: AnyObject?) -> Promise
    {
        return Craft.promise({
            (resolve: (value: AnyObject?) -> (), reject: (value: AnyObject?) -> ()) -> () in
            
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
