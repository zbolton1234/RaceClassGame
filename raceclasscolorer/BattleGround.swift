//
//  BattleGround.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 3/2/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

enum Spot {
    case void
    case empty
    case terain(String)
    case person(PersonState)
}

//TODO: rename this
enum TeamType {
    case our
    case enemy
}

class PersonState {
    let person: Person
    let teamType: TeamType
    var position: (x: Int, y: Int)?
    
    init(person: Person, teamType: TeamType) {
        self.person = person
        self.teamType = teamType
    }
    
    func distance(otherPerson: PersonState) -> Double? {
        guard let ourPosition = position,
            let otherPosition = otherPerson.position else {
            return nil
        }
        
        let xDiff = pow(Double(ourPosition.x - otherPosition.x), 2)
        let yDiff = pow(Double(ourPosition.y - otherPosition.y), 2)
        return sqrt(xDiff + yDiff)
    }
}

class BattleGround {
    let ourTeamSide: [PersonState]
    let enemyTeamSide: [PersonState]
    
    init(ourTeam: Team, enemyTeam: Team) {
        ourTeamSide = ourTeam.members.map({ PersonState(person: $0,
                                                        teamType: .our) })
        enemyTeamSide = enemyTeam.members.map({ PersonState(person: $0,
                                                            teamType: .enemy) })
    }
    
    func closestEnemy(attackingPerson: PersonState) -> PersonState? {
        let onOur = attackingPerson.teamType == .our
        let defendingTeam = onOur ? enemyTeamSide : ourTeamSide
        
        let distances = defendingTeam.compactMap({ (defender) -> (Double, PersonState)? in
            guard let distance = attackingPerson.distance(otherPerson: defender) else {
                return nil
            }
            return (distance, defender)
        })
        return distances.min(by: { $0.0 < $1.0 })?.1
    }
}
