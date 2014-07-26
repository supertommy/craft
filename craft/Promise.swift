//
//  Promise.swift
//  craft
//
//  Created by Tommy Leung on 6/28/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import Foundation

enum PromiseState: Int
{
    case PENDING, FULFILLED, REJECTED
}

public class Promise
{
    let deffered: Deferred
    var state: PromiseState = PromiseState.PENDING
    
    init(deferred d: Deferred)
    {
        self.deffered = d
    }
    
    public func then(resolve: Result?, reject: Result?) -> Promise
    {
        let p = Craft.promise()
        
        deffered.addChild(resolve, reject: reject, p: p)
        
        return p;
    }
    
    public func then(resolve: Result?) -> Promise
    {
        return then(resolve, reject: nil)
    }
    
    public func then() -> Promise
    {
        return then(nil, nil)
    }
    
    public func catch(reject: Result) -> Promise
    {
        return then(nil, reject: reject)
    }
}