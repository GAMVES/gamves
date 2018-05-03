//
//  UserDefaults+helpers.swift
//  audible
//
//  Created by Jose Vigil 08/12/2017.
//

import Foundation

extension UserDefaults {
    
    enum UserDefaultsKeys: String {
        case isLoggedIn
        case isHasProfileInfo
        case isRegistered
    }
    
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    func setHasProfileInfo(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isHasProfileInfo.rawValue)
        synchronize()
    }
    
    func isHasProfileInfo() -> Bool {
        return bool(forKey: UserDefaultsKeys.isHasProfileInfo.rawValue)
    }
    
    func setIsRegistered(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isRegistered.rawValue)
        synchronize()
    }
    
    func isRegistered() -> Bool {
        return bool(forKey: UserDefaultsKeys.isRegistered.rawValue)
    }
    
    
    
}
