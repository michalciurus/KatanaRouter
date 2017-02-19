//
//  NavigationActions.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 09/02/17.
//  Copyright © 2017 Michal Ciurus. All rights reserved.
//

import Katana

public struct AddNavigationDestination {
    
    fileprivate let routableType: Routable.Type
    fileprivate let contextData: Any?
    fileprivate let identifier: String?
    
    /// Creates a new destination
    ///
    /// - Parameters:
    ///   - routableType: type of the destination's Routable
    ///   - contextData: any data that you wish to pass as context
    ///   - identifier: your own identifier that you may use later. **Make sure that all identifiers are unique!!**
    public init(routableType: Routable.Type, contextData: Any? = nil, identifier: String? = nil) {
        self.routableType = routableType
        self.contextData = contextData
        self.identifier = identifier
    }
}

/// Add a new destination on top of the current route
extension AddNavigationDestination: Action {
    public func updatedState(currentState: State) -> State {
        guard var state = currentState as? RoutableState else { return currentState }
        let destination = Destination(routableType: routableType, contextData: contextData, userIdentifier: identifier)
        state.navigationState.addNewDestinationToActiveRoute(destination: destination)
        return state
    }
}


/// Set the current navigation root. 
/// Discards all the current routes and replaces it with the root routable!
public struct SetRootRoutable: Action {
    
    private let routable: Routable
    private let userIdentifier: String?
    
    public init(routable: Routable, userIdentifier: String? = nil) {
        self.routable = routable
        self.userIdentifier = userIdentifier
    }
    
    public func updatedState(currentState: State) -> State {
        guard var state = currentState as? RoutableState else { return currentState }
        let rootDestination = Destination(routableType: type(of: routable), contextData: nil, userIdentifier: userIdentifier)
        let rootNode = NavigationTreeNode(value: rootDestination)
        rootNode.currentRoutable = routable
        state.navigationState.navigationTreeRootNode = rootNode
        return state
    }
}

// Add children to a node with given user identifier
public struct AddChildrenToDestination: Action {
    
    private let destinationIdentifier: String
    private let destinations: [AddNavigationDestination]
    
    public func updatedState(currentState: State) -> State {
        guard var state = currentState as? RoutableState else { return currentState }
        guard let node = state.navigationState.navigationTreeRootNode?.find(userIdentifier: destinationIdentifier) else {
            return currentState
        }
        
        let nodes = destinations.map { addDestination -> NavigationTreeNode in
            let destination = Destination(routableType: addDestination.routableType, contextData: addDestination.contextData, userIdentifier: addDestination.identifier)
            return NavigationTreeNode(value: destination)
        }
        node.children.append(contentsOf: nodes)
        
        return state
    }
    
}
