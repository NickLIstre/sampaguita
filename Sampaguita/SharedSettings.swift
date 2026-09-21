//
//  SharedSettings.swift
//  Sampaguita
//
//  Created by Nick Istre on 9/21/26.
//

import Foundation

enum SharedSettings {
    static let appGroup = "group.com.blackbaccaraproductions.Sampaguita"
    static let store = UserDefaults(suiteName: appGroup)!

    static let textOpacityKey = "textOpacity"
}
