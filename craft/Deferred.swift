//
//  Deferred.swift
//  craft
//
//  Created by Tommy Leung on 6/28/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import Foundation

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
    
    var children: [Child]
    
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
    
    func resolve(value: Value)
    {
        promise.state = PromiseState.FULFILLED
        
        for c in children
        {
            resolveChild(c, value: value)
        }
    }
    
    func reject(value: Value)
    {
        promise.state = PromiseState.REJECTED
        
        for c in children
        {
            if let r = c.onRejected
            {
                let v: Value? = r(value: value)
                
                //only fire once
                c.onRejected = nil
                
                c.promise.deffered.reject(v)
                continue;
            }
            
            c.promise.deffered.reject(value)
        }
    }
    
    //MARK: private methods
    private func resolveChild(child: Child, value: Value)
    {
        if let r = child.onResolved
        {
            let v: Value = r(value: value)
            
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
                let x = v as! Promise
                promise.state = x.state
                x.then({
                    (value: Value) -> Value in
                    
                    println(value)
                    self.resolve(value)
                    
                    return nil
                    }, reject: {
                        (value: Value) -> Value in
                        
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
    
    private func valueIsPromise(value: Value) -> Bool
    {
        if let val: Any = value
        {
            return val is Promise
        }
        
        return false
    }
    
    private func resolutionIsTypeError(value: Value) -> Bool
    {
        if (valueIsPromise(value))
        {
            if (value as! Promise === promise)
            {
                return true
            }
        }
        return false
    }
}