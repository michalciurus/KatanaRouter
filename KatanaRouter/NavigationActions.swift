//
//  NavigationActions.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 09/02/17.
//  Copyright © 2017 Michal Ciurus. All rights reserved.
//

import Katana

/// Add a new destination on top of the current route
public struct AddNewDestination: Action {
    
    private let destination: Destination
    
    public init(destination: Destination) {
        self.destination = destination
    }
    
    public func updatedState(currentState: State) -> State {
        guard var state = currentState as? RoutableState else { return currentState }
        state.navigationState.addNewDestinationToActiveRoute(destination: destination)
        return state
    }
}

/// Removes the destination with given instance identifier from the navigation tree
/// Doesn't do anything if the node is not in the tree
/// Very useful for updating the tree with automatic navigation e.g. back button in UINavigationController
public struct RemoveDestination: Action {
    
    private let instanceIdentifier: UUID
    
    
    public init(instanceIdentifier: UUID) {
        self.instanceIdentifier = instanceIdentifier
    }
    
    public func updatedState(currentState: State) -> State {
        guard var state = currentState as? RoutableState else { return currentState }
        state.navigationState.removeDestination(instanceIdentifier: instanceIdentifier)
        return state
    }
}

/// Removes currently active destination
public struct RemoveCurrentDestination: Action {
    public func updatedState(currentState: State) -> State {
        guard var state = currentState as? RoutableState else { return currentState }
        state.navigationState.removeDestinationAtActiveRoute()
        return state
    }
    
    public init() {
        
    }
}

// Add children to a node with given user identifier
public struct AddChildrenToDestination: Action {
    
    private let destinationIdentifier: String
    // All destinations to add
    private let destinations: [Destination]
    // Destination to set active as
    private let activeDestination: Destination?
    
    public init(identifier: String, destinations: [Destination], activeDestination: Destination?) {
        self.destinationIdentifier = identifier
        self.destinations = destinations
        self.activeDestination = activeDestination
    }
    
    
    /// Adds one active child to a destination
    ///
    /// - Parameters:
    ///   - identifier: destination to add to
    ///   - child: to add to the destination
    public init(identifier: String, child: Destination) {
        self.destinationIdentifier = identifier
        self.destinations = [child]
        self.activeDestination = child
    }
    
    public func updatedState(currentState: State) -> State {
        guard var state = currentState as? RoutableState else { return currentState }
        guard let node = state.navigationState.mutateNavigationTreeRootNode()?.find(userIdentifier: destinationIdentifier) else {
            return currentState
        }
        
        let childrenNodes = destinations.map { addDestination -> NavigationTreeNode in
            return NavigationTreeNode(value: addDestination, isActiveRoute: addDestination == activeDestination)
        }

        node.addChildren(childrenNodes)
        
        return state
    }
}
