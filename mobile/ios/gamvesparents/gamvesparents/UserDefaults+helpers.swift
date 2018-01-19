//
//  UserDefaults+helpers.swift
//  audible
//
//  Created by Brian Voong on 10/3/16.
//  Copyright © 2016 Lets Build That App. All rights reserved.
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
