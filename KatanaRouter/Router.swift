//
//  Router.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 13/02/17.
//  Copyright © 2017 Michal Ciurus. All rights reserved.
//

import Katana

internal struct SetRootDestination: Action {
    
    let rootDestination: Destination
    
    public func updatedState(currentState: State) -> State {
        guard var state = currentState as? RoutableState else { return currentState }
        let rootNode = NavigationTreeNode(value: rootDestination, isActiveRoute: true)
        state.navigationState.setNavigationTreeRootNode(rootNode)
        return state
    }
}

/// Router reacts to the changes in the navigation tree and informs all the routables of the
/// differences that they need to react to
final public class Router<State: RoutableState> {
    
    fileprivate let store: Store<State>
    fileprivate var lastNavigationStateCopy: NavigationTreeNode?
    fileprivate let routingQueue: DispatchQueue
    fileprivate var routables: [Destination : Routable]
    
    /// - Parameters:
    ///   - store: current store
    ///   - rootRoutable: your root Routable instance. If your root node of your navigation tree is empty the Router will create it for you.
    ///   - rootIdentifier: your root Routable user identifier. Ignored if the navigation tree already has a root
    public init(store: Store<State>, rootRoutable: Routable, rootIdentifier: String? = nil) {
        self.store = store
        self.routables = [ : ]
        routingQueue = DispatchQueue(label: "RoutingQueue", attributes: [])
        _ =  store.addListener { [weak self] in
            self?.stateChanged()
        }
        
        setupRootForRoutable(rootRoutable, identifier: rootIdentifier)
    }
}

private extension Router {
    
    func stateChanged() {
        var currentState = store.state
        let currentRootNode = currentState.navigationState.mutateNavigationTreeRootNode()
        fireActionsForChanges(lastState: lastNavigationStateCopy, currentState: currentRootNode)
        lastNavigationStateCopy = currentRootNode?.deepCopy()
    }
    
    func fireActionsForChanges(lastState: NavigationTreeNode?, currentState: NavigationTreeNode?) {
        let actions = NavigationTreeDiff.getNavigationDiffActions(lastState: lastState, currentState: currentState)
        
        for action in actions {
            
            // Creating a semaphore to wait for the completion handlers.
            // Users need call the handlers, because UI transitions take time/are asynchronous
            // so we can't fire all the events synchronously
            let completionSemaphore = DispatchSemaphore(value: 0)
            
            routingQueue.async {
                let completion: RoutableCompletion = {
                    completionSemaphore.signal()
                }
                switch action {
                case .push(let nodeToPush):
                    DispatchQueue.main.async {
                        self.performPush(node: nodeToPush, completion: completion)
                    }
                case .pop(let nodeToPop):
                    DispatchQueue.main.async {
                        self.performPop(node: nodeToPop, completion: completion)
                    }
                case .changed(let nodesToPop, let nodesToPush):
                    DispatchQueue.main.async {
                        self.performChange(nodesToPop: nodesToPop, nodesToPush: nodesToPush, completion: completion)
                    }
                case .changedActiveChild(let activeChild):
                    DispatchQueue.main.async {
                        self.performChangeActiveChild(activeChild: activeChild, completion: completion)
                    }
                }
                
                let timeToWait = DispatchTime.now() + .seconds(5)
                let result = completionSemaphore.wait(timeout: timeToWait)
                
                if case .timedOut = result {
                    fatalError("The Routable completion handler has not been called. Please make sure that you call the handler in each Routable method")
                }
            }
        }
    }
    
    func performPush(node: NavigationTreeNode, completion: @escaping RoutableCompletion) {
        if let parentNode = node.parentNode {
            let routable = routables[parentNode.value]!.push(destination: node.value, completionHandler: completion)
            routables[node.value] = routable
        } else {
            //This is root node, there is no parent to inform
            completion()
        }
    }
    
    func performPop(node: NavigationTreeNode, completion: @escaping RoutableCompletion) {
        if let parentNode = node.parentNode {
            routables[parentNode.value]!.pop(destination: node.value, completionHandler: completion)
        } else {
            //This is root node, there is no parent to inform
            completion()
        }
    }
    
    func performChange(nodesToPop: [NavigationTreeNode], nodesToPush: [NavigationTreeNode], completion: @escaping RoutableCompletion) {
        let node = nodesToPop.count > 0 ? nodesToPop[0] : nodesToPush[0]
        
        if let parentNode = node.parentNode {
            let destinationsToPop = nodesToPop.map { $0.value }
            let destinationsToPush = nodesToPush.map { $0.value }
            let routablesToAdd = routables[parentNode.value]!.change(destinationsToPop: destinationsToPop, destinationsToPush: destinationsToPush, completionHandler: completion)
            
            // Need to make sure that the user returned all the needed pushed Routables
            for nodeToPush in nodesToPush {
                let routable = routablesToAdd[nodeToPush.value]
                if let routable = routable {
                    routables[nodeToPush.value] = routable
                } else {
                    fatalError("Did not find a correct Routable for a pushed Destination. Please make sure you're returning a correct dictionary in change(destinationsToPop:destinationsToPush:completionHandler:)")
                }
            }
        } else {
            //This is root node, there is no parent to inform
            completion()
        }
    }
    
    func performChangeActiveChild(activeChild: NavigationTreeNode, completion: @escaping RoutableCompletion) {
        if let parentNode = activeChild.parentNode {
            routables[parentNode.value]!.changeActiveDestination(currentActiveDestination: activeChild.value, completionHandler: completion)
        }
    }
    
    
    /// Sets up the root routable depending on the current state of the tree
    /// If the current tree is empty, then it creates a new node out of the rootable type
    /// If the current tree is not empty, it sets the routable for the current root node type
    ///
    /// - Parameter routable: root routable to be set
    /// - Parameter identifier: if new root is created, this identifier will used
    func setupRootForRoutable(_ routable: Routable, identifier: String?) {
        var currentState = store.state
        // User has already set up a tree, we just have to add a routable for the root node
        if let rootNode = currentState.navigationState.mutateNavigationTreeRootNode() {
            if identifier != nil {
                print("[KatanaRouter] rootIdentifier has been passed in the Router `init`, but a navigation root already exists in the state. The rootIdentifier will not be used")
            }
            assert(rootNode.value.routableType == type(of: routable), "rootRoutable is of different type than the current root node you've set")
            routables[rootNode.value] = routable
        } else {
        // User has not set up his tree, Router sets it up for him as a convenience
            let rootDestination = Destination(routableType: type(of: routable), contextData: nil, userIdentifier: identifier)
            let setRootDestination = SetRootDestination(rootDestination: rootDestination)
            store.dispatch(setRootDestination)
            routables[rootDestination] = routable
        }
    }
}
