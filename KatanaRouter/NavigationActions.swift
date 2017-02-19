//
//  NavigationActions.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 09/02/17.
//  Copyright © 2017 Michal Ciurus. All rights reserved.
//

import Katana

/// Add a new destination on top of the current route
public struct AddNavigationDestination: Action {
    
    private let routableType: Routable.Type
    private let contextData: Any?
    
    public init(routableType: Routable.Type, contextData: Any? = nil) {
        self.routableType = routableType
        self.contextData = contextData
    }
    
    public func updatedState(currentState: State) -> State {
        guard var state = currentState as? RoutableState else { return currentState }
        state.navigationState.addNewDestinationToActiveRoute(routableType, contextData: contextData)
        return state
    }
}


/// Set the current navigation root. 
/// Discards all the current routes and replaces it with the root routable!
public struct SetRootRoutable: Action {
    
    private let routable: Routable
    
    public init(routable: Routable) {
        self.routable = routable
    }
    
    public func updatedState(currentState: State) -> State {
        guard var state = currentState as? RoutableState else { return currentState }
        let rootDestination = Destination(routableType: type(of: routable), contextData: nil)
        let rootNode = NavigationTreeNode(value: rootDestination)
        rootNode.currentRoutable = routable
        state.navigationState.navigationTreeRootNode = rootNode
        return state
    }

}
