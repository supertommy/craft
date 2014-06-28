//
//  Promise.swift
//  craft
//
//  Created by Tommy Leung on 6/28/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import Foundation

enum PromiseState
{
    case PENDING, FULFILLED, REJECTED
}

class Promise
{
    let deffered: Deferred
    var state: PromiseState = PromiseState.PENDING
    
    init(deferred d: Deferred)
    {
        self.deffered = d
    }
    
    func then(resolve: Result?, reject: Result?) -> Promise?
    {
        deffered.onResolved = resolve
        deffered.onRejected = reject
        
        let p = Craft.promise()
        
        deffered.addChild(p)
        
        return p;
    }
    
    func then(resolve: Result?) -> Promise?
    {
        return then(resolve, reject: {
            (value: AnyObject?) -> AnyObject? in
                return nil;
            })
    }
    
    func then() -> Promise?
    {
        return then(nil, nil)
    }
    
    func catch(reject: Result) -> Promise?
    {
        return then({
            (value: AnyObject?) -> AnyObject? in
                return nil;
        }, reject: reject)
    }
}