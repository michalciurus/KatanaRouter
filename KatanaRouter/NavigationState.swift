//
//  NavigationState.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 09/02/17.
//  Copyright © 2017 Michal Ciurus. All rights reserved.
//

import Katana

public struct Destination: Equatable, Hashable {
    public let routableType: Routable.Type
    public let contextData: Any?
    /// User identifier is optional, but has bigger priority than the instance identifier
    public let userIdentifier: String?
    public let instanceIdentifier: UUID = UUID()
    public var hashValue: Int {
        return instanceIdentifier.hashValue
    }
    
    public static func ==(lhs: Destination, rhs: Destination) -> Bool {
        if let lhsUserIdentifier = lhs.userIdentifier,
           let rhsUserIdentifier = rhs.userIdentifier {
            return lhs.userIdentifier == rhs.userIdentifier
        } else {
            return lhs.instanceIdentifier == rhs.instanceIdentifier
        }
    }
}

public protocol RoutableState: State {
    var navigationState: NavigationState { get set }
}

public struct NavigationState {
    public var navigationTreeRootNode: NavigationTreeNode?
    
    public init(navigationRootNode: NavigationTreeNode? = nil) {
        self.navigationTreeRootNode = navigationRootNode
    }
}

//MARK: NavigationState Mutation Helper Functions

public extension NavigationState {
    public mutating func addNewDestinationToActiveRoute(destination: Destination) {
        let destinationNode = NavigationTreeNode(value: destination)
        destinationNode.isActiveRoute = true
        
        guard let rootNode = navigationTreeRootNode else {
            navigationTreeRootNode = destinationNode
            return
        }
        
        rootNode.addActiveLeaf(node: destinationNode)
    }
}
