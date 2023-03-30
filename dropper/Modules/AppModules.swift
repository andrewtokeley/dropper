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
    case modalDialog
    var viewType: ViperitViewType {
        if self == .modalDialog {
            return .storyboard
        } else {
            return .code
        }
    }
}
