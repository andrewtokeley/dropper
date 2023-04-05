//
//  ServiceBase.swift
//  dropper
//
//  Created by Andrew Tokeley on 22/03/23.
//

import Foundation

class ServiceBase {
    var testMode: Bool = false
    var KEY_PREFIX: String {
        return testMode ? "TEST_" : ""
    }
    init(_ testMode: Bool = false) {
        self.testMode = testMode
    }
}
