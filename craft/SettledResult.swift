//
//  Result.swift
//  craft
//
//  Created by Tommy Leung on 6/28/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import Foundation

public class SettledResult
{
    public let state: PromiseState
    public let value: Any?
    
    init(state: PromiseState, value: Any?)
    {
        self.state = state
        self.value = value
    }
}