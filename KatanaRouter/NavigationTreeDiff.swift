//
//  NavigationTreeDiff.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 15/02/17.
//  Copyright © 2017 Michal Ciurus. All rights reserved.
//

import Foundation

enum NavigationTreeDiffAction {
    case push(nodeToPush: NavigationTreeNode)
    case pop(nodeToPop: NavigationTreeNode)
    case changed(poppedNodes: [NavigationTreeNode], pushedNodes: [NavigationTreeNode])
}

class NavigationTreeDiff {
    
    static func getNavigationDiffActions(lastState: NavigationTreeNode?, currentState: NavigationTreeNode?) -> [NavigationTreeDiffAction] {
        
        var nodesToPop: [NavigationTreeNode] = []
        var nodesToPush: [NavigationTreeNode] = []
        
        lastState?.traverse(postOrder: true) { node in
            if !containsNode(node, in: currentState) {
                nodesToPop.append(node)
            }
        }
        
        currentState?.traverse(postOrder: false) { node in
            if !containsNode(node, in: lastState) {
                nodesToPush.append(node)
            }
        }
        
        let uniquePushParents: [NavigationTreeNode?] = getUniqueParents(nodesToPush)
        var filteredSinglePopNodes = nodesToPop
        var insertActions: [NavigationTreeDiffAction] = []
        
        for uniquePushParent in uniquePushParents {
            let sameParentFilter: (NavigationTreeNode) -> Bool = {
                $0.parentNode == uniquePushParent
            }
            let differentParentFilter: (NavigationTreeNode) -> Bool = {
                $0.parentNode != uniquePushParent
            }
            
            let pushesWithSameParent = nodesToPush.filter(sameParentFilter)
            let popsWithSameParent = nodesToPop.filter(sameParentFilter)
            
            guard pushesWithSameParent.count > 1 || popsWithSameParent.count > 0 else {
                insertActions.append(.push(nodeToPush: pushesWithSameParent[0]))
                continue
            }
            
            insertActions.append(.changed(poppedNodes: popsWithSameParent, pushedNodes: pushesWithSameParent))
            filteredSinglePopNodes = filteredSinglePopNodes.filter(differentParentFilter)
        }
        
        return getPopActions(from: filteredSinglePopNodes) + insertActions
    }
    
    static func getPopActions(from nodesToPop: [NavigationTreeNode]) -> [NavigationTreeDiffAction] {
        var popActions: [NavigationTreeDiffAction] = []
        let uniquePopParents: [NavigationTreeNode?] = getUniqueParents(nodesToPop)
        
        for uniquePopParent in uniquePopParents {
            let popsWithSameParent = nodesToPop.filter {
                $0.parentNode == uniquePopParent
            }
            
            guard popsWithSameParent.count > 1 else {
                popActions.append(.pop(nodeToPop: popsWithSameParent[0]))
                continue
            }
            
            popActions.append(.changed(poppedNodes: popsWithSameParent, pushedNodes: []))
        }
        
        return popActions
    }
    
    static func getUniqueParents(_ nodes: [NavigationTreeNode]) -> [NavigationTreeNode?] {
        var uniqueParents: [NavigationTreeNode?] = []
        for node in nodes {
            let containsParent = uniqueParents.contains {
                $0 == node.parentNode
            }
            if !containsParent {
                uniqueParents.append(node.parentNode)
            }
        }
        return uniqueParents
    }
    
    static func containsNode(_ node: NavigationTreeNode, in tree: NavigationTreeNode?) -> Bool {
        return tree?.containsValue(value: node.value) ?? false
    }
}
