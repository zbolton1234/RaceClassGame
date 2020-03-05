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
    
    private(set) var ground: [[Spot]]
    
    init(ourTeam: Team, enemyTeam: Team) {
        ourTeamSide = ourTeam.members.map({ PersonState(person: $0,
                                                        teamType: .our) })
        enemyTeamSide = enemyTeam.members.map({ PersonState(person: $0,
                                                            teamType: .enemy) })
        
        ourTeamSide.enumerated().forEach({ (index, state) in
            state.position = (index + 2, 0)
        })
        let convertedOur = ourTeamSide.map({ Spot.person($0) })
        enemyTeamSide.enumerated().forEach({ (index, state) in
            state.position = (index + 2, 5)
        })
        let convertedEnemy = enemyTeamSide.map({ Spot.person($0) })

        //TODO: different sizes and different layouts needed
        ground = [[.void, .void] + convertedOur + [.void, .void],
        [.void, .empty, .empty, .empty, .empty, .empty, .void],
        [.void, .void, .empty, .void, .empty, .void, .void],
        [.void, .void, .empty, .void, .empty, .void, .void],
        [.void, .empty, .empty, .empty, .empty, .empty, .void],
        [.void, .void] + convertedEnemy + [.void, .void]]
    }
    
    func closestEnemy(attackingPerson: PersonState) -> (Double, PersonState)? {
        let onOur = attackingPerson.teamType == .our
        let defendingTeam = onOur ? enemyTeamSide : ourTeamSide
        
        let distances = defendingTeam.compactMap({ (defender) -> (Double, PersonState)? in
            guard defender.person.currentHp > 0 else {
                return nil
            }
            
            guard let distance = attackingPerson.distance(otherPerson: defender) else {
                return nil
            }
            return (distance, defender)
        })
        return distances.min(by: { $0.0 < $1.0 })
    }
    
    func move(person: PersonState, position: (x: Int, y: Int)) -> Bool {
        //TODO: do this better
        if case .person(let personInSpot) = ground[position.y][position.x] {
            if personInSpot.person.currentHp <= 0 {
                ground[position.y][position.x] = .empty
            }
        }
        
        guard case .empty = ground[position.y][position.x] else {
            return false
        }
        
        ground[position.y][position.x] = .person(person)
        
        if let oldPosition = person.position {
            ground[oldPosition.y][oldPosition.x] = .empty
        }
        
        person.position = position
        return true
    }
}
