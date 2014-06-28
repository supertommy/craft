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
    
    func testCanCreatePromise()
    {
        // This is an example of a functional test case.
        //XCTAssert(true, "Pass")
        
        let p : Promise = Craft.promise()
        
        XCTAssertNotNil(p, "promise was not created")
    }
    
    func testThenable()
    {
        let p : Promise = Craft.promise()
        p.then({
            (value: AnyObject?) -> AnyObject? in
            return nil;
        },
        reject: {
            (value: AnyObject?) -> AnyObject? in
            return nil;
        })
    }
    
    func testThenableNoReject()
    {
        let p : Promise = Craft.promise()
        p.then({
            (value: AnyObject?) -> AnyObject? in
            return nil;
        })
        
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
        
        waitForExpectationsWithTimeout(1.5, handler: {
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
        
        waitForExpectationsWithTimeout(1.5, handler: {
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
        
        waitForExpectationsWithTimeout(1.5, handler: {
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
        
        waitForExpectationsWithTimeout(30.0, handler: {
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
        
        waitForExpectationsWithTimeout(1.5, handler: {
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
        
        waitForExpectationsWithTimeout(1.5, handler: {
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
        
        waitForExpectationsWithTimeout(1.5, handler: {
            (error: NSError!) -> () in
            
        });
    }
    
    func testPerformanceExample()
    {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    //MARK: helpers
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
                usleep(500 * 1000)
                
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
                usleep(500 * 1000)
                
                dispatch_sync(dispatch_get_main_queue(), {
                    reject(value: value)
                })
            })
        });
    }
}
