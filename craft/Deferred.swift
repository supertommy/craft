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
    class Child
    {
        var onResolved: Result?
        var onRejected: Result?
        var promise: Promise
        
        init(promise: Promise)
        {
            self.promise = promise
        }
    }
    
    var promise: Promise!
    
    var children: Array<Child>
    
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
    
    func addChild(resolve: Result?, reject: Result?, p: Promise)
    {
        let c = Child(promise: p)
        c.onResolved = resolve
        c.onRejected = reject
        
        children.append(c)
    }
    
    func resolve(value: AnyObject?)
    {
        promise.state = PromiseState.FULFILLED
        
        for c in children
        {
            resolveChild(c, value: value)
        }
    }
    
    func reject(value: AnyObject?)
    {
        promise.state = PromiseState.REJECTED
        
        for c in children
        {
            if let r = c.onRejected
            {
                let v: AnyObject? = r(value: value)
                
                //only fire once
                c.onRejected = nil
                
                c.promise.deffered.reject(v)
                continue;
            }
            
            c.promise.deffered.reject(value)
        }
    }
    
    //MARK: should be private
    func resolveChild(child: Child, value: AnyObject?)
    {
        if let r = child.onResolved
        {
            let v: AnyObject? = r(value: value)
            
            //only fire once
            child.onResolved = nil
            
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
            
            child.promise.deffered.resolve(v)
            return
        }
        
        child.promise.deffered.resolve(value)
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