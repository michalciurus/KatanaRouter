//
//  KatanaRouterTests.swift
//  KatanaRouterTests
//
//  Created by Michal Ciurus on 16/02/17.
//  Copyright © 2017 Michal Ciurus. All rights reserved.
//

import XCTest
@testable import KatanaRouter

class NavigationTreeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        setupExampleNodes()
    }
    
    override func tearDown() {
        super.tearDown()
        setupExampleNodes()
    }
    
    func testAddingChild() {
        nodeA.addChild(nodeB)
        
        XCTAssert(nodeB.parentNode == nodeA)
    }
    
    func testFindActiveLeaf() {
        nodeA.isActiveRoute = true
        nodeB.isActiveRoute = false
        nodeC.isActiveRoute = true
        nodeD.isActiveRoute = true
        
        nodeA.addChild(nodeB)
        nodeA.addChild(nodeC)
        nodeC.addChild(nodeD)
        
        XCTAssert(nodeA.getActiveLeaf() == nodeD)
        XCTAssert(nodeD.isActiveRoute)
    }
    
    func testAddActiveLeafToInactiveRoot() {
        nodeA.isActiveRoute = false
        nodeA.addActiveLeaf(node: nodeB)
        
        XCTAssert(nodeA.isActiveRoute)
        XCTAssert(nodeB.isActiveRoute)
    }
    
    func testNormalAddActiveLeaf() {
        nodeA.isActiveRoute = true
        nodeB.isActiveRoute = false
        nodeC.isActiveRoute = true
        nodeD.isActiveRoute = true
        nodeE.isActiveRoute = false
        
        nodeA.addChild(nodeB)
        nodeA.addChild(nodeC)
        nodeC.addChild(nodeD)
        nodeA.addActiveLeaf(node: nodeE)
        
        XCTAssert(nodeE.parentNode == nodeD)
        XCTAssert(nodeE.isActiveRoute)
    }
    
    func testTraverseTestA() {
        setupExampleTreeA()
        
        var traverseHistory: [NavigationTreeNode] = []
        
        nodeA.traverse(postOrder: false) { node in
            print(node.value.routableType)
            traverseHistory.append(node)
        }
        
        XCTAssert(traverseHistory[0] == nodeA)
        XCTAssert(traverseHistory[1] == nodeC)
        XCTAssert(traverseHistory[2] == nodeD)
        XCTAssert(traverseHistory[3] == nodeE)
        XCTAssert(traverseHistory[4] == nodeB)
    }
    
    func testTraverseTestB() {
        setupExampleTreeA()
        
        var traverseHistory: [NavigationTreeNode] = []
    
        nodeA.traverse(postOrder: true) { node in
            print(node.value.routableType)
            traverseHistory.append(node)
        }
        
        XCTAssert(traverseHistory[0] == nodeE)
        XCTAssert(traverseHistory[1] == nodeD)
        XCTAssert(traverseHistory[2] == nodeC)
        XCTAssert(traverseHistory[3] == nodeB)
        XCTAssert(traverseHistory[4] == nodeA)
    }
    
    func testFind() {
        setupExampleTreeA()
        
        XCTAssert(nodeA.find(value: nodeE.value) == nodeE)
    }
    
    func testDeepCopy() {
        setupExampleTreeA()
        
        let nodeADeepCopy = nodeA.deepCopy()
        
        var traverseHistory: [NavigationTreeNode] = []
        var traverseHistoryDeepCopy: [NavigationTreeNode] = []

        nodeA.traverse(postOrder: true) { node in
            traverseHistory.append(node)
        }
        
        nodeADeepCopy.traverse(postOrder: true) { node in
            traverseHistoryDeepCopy.append(node)
        }
        
        for index in 0..<5 {
            XCTAssert(traverseHistoryDeepCopy[index] !== traverseHistory[index])
            XCTAssert(traverseHistoryDeepCopy[index] == traverseHistory[index])
        }
        
        XCTAssert(nodeB.parentNode !== nodeADeepCopy.children[0].parentNode)
        XCTAssert(nodeB.parentNode == nodeADeepCopy.children[0].parentNode)
    }
}
