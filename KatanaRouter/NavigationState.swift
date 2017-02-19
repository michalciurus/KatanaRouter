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
    public let instanceIdentifier: UUID = UUID()
    public var hashValue: Int {
        return instanceIdentifier.hashValue
    }
    
    public static func ==(lhs: Destination, rhs: Destination) -> Bool {
        return lhs.instanceIdentifier == rhs.instanceIdentifier
    }
}

public struct NavigationState {
    public init() {}
    public var navigationTreeRootNode: NavigationTreeNode?
}

public protocol RoutableState: State {
    var navigationState: NavigationState { get set }
}

public extension NavigationState {
    public mutating func addNewDestinationToActiveRoute(_ destination: Routable.Type, contextData: Any?) {
        let destination = Destination(routableType: destination, contextData: contextData)
        let destinationNode = NavigationTreeNode(value: destination)
        destinationNode.isActiveRoute = true
        
        guard let rootNode = navigationTreeRootNode else {
            navigationTreeRootNode = destinationNode
            return
        }
        
        rootNode.addActiveLeaf(node: destinationNode)
    }
}
