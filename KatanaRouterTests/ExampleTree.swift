//
//  ExampleTree.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 16/02/17.
//  Copyright © 2017 Michal Ciurus. All rights reserved.
//

import Foundation
@testable import KatanaRouter

var nodeA: NavigationTreeNode!
var nodeB: NavigationTreeNode!
var nodeC: NavigationTreeNode!
var nodeD: NavigationTreeNode!
var nodeE: NavigationTreeNode!
var nodeF: NavigationTreeNode!
var nodeG: NavigationTreeNode!
var nodeH: NavigationTreeNode!

class BaseExampleNode: Routable {
    func push(destination: Destination, completionHandler: @escaping RoutableCompletion) -> Routable { return self }
    func pop(destination: Destination, completionHandler: @escaping RoutableCompletion) { }
    func change(destinationsToPop: [Destination], destinationsToPush: [Destination], completionHandler: @escaping RoutableCompletion) -> [Destination : Routable] { return [Destination(routableType: A.self, contextData: nil): self] }
}

class A: BaseExampleNode {

}
class B: BaseExampleNode {

}

class C: BaseExampleNode {

}

class D: BaseExampleNode {

}

class E: BaseExampleNode {

}

class F: BaseExampleNode {

}

class G: BaseExampleNode {

}
class H: BaseExampleNode {
}


func setupExampleNodes() {
    let destinationA = Destination(routableType: A.self, contextData: nil)
    let destinationB = Destination(routableType: B.self, contextData: nil)
    let destinationC = Destination(routableType: C.self, contextData: nil)
    let destinationD = Destination(routableType: D.self, contextData: nil)
    let destinationE = Destination(routableType: E.self, contextData: nil)
    let destinationF = Destination(routableType: F.self, contextData: nil)
    let destinationG = Destination(routableType: G.self, contextData: nil)
    let destinationH = Destination(routableType: H.self, contextData: nil)
    
    
    nodeA = NavigationTreeNode(value: destinationA)
    nodeB = NavigationTreeNode(value: destinationB)
    nodeC = NavigationTreeNode(value: destinationC)
    nodeD = NavigationTreeNode(value: destinationD)
    nodeE = NavigationTreeNode(value: destinationE)
    nodeF = NavigationTreeNode(value: destinationF)
    nodeG = NavigationTreeNode(value: destinationG)
    nodeH = NavigationTreeNode(value: destinationH)
}


func setupExampleTreeA() {
    nodeA.isActiveRoute = true
    nodeB.isActiveRoute = true
    nodeC.isActiveRoute = false
    nodeD.isActiveRoute = false
    nodeE.isActiveRoute = false
    
    nodeA.addChild(nodeB)
    nodeA.addChild(nodeC)
    nodeC.addChild(nodeD)
    nodeD.addChild(nodeE)
}
