//
//  ServiceFactory.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/03/23.
//

import Foundation

enum ServiceError: Error {
    case Failed
}

class ServiceFactory {
    
    static let sharedInstance = ServiceFactory()
    
    var runningInTestMode: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    lazy var gameService: GameServiceContract = {
        return GameService(runningInTestMode)
    }()
    
    lazy var levelService: LevelServiceContract = {
        return LevelService(runningInTestMode)
    }()
}
