# KatanaRouter: App Navigation routing for Katana

**This library is still under development**

KatanaRouter is a declarative, type-safe app navigation router for [Katana](https://github.com/BendingSpoons/katana-swift). Katana's *state* structure should represent the whole app's state, including the navigation. The only way to change the navigation state should be through *Actions*. 

KatanaRouter takes care of everything for you: storing the state, providing you actions to change the state, and finding differences between the navigation states.

*Inspired by [ReSwift-Router](https://github.com/ReSwift/ReSwift-Router)*.

## Installation

### Requirements

- iOS 8.4+ / macOS 10.10+

- Xcode 8.0+

- Swift 3.0+

###CocoaPods

You can install KatanaRouter via CocoaPods by adding this line to your `podfile`:

	pod 'KatanaRouter'
	
And run `pod install`.

## Overview

KatanaRouter is totally decoupled from any UI framework. Under the hood it's a tree of `Destination` structures. Each `Destination` can contain children `Destination`, one of which can be *active* (visible).

A `Destination` can route to anything, a `UIViewController`, or even an `UIView`.

For example:

• A `UITabBarController` with `UINavigationController` as tabs, every one of which can push `UIViewControllers` on top of each other. It's modelled into a tree in which the tab bar controller is the root

```
            UITabBarController(active)
               +     +   +
   +-----------+     |   +------------+
   |                 |                |
   |                 +                |
   +                                  +
Tab One(active)    Tab Two         Tab Three

   +                  +                +
   |                  |                |
   |                  |                |
   |                  +                |
   +                                   +
ChildVc(active)     ChildVc          ChildVc
```

• You can as easily model a `UIViewController` destination which has children `UIView` destinations in a `UIScrollView` and declaratively change the `UIView` children with an action. It means that you can use KatanaRouter to route your child `UIView`s.

### Destination

`Destination` is a structure which models a unique destination, identified by a unique `instanceIdentifier`, or by `userIdentifier` set by you to easily refer to it later. **Please make sure that all `userIdentifier`s are unique**.

`routableType` is the type of the `Routable` conforming class that will support all the navigation changes callbacks.

You can also pass `contextData` inside, to receive it and use it when it comes time to navigate.

### State Storage

KatanaRouter takes care of storing the current navigation state for you. All you have to do is make your state to conform to `RoutableState` protocol.

```swift
struct MyState: State, RoutableState {
    var navigationState: NavigationState = NavigationState()
}
```

### Changing State

KatanaRouter provides you with actions to change the current state. If you want to request a new state change action, that's missing, please create an issue on GitHub.

```swift
    func didTapPush() {
         //RandomViewController conforms to `Routable` type
        let pushAction = AddNewDestination(destination: Destination(routableType: RandomViewController.self))
        store.dispatch(pushAction)
    }
```

### Reacting to state change

KatanaRouter has an algorithm that finds differences between states and informs you about them. This is where all the concrete UI actions happen e.g. `presentViewController`, `pushViewController`, `addSubview`.

All you have to do is conform to the `Routable` protocol in objects that control your app's navigation actions.

```swift
extension RandomViewController: Routable {
```

`Routable` has 4 methods that it can implement:

• Push - Singular push action happened. You're responsible to push/present/show the destination and return it's `Routable`

```swift
    func push(destination: Destination, completionHandler: @escaping RoutableCompletion) -> Routable {
        switch(destination.routableType) {
        case is RandomViewController.Type:
            // Instantiate and push/present/show an instance of `RandomViewController`
            // Remember to always call the `completionHandler`
            completionHandler()
            // Return a `Routable` responsible for the pushed destination
            return randomViewController
        default: fatalError("Not supported")
        }
    }
```

• Pop - Singular pop happened. You're responsible to pop/dismiss/remove the destination
    
```swift
    func pop(destination: Destination, completionHandler: @escaping RoutableCompletion) {
        switch(destination.routableType) {
        case is RandomViewController.Type:
            // pop/dismiss/remove `randomViewController`
        completionHandler()
        default: fatalError("Not supported")
        }
    }
```

• Change - A more complex action. At least two singular pop/push actions. It gives you a chance to replace the destinations in one smooth transition. You're responsible for popping and pushing, you also need to return `Routable`'s for all the freshly pushed destinations.

```swift
        public func change(destinationsToPop: [Destination], destinationsToPush: [Destination], completionHandler: @escaping RoutableCompletion) -> [Destination : Routable] {
        var createdRoutables: [Destination : Routable] = [:]
        for destinationToPush in destinationsToPush {
            switch destinationToPush.routableType {
            case is FirstChildView.Type:
                // Show/add first child
                // You need to return the `Routable` that's responsible for routing the `FirstChildView` instance
                createdRoutables[destinationToPush] = firstChildInstance
            case is SecondChildView.Type:
                // Show/add second child
                // You need to return the `Routable` that's responsible for routing the `SecondChildView` instance
                createdRoutables[destinationToPush] = secondChildInstance
            default: fatalError("Not supported")
            }
        }
        // Remember to always call the CompletionHandler when finished with the transition!
        completionHandler()
        return createdRoutables
    }
```

• ChangeActiveDestination - Called when there's a new destination set to active. You're responsible of setting the active destination to visible.

```swift
        public func changeActiveDestination(currentActiveDestination: Destination, completionHandler: @escaping RoutableCompletion) {
        switch currentActiveDestination.routableType {
            case is FirstChildView.Type:
                self.selectedIndex = 0
            case is SecondChildView.Type:
                self.selectedIndex = 1
        default: fatalError("Not supported")
        }
        completionHandler()
    }
}
```










