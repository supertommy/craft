craft
=====

A promise library based on the Promises/A+ standard written in Swift for iOS and OSX.

### What are Promises?

Promises are a way to handle asynchronous operations. They are a proxy for values that are currently unknown due to waiting for the network, long and complex computations, or anything else that does not immediately resolve. Promises are commonly used in JavaScript in libraries like jQuery. Most JavaScript implementations conform to the [Promises/A+](http://promises-aplus.github.io/promises-spec/) standard like [Q](https://github.com/kriskowal/q) or [RSVP](https://github.com/tildeio/rsvp.js/).

There are also a few Objective-C implementations for iOS. Check out [this article](http://www.html5rocks.com/en/tutorials/es6/promises/) for more information on Promises.

### Usage

Basic usage is going to be very similar to most JavaScript implementations as Swift supports closures natively.

```
let promise = Craft.promise({
    (resolve: (value: AnyObject?) -> (), reject: (value: AnyObject?) -> ()) -> () in
    
    //some async action
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    dispatch_async(queue, {
    
        //do something
        usleep(250 * 1000)
        
        dispatch_sync(dispatch_get_main_queue(), {
            
            //resolve if all went well
            resolve(value: value)
            
            //or reject if there was a problem
            reject(value: value)
        })
    })
})

promise.then({
    (value: AnyObject?) -> AnyObject? in
    
    //resolved successfully!
    
    return nil
}, reject: {
    (value: AnyObject?) -> AnyObject? in
    
    //failed for some reason
    
    return nil
})
```

A Promise is created using the static method `Craft.promise()` and a closure that accepts a resolve and reject closure should be passed in for any async work that should be done. Generally you will want to use Grand Central Dispatch for actually performing an async operation. The Promise must then resolve or reject on the main thread.

When the work is done, the resolve or reject closures passed into `promise.then` will be called depending on the state of the Promise. A Promise cannot be both rejected and resolved. Once a Promise has been resolved or rejected, it cannot be reused.

### Chaining

Chaining is one of the defining features of the Promises/A+ standard. The resolve or reject handlers passed into `then` can return nil or a value. The return type of those closures is `AnyObject?`. These closures have a return type because their returned values are then passed into the next resolve or reject handler.

```
promise.then({
    (value: AnyObject?) -> AnyObject? in
    
    return "hello"
})
.then({
    (value: AnyObject?) -> AnyObject? in
    
    println(value + " world")
    //hello world
    
    return nil
})
 
```

In the above example, the first resolve returns the string "hello". That is then passed into the next resolve as it's incoming value parameter so when we print `value + " world"` we get "hello world".

When you return a Promise in a resolve closure, the result of that promise will be sent to the next resolve in the chain.

```
promise.then({
    (value: AnyObject?) -> AnyObject? in
    
    return somePromise
})
.then({
    (value: AnyObject?) -> AnyObject? in
    
    println(value)
    //value is the result of the returned promise above
    
    return nil
})
```

### Arrays of Promises

Sometimes you will want multiple Promises to resolve before doing anything because they all depend on each other or some other reason. As a convenience, there is an `all()` method that can handle this.

```
let a = [
    somePromise,
    someOtherPromise,
    anotherPromise
]

Craft.all(a).then({
    (value: AnyObject?) -> AnyObject? in
    
    if let v: BulkResult = value as? BulkResult
    {
        println(v.data)
    }
    
    return nil
})
```

The `value` passed into the resolve will be of type `BulkResult`. This is mainly due to some issues with passing an `Array<AnyObject?>` as `AnyObject?`. `BulkResult` just wraps the actual result array in the `data` property. This is something to be looked into but for now this is how it works.

If any of the Promises in the array is rejected then the entire thing is rejected. `Craft.all()` only resolves if all the Promises resolve and rejects immediately if any of them fail.

### Settling Arrays of Promises

Sometimes you don't want all the Promises to resolve in order to proceed so there is a convenience method called `Craft.allSettled()`. It works in very much the same way as `Craft.all()` except it will return the state of each Promise in the array.

```
let a = [
    somePromise,
    someOtherPromise,
    anotherPromise
]

Craft.allSettled(a).then({
    (value: AnyObject?) -> AnyObject? in
    
    if let v: BulkResult = value as? BulkResult
    {
        let s: Array<AnyObject?> = v.data
        for obj: AnyObject? in s
        {
            if let o = obj as? SettledResult
            {
                println(o.state.toRaw())
                println(o.value)
            }
        }
    }
    
    return nil
})
```

Again, the result is wrapped inside a `BulkResult`. The `data` property of `BulkResult` is an `Array<SettledResult>`. A `SettledResult` has a `state` and `value` property to denote the state (FULFILLED or REJECTED) and the resulting value of the promise. `Craft.allSettled` will always resolve.

### Tests

Other example usages can be found in the tests. They are in the cleverly named `craftTests.swift`.

### Suggestions, Improvements, Questions

You are welcome to open issues here on Github or fork it and change it any way you like. As for questions you can find me on Twitter [@iamsupertommy](https://twitter.com/iamsupertommy). I am not terribly active on Twitter.
