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
    
    /// Singular push action happened
    ///
    /// - Parameters:
    ///   - destination: destination to push
    ///   - completionHandler: completion handler **needs to be called** after the transition
    /// - Returns: the Routable responsible for the pushed object
    func push(destination: Destination, completionHandler: @escaping RoutableCompletion) -> Routable
    
    
    /// Singular pop action happened
    ///
    /// - Parameters:
    ///   - destination: destination to pop
    ///   - completionHandler: completion handler **needs to be called** after the transition
    func pop(destination: Destination, completionHandler: @escaping RoutableCompletion)
    
    
    /// A more complex action. At least two singular pop/push actions.
    /// It gives you a chance to replace the Routables in one smooth transition.
    ///
    /// - Parameters:
    ///   - destinationsToPop: destinations to pop
    ///   - destinationsToPush: destinations to push
    ///   - completionHandler: completion handler **needs to be called** after the transition
    /// - Returns: **Important** A dictionary of pushed destinations and their corresponding Routables
    ///            You need to return all the created Routables for the pushed destinations
    func change(destinationsToPop: [Destination],
                destinationsToPush: [Destination],
                completionHandler: @escaping RoutableCompletion) -> [Destination : Routable]
}

public extension Routable {
    func push(destination: Destination, completionHandler: @escaping RoutableCompletion) -> Routable {
        fatalError("`push` function is not implemented in this Routable")
    }
    func pop(destination: Destination, completionHandler: @escaping RoutableCompletion) {
        fatalError("`pop` function is not implemented in this Routable")
    }
    func change(destinationsToPop: [Destination],
                destinationsToPush: [Destination],
                completionHandler: @escaping RoutableCompletion) -> [Destination : Routable] {
        fatalError("`change` function is not implemented in this Routable")
    }
}

