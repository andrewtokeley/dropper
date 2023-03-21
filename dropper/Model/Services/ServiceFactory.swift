//
//  ServiceFactory.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/03/23.
//

import Foundation

class ServiceFactory {
    
    static let sharedInstance = ServiceFactory()
    
    lazy var gameService: GameServiceContract = {
        return GameService()
    }()
    
    lazy var levelService: LevelServiceContract = {
        return LevelService()
    }()
}
