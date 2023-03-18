//
//  AppModules.swift
//  dropper
//
//  Created by Andrew Tokeley on 21/02/23.
//

import Foundation
import Viperit

enum AppModules: String, ViperitModule {
    case game
    case home
    
    var viewType: ViperitViewType {
        return .code
    }
}
