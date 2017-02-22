//
//  Routbale.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 15/02/17.
//  Copyright © 2017 MichalCiurus. All rights reserved.
//

import Foundation

public typealias RoutableCompletion = () -> Void

/// Building block of KatanaRouter
/// Represents a unique navigation destination
/// Every destination has a unique instanceIdentifier
/// Optionally, it can have a userIdentifier, which has higher priority than instanceIdentifier
/// ** userIdentifier ** must be unique!!
public struct Destination: Equatable, Hashable {
    public let routableType: Routable.Type
    public let contextData: Any?
    /// User identifier is optional, but has bigger priority than the instance identifier
    public let userIdentifier: String?
    public let instanceIdentifier: UUID
    public var hashValue: Int {
        return instanceIdentifier.hashValue
    }
    
    /// - Parameters:
    ///   - routableType: routable type of the destination
    ///   - contextData: context data e.g. flags, animation properties
    ///   - userIdentifier: identifier set by user to easily manage destinations **must be unique! **
    ///   - instanceIdentifier: unique destination identifier
    public init(routableType: Routable.Type, contextData: Any? = nil, userIdentifier: String? = nil, instanceIdentifier: UUID = UUID()) {
        self.instanceIdentifier = instanceIdentifier
        self.routableType = routableType
        self.contextData = contextData
        self.userIdentifier = userIdentifier
    }
    
    public static func ==(lhs: Destination, rhs: Destination) -> Bool {
        if let lhsUserIdentifier = lhs.userIdentifier,
            let rhsUserIdentifier = rhs.userIdentifier {
            return lhsUserIdentifier == rhsUserIdentifier
        } else {
            return lhs.instanceIdentifier == rhs.instanceIdentifier
        }
    }
}

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
    
    
    /// Called when there's a new destination set to active
    ///
    /// - Parameters:
    ///   - currentActiveDestination: destination that was set to active
    ///   - completionHandler: completion handler **needs to be called** after the transition
    func changeActiveDestination(currentActiveDestination: Destination, completionHandler: @escaping RoutableCompletion)
}

public extension Routable {
    
    // push, pop, change need to be implemented *if* they're ever called. Otherwise the UI navigation tree and the Router navigation tree will be out of sync which is an invalid state and the application should not be allowed to run.

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
    
    // changeActiveDestination is fully optional
    
    func changeActiveDestination(currentActiveDestination: Destination, completionHandler: @escaping RoutableCompletion) {
        completionHandler()
    }
}

