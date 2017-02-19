//
//  NavigationActions.swift
//  KatanaRouter
//
//  Created by Michal Ciurus on 09/02/17.
//  Copyright © 2017 Michal Ciurus. All rights reserved.
//

import Katana

public struct AddNavigationDestination: Action {
    
    private let routableType: Routable.Type
    private let contextData: Any?
    
    public func updatedState(currentState: State) -> State {
        guard var state = currentState as? RoutableState else { return currentState }
        state.navigationState.addNewDestinationToActiveRoute(routableType, contextData: contextData)
        return state
    }
}
