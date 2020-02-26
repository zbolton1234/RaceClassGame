//
//  Team.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/20/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class Team {
    var members: [Person]
    
    init(members: [Person]) {
        self.members = members
    }
    
    var isAlive: Bool {
        return !members.reduce(true, { $0 && $1.currentHp <= 0 })
    }
}
