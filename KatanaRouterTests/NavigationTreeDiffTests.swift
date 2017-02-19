//
//  NavigationTreeDiffTests.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 16/02/17.
//  Copyright © 2017 Michal Ciurus. All rights reserved.
//

import XCTest
@testable import KatanaRouter

class NavigationTreeDiffTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupExampleNodes()
    }
    
    override func tearDown() {
        super.tearDown()
        setupExampleNodes()
        
    }
    
    func testDiffA() {
        nodeA.isActiveRoute = true
        
        nodeB.isActiveRoute = true
        nodeB.addChild(nodeC)
        
        let actions = NavigationTreeDiff.getNavigationDiffActions(lastState: nodeA, currentState: nodeB)
        XCTAssert(isChangeNode(action: actions[0], nodesPushed: [nodeB], nodesPopped: [nodeA]))
        XCTAssert(isPushWithNode(action: actions[1], node: nodeC))
    }
    
    func testDiffB() {
        nodeA.isActiveRoute = true
        
        let nodeACopy = nodeA.deepCopy()
        
        nodeACopy.addChild(nodeB)
        
        let actions = NavigationTreeDiff.getNavigationDiffActions(lastState: nodeA, currentState: nodeACopy)
        
        XCTAssert(isPushWithNode(action: actions[0], node: nodeB))
    }
    
    func testDiffC() {
        nodeA.isActiveRoute = true
        
        let nodeACopy = nodeA.deepCopy()
        
        nodeA.addChild(nodeB)
        
        let actions = NavigationTreeDiff.getNavigationDiffActions(lastState: nodeA, currentState: nodeACopy)
        
        XCTAssert(isPopWithNode(action: actions[0], node: nodeB))
    }
    
    func testDiffE() {
        let nodeADeepCopy = nodeA.deepCopy()
        nodeA.addChild(nodeB)
        nodeB.addChild(nodeC)
        nodeB.addChild(nodeD)
        
        nodeADeepCopy.addChild(nodeE)
        nodeE.addChild(nodeF)
        nodeE.addChild(nodeG)
        
        let actions = NavigationTreeDiff.getNavigationDiffActions(lastState: nodeA, currentState: nodeADeepCopy)
        
        XCTAssert(isChangeNode(action: actions[0], nodesPushed: [], nodesPopped: [nodeC, nodeD]))
        XCTAssert(isChangeNode(action: actions[1], nodesPushed: [nodeE], nodesPopped: [nodeB]))
        XCTAssert(isChangeNode(action: actions[2], nodesPushed: [nodeF, nodeG], nodesPopped: []))
    }
    
    func testDiffLastStateIsNil() {
        nodeA.addChild(nodeB)
        
        let actions = NavigationTreeDiff.getNavigationDiffActions(lastState: nil, currentState: nodeA)
        
        XCTAssert(isPushWithNode(action: actions[0], node: nodeA))
        XCTAssert(isPushWithNode(action: actions[1], node: nodeB))
    }
    
    func testDiffCurrentStateIsNil() {
        nodeA.addChild(nodeB)
        
        let actions = NavigationTreeDiff.getNavigationDiffActions(lastState: nodeA, currentState: nil)
        
        XCTAssert(isPopWithNode(action: actions[0], node: nodeB))
        XCTAssert(isPopWithNode(action: actions[1], node: nodeA))
    }
    
    
    
    func isPushWithNode(action: NavigationTreeDiffAction, node: NavigationTreeNode) -> Bool {
        if case NavigationTreeDiffAction.push(let x) = action {
            if x == node {
                return true
            }
        }
        
        return false
    }
    
    func isPopWithNode(action: NavigationTreeDiffAction, node: NavigationTreeNode) -> Bool {
        if case NavigationTreeDiffAction.pop(let x) = action {
            if x == node {
                return true
            }
        }
        
        return false
    }
    
    func isChangeNode(action: NavigationTreeDiffAction, nodesPushed: [NavigationTreeNode], nodesPopped: [NavigationTreeNode]) -> Bool {
        
        if case NavigationTreeDiffAction.changed(let diffPopped, let diffPushed) = action {
            var isCorrect = diffPopped.count == nodesPopped.count && diffPushed.count == nodesPushed.count
            
            for nodePushed in diffPushed {
                if !nodesPushed.contains(nodePushed) {
                    isCorrect = false
                }
            }
            
            for nodePopped in diffPopped {
                if !nodesPopped.contains(nodePopped) {
                    isCorrect = false
                }
            }
            
            return isCorrect
        }
        
        return false
    }
    
}
