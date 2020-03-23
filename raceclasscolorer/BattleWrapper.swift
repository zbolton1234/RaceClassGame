//
//  BattleWrapper.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 3/17/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import Foundation

protocol Battler {
    func totalBuffs(team: Team) -> Int
    func attackModifer(enemy: Battler) -> Float
    
    var attack: Int { get }
    var defense: Int { get }
    
    var currentHp: Int { get set }
    var currentAttack: Int { get set }
    var currentDefense: Int { get set }
}

extension Battler {
    func attackModifer(enemy: Battler) -> Float {
        if enemy.currentDefense == 0 {
            return Float(currentAttack)
        }
        return Float(currentAttack / enemy.currentDefense)
    }
}
