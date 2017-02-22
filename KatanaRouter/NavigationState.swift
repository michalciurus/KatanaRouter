//
//  NavigationState.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 09/02/17.
//  Copyright © 2017 Michal Ciurus. All rights reserved.
//

import Katana

public protocol RoutableState: State {
    var navigationState: NavigationState { get set }
}

public struct NavigationState {
    private var navigationTreeRootNode: NavigationTreeNode?
    
    public init(navigationRootNode: NavigationTreeNode? = nil) {
        self.navigationTreeRootNode = navigationRootNode
    }

    mutating func setNavigationTreeRootNode(_ navigationTreeRootNode: NavigationTreeNode?) {
        self.navigationTreeRootNode = navigationTreeRootNode
    }
    
    /// Whenever mutating `navigationTreeRootNode` which is an object, a copy is created so it doesn't affect
    /// other `NavigationState` values
    ///
    /// - Returns: a copy of `navigationTreeRootNode`, which becomes the new `navigationTreeRootNode`
    mutating func mutateNavigationTreeRootNode() -> NavigationTreeNode? {
        navigationTreeRootNode = navigationTreeRootNode?.deepCopy()
        return navigationTreeRootNode
    }
}

//MARK: NavigationState Mutation Helper Functions

public extension NavigationState {
    public mutating func addNewDestinationToActiveRoute(destination: Destination) {
        let destinationNode = NavigationTreeNode(value: destination, isActiveRoute: true)
        
        guard let rootNode = mutateNavigationTreeRootNode() else {
            setNavigationTreeRootNode(destinationNode)
            return
        }
        
        rootNode.addActiveLeaf(node: destinationNode)
    }
    
    public mutating func removeDestinationAtActiveRoute() {
        guard let rootNode = mutateNavigationTreeRootNode() else { return }
        guard let activeLeaf = rootNode.getActiveLeaf() else { return }
        activeLeaf.removeNode()
    }
    
    public mutating func removeDestination(instanceIdentifier: UUID) {
        guard let rootNode = mutateNavigationTreeRootNode() else { return }
        let nodeToRemove = rootNode.find() {
            $0.value.instanceIdentifier == instanceIdentifier
        }
        
        print(instanceIdentifier)
        
        nodeToRemove?.removeNode()        
    }
    
}
