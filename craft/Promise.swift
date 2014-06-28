//
//  Promise.swift
//  craft
//
//  Created by Tommy Leung on 6/28/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import Foundation

typealias Result = (value: AnyObject?) -> AnyObject?

class Promise
{
    var onResolved: Result?
    var onRejected: Result?
    
    init()
    {
    }
    
    func then(resolve: Result, reject: Result) -> Promise?
    {
        self.onResolved = resolve
        self.onRejected = reject
        
        return Promise()
    }
    
    func then(resolve: Result) -> Promise?
    {
        return then(resolve, reject: {
            (value: AnyObject?) -> AnyObject? in
                return nil;
            })
    }
    
    func resolve(value: AnyObject?)
    {
        if let r = onResolved
        {
            r(value: value)
        }
    }
    
    func reject(value: AnyObject?)
    {
        if let r = onRejected
        {
            r(value: value)
        }
    }
}