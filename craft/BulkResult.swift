//
//  Result.swift
//  craft
//
//  Created by Tommy Leung on 6/28/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import Foundation

public class BulkResult
{
    public let data: [AnyObject?]
    
    init(data: [AnyObject?])
    {
        self.data = data
    }
}

public class SettledResult
{
    let state: PromiseState
    public let value: AnyObject?
    
    init(state: PromiseState, value: AnyObject?)
    {
        self.state = state
        self.value = value
    }
}