//
//  NavigationTree.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 10/02/17.
//  Copyright © 2017 Michal Ciurus. All rights reserved.
//

import Foundation

final public class NavigationTreeNode: Equatable {
    
    public let value: Destination
    public var children: [NavigationTreeNode]
    public var isActiveRoute: Bool
    public var parentNode: NavigationTreeNode?
    public var currentRoutable: Routable?
    
    public init(value: Destination, children: [NavigationTreeNode] = [], isActiveRoute: Bool = false, parentNode: NavigationTreeNode? = nil, routable: Routable? = nil) {
        self.value = value
        self.children = []
        self.isActiveRoute = false
        self.parentNode = parentNode
    }
    
    public func addChild(_ node: NavigationTreeNode) {
        children.append(node)
        node.parentNode = self
    }
    
    public func getActiveLeaf() -> NavigationTreeNode? {
        guard isActiveRoute else { return nil }
        
        var activeLeaf = self
        while let childActiveLeaf = activeLeaf.getActiveChild() {
            activeLeaf = childActiveLeaf
        }
        
        return activeLeaf
    }
    
    public func addActiveLeaf(node: NavigationTreeNode) {
        let activeLeaf = self.getActiveLeaf() ?? self
        activeLeaf.isActiveRoute = true
        node.isActiveRoute = true
        
        activeLeaf.addChild(node)
    }
    
    public func getActiveChild() -> NavigationTreeNode? {
        for child in children {
            if child.isActiveRoute {
                return child
            }
        }
        
        return nil
    }
    
    public func traverse(postOrder: Bool, visitNode: (NavigationTreeNode) -> ()) {
        let activeChildrenLast = children.sorted { !($0.0.isActiveRoute) }
        
        if !postOrder {
            visitNode(self)
        }
        
        for child in activeChildrenLast {
            child.traverse(postOrder: postOrder, visitNode: visitNode)
        }
        
        if postOrder {
            visitNode(self)
        }
    }
    
    public func find(value: Destination) -> NavigationTreeNode? {
        
        if value == self.value {
            return self
        }
        
        for child in children {
            let searchResult = child.find(value: value)
            if searchResult != nil {
                return searchResult
            }
        }
        
        return nil
    }
    
    public func containsValue(value: Destination) -> Bool {
        return find(value: value) != nil ? true : false
    }
    
    public func deepCopy() -> NavigationTreeNode {
        var childrenCopies: [NavigationTreeNode] = []
        
        let navigationNodeCopy = NavigationTreeNode(value: value, children: [ ], isActiveRoute: isActiveRoute, routable: currentRoutable)
        
        for child in children {
            let childCopy = child.deepCopy()
            childCopy.parentNode = navigationNodeCopy
            childrenCopies.append(childCopy)
        }
        
        navigationNodeCopy.children = childrenCopies
        
        return navigationNodeCopy
    }
    
    public static func ==(lhs: NavigationTreeNode, rhs: NavigationTreeNode) -> Bool {
        return lhs.value == rhs.value
    }
}
