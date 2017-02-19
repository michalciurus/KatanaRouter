//
//  Routbale.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 15/02/17.
//  Copyright © 2017 MichalCiurus. All rights reserved.
//

import Foundation

public typealias RoutableCompletion = () -> Void

public protocol Routable {    
    func push(destination: Destination, completionHandler: @escaping RoutableCompletion) -> Routable
    func pop(destination: Destination, completionHandler: @escaping RoutableCompletion)
    func change(destinationsToPop: [Destination],
                destinationsToPush: [Destination],
                completionHandler: @escaping RoutableCompletion) -> [Destination : Routable]
}
