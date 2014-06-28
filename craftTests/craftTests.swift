//
//  craftTests.swift
//  craftTests
//
//  Created by Tommy Leung on 6/28/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import XCTest
import craft

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
        let p : Promise = Craft.promise()
        p.then({
            (value: AnyObject?) -> AnyObject? in
            return nil;
        })?
        .then({
            (value: AnyObject?) -> AnyObject? in
            return nil;
        })
        
    }
    
    func testPromise()
    {
        let expectation = expectationWithDescription("promise");
        
        let p = Craft.promise({
            (resolve: (value: AnyObject?) -> (), reject: (value: AnyObject?) -> ()) -> () in
            
            //some async action
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            dispatch_async(queue, {
                sleep(1)
                
                dispatch_sync(dispatch_get_main_queue(), {
                    resolve(value: "hi")
                })
            })
        });
        
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
    
    func testPerformanceExample()
    {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
