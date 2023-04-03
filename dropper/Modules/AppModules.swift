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
    case settings
    case popup
    case loading
    var viewType: ViperitViewType {
        if self == .loading {
            return .storyboard
        }
        return .code
    }
}
