//
//  PFGeoPoint+Extension.swift
//  gamvesparents
//
//  Created by XCodeClub on 2018-04-03.
//  Copyright © 2018 Lets Build That App. All rights reserved.
//

import Parse

extension PFGeoPoint {
    
    func location() -> CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
}
