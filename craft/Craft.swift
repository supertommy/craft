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
        return Promise()
    }
    
    class func promise(action: Action) -> Promise
    {
        let p = Promise();
        
        action(resolve: p.resolve, reject: p.reject)
        
        return p;
    }
}