//
//  Deferred.swift
//  craft
//
//  Created by Tommy Leung on 6/28/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import Foundation

typealias Result = (value: AnyObject?) -> AnyObject?

class Deferred
{
    var onResolved: Result?
    var onRejected: Result?
    
    var promise: Promise!
    
    var children: Array<Promise>
    
    class func create() -> Deferred
    {
        let d = Deferred()
        d.promise = Promise(deferred: d)
        
        return d
    }
    
    init()
    {
        children = Array()
    }
    
    func addChild(p: Promise)
    {
        children.append(p)
    }
    
    func resolve(value: AnyObject?)
    {
        promise.state = PromiseState.FULFILLED
        
        if let r = onResolved
        {
            let v: AnyObject? = r(value: value)
            
            //only fire once
            onResolved = nil
            
            if (resolutionIsTypeError(v))
            {
                //TODO: perhaps better rejection value here
                reject("Type error")
                return
            }
            
            if (valueIsPromise(v))
            {
                //see 2.3.2
                let x = v as Promise
                promise.state = x.state
                x.then({
                    (value: AnyObject?) -> AnyObject? in
                    
                    self.resolve(value)
                    
                    return nil
                }, reject: {
                    (value: AnyObject?) -> AnyObject? in
                    
                    self.reject(value)
                    
                    return nil
                })
                
                return
            }
            
            //TODO: consider how/if to handle 2.3.3
            
            resolveChildren(v)
            return
        }
        
        resolveChildren(value)
    }
    
    func reject(value: AnyObject?)
    {
        promise.state = PromiseState.REJECTED
        
        if let r = onRejected
        {
            let v: AnyObject? = r(value: value)
            
            //only fire once
            onRejected = nil
            
            rejectChildren(v)
            return
        }
        
        rejectChildren(value)
    }
    
    //MARK: should be private
    func resolveChildren(value: AnyObject?)
    {
        for p in children
        {
            p.deffered.resolve(value)
        }
    }
    
    func rejectChildren(value: AnyObject?)
    {
        for p in children
        {
            p.deffered.reject(value)
        }
    }
    
    func valueIsPromise(value: AnyObject?) -> Bool
    {
        if let val: AnyObject = value
        {
            return val is Promise
        }
        
        return false
    }
    
    func resolutionIsTypeError(value: AnyObject?) -> Bool
    {
        if (valueIsPromise(value))
        {
            if (value as Promise === promise)
            {
                return true
            }
        }
        return false
    }
}