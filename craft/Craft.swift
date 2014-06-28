//
//  Craft.swift
//  craft
//
//  Created by Tommy Leung on 6/28/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import Foundation

typealias Action = (resolve: (value: AnyObject?) -> (), reject: (value: AnyObject)? -> ()) -> ()

class Craft
{
    class func promise() -> Promise
    {
        return promise(nil)
    }
    
    class func promise(action: Action?) -> Promise
    {
        let d = Deferred.create()
        
        let q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(q, {
            
            dispatch_sync(dispatch_get_main_queue(), {
                if let a = action
                {
                    a(resolve: d.resolve, reject: d.reject)
                }
            })
        })
        
        return d.promise;
    }
}