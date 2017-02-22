//
//  NavigationTree.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 10/02/17.
//  Copyright © 2017 Michal Ciurus. All rights reserved.
//

import Foundation


/// Navigation tree node, used to build a tree structure of the navigation state
final public class NavigationTreeNode: Equatable {
    
    public let value: Destination
    /// Active route is the currently visible navigation path of nodes
    public var isActiveRoute: Bool
    public var parentNode: NavigationTreeNode?
    
    public private(set) var children: [NavigationTreeNode]
    
    public init(value: Destination, children: [NavigationTreeNode] = [], isActiveRoute: Bool, parentNode: NavigationTreeNode? = nil) {
        self.value = value
        self.children = []
        self.isActiveRoute = isActiveRoute
        self.parentNode = parentNode
    }
    
    public func addChild(_ node: NavigationTreeNode) {
        children.append(node)
        node.parentNode = self
    }
    
    public func addChildren( _ children: [NavigationTreeNode]) {
        for child in children {
            self.addChild(child)
        }
    }
    
    public func removeChild(_ child: NavigationTreeNode) {
        guard let index = children.index(of: child) else { return }
        children.remove(at: index)
    }
    
    public func removeNode() {
        guard let parentNode = parentNode else { return }
        parentNode.removeChild(self)
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
    
    
    /// Traverses all the nodes in the tree
    /// Inactive nodes have the priority: it's important that the active path is visited last
    /// - Parameters:
    ///   - postOrder: Traverses post order if true. Pre-order if false.
    ///   - visitNode: visitNode is called when a node is visited
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
        return find() {
            $0.value == value
        }
    }
    
    public func find(findCondition: (NavigationTreeNode) -> Bool) -> NavigationTreeNode?{
        if findCondition(self) {
            return self
        }
        
        for child in children {
            let searchResult = child.find(findCondition: findCondition)
            if searchResult != nil {
                return searchResult
            }
        }
        
        return nil
    }
    
    public func find(userIdentifier: String) -> NavigationTreeNode? {
        return find() {
            $0.value.userIdentifier == userIdentifier
        }
    }
    
    public func containsValue(value: Destination) -> Bool {
        return find(value: value) != nil ? true : false
    }
    
    
    /// Creates a deep copy of the node and it's children
    /// It does not create a copy of the parent! That's why it's best that this method is used on the root of the tree
    /// - Returns: deep copy of the tree
    public func deepCopy() -> NavigationTreeNode {
        var childrenCopies: [NavigationTreeNode] = []
        
        let navigationNodeCopy = NavigationTreeNode(value: value, children: [ ], isActiveRoute: isActiveRoute)
        
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
