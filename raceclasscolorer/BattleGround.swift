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
    var position: Position?
    
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
    
    let ourTeam: Team
    let enemyTeam: Team
    
    private(set) var ground: [[Spot]]
    
    init(ourTeam: Team, enemyTeam: Team, groundJson: GroundJson) {
        self.ourTeam = ourTeam
        self.enemyTeam = enemyTeam
        
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
        
        var ground = [[Spot]]()
        for line in groundJson.ground {
            var groundLine = [Spot]()
            for tile in line {
                switch tile {
                case "e":
                    groundLine.append(.empty)
                case "o":
                    groundLine.append(contentsOf: convertedOur)
                case "m":
                    groundLine.append(contentsOf: convertedEnemy)
                case "t":
                    groundLine.append(.terain("Tree"))
                default:
                    groundLine.append(.void)
                }
            }
            ground.append(groundLine)
        }
        self.ground = ground
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
    
    func move(person: PersonState, position: Position) -> Bool {
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
    
    private func sightBlocked(attackingPosition: Position, defendingPosition: Position) -> Bool {
        let allPositions = smartVisionLine(position1: attackingPosition, position2: defendingPosition)
        
        for position in allPositions {
            if position != attackingPosition && position != defendingPosition {
                if case .empty = ground[position.y][position.x] {
                    //TODO: uuugggg
                } else {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func teamAttack(attackingTeam: [PersonState], defendingTeam: [PersonState]) {
        attackingTeam.enumerated().forEach({ (index, memberState) in
            let member = memberState.person
            guard member.currentHp > 0,
                let memberPosition = memberState.position else {
                return
            }
            
            switch member.attackType {
            case .aoe:
                for enemyState in defendingTeam {
                    enemyState.person.currentHp -= Int(Float(2) * member.attackModifer(enemy: enemyState.person))
                }
            case .ping:
                let enemyState = defendingTeam.randomElement()!
                enemyState.person.currentHp -= 1
            case .singleRanged:
                if let closestEnemyState = closestEnemy(attackingPerson: memberState), let closestPosition = closestEnemyState.1.position {
                    if !sightBlocked(attackingPosition: memberPosition, defendingPosition: closestPosition) {
                        closestEnemyState.1.person.currentHp -= Int(Float(5) * member.attackModifer(enemy: closestEnemyState.1.person))
                    } else {
                        print("my line was blocked")
                    }
                }
            case .single:
                if let closestEnemyState = closestEnemy(attackingPerson: memberState) {
                    //print("I'm \(member.race.name)\(member.pclass.name)\(member.color) and \(enemyState.1.person.race.name)\(enemyState.1.person.pclass.name)\(enemyState.1.person.color) is \(enemyState.0)")
                    
                    if closestEnemyState.0 < 2.0 {
                        closestEnemyState.1.person.currentHp -= Int(Float(5) * member.attackModifer(enemy: closestEnemyState.1.person))
                    } else {
                        var newPostion = memberPosition
                        var yChange = 0
                        var xChange = 0
                        
                        if closestEnemyState.1.position?.y ?? 0 > memberPosition.y {
                            newPostion.y += 1
                            yChange = 1
                        } else if closestEnemyState.1.position?.y ?? 0 < memberPosition.y {
                            newPostion.y -= 1
                            yChange = -1
                        }
                        
                        if closestEnemyState.1.position?.x ?? 0 > memberPosition.x {
                            newPostion.x += 1
                            xChange = 1
                        } else if closestEnemyState.1.position?.x ?? 0 < memberPosition.x {
                            newPostion.x -= 1
                            xChange = -1
                        }
                        
                        //TODO: feel like this is overcomplicated
                        if !move(person: memberState, position: newPostion) {
                            //print("failed \(newPostion)")
                            if xChange == 0 {
                                newPostion.x -= 1
                                //print("trying \(newPostion)")
                                if !move(person: memberState, position: newPostion) {
                                    newPostion.x += 2
                                    //print("trying \(newPostion)")
                                    move(person: memberState, position: newPostion)
                                }
                            } else if yChange == 0 {
                                newPostion.y -= 1
                                //print("trying \(newPostion)")
                                if !move(person: memberState, position: newPostion) {
                                    newPostion.y += 2
                                    //print("trying \(newPostion)")
                                    move(person: memberState, position: newPostion)
                                }
                            } else {
                                newPostion.x += xChange
                                //print("trying \(newPostion)")
                                if !move(person: memberState, position: newPostion) {
                                    newPostion.x -= xChange
                                    newPostion.y += yChange
                                    //print("trying \(newPostion)")
                                    move(person: memberState, position: newPostion)
                                }
                            }
                        }
                    }
                }
            case .buff:
                for memberState in attackingTeam {
                    memberState.person.currentAttack += 1
                }
            }
        })
    }
    
    //TODO: the passing this view here feels bad should be a block
    func fight(battleFieldView: BattleFieldView, completion: @escaping ((FightState) -> Void)) {
        
        DispatchQueue.global(qos: .background).async {
            while self.ourTeam.isAlive && self.enemyTeam.isAlive {
                DispatchQueue.main.sync {
                    self.teamAttack(attackingTeam: self.ourTeamSide, defendingTeam: self.enemyTeamSide)
                    self.teamAttack(attackingTeam: self.enemyTeamSide, defendingTeam: self.ourTeamSide)
                    battleFieldView.updateBattleGround(battleGround: self)
                }
                sleep(3)
            }
            
            let wonState = self.ourTeam.isAlive
            
            let reward: Reward
            if wonState {
                reward = Reward(people: [self.enemyTeam.members.randomElement()!],
                                points: [Points(race: self.ourTeam.members.first!.race, points: 5)])
            } else {
                reward = Reward(people: [], points: [])
            }
            
            DispatchQueue.main.sync {
                completion(FightState(won: wonState, reward: reward))
            }
        }
    }
}
