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

enum TeamType {
    case our
    case enemy
}

class PersonState: Hashable {
    let person: BattlePerson
    let teamType: TeamType
    var position: Position
    
    init(person: Person, teamType: TeamType, position: Position) {
        self.person = BattlePerson(person: person)
        self.teamType = teamType
        self.position = position
    }
    
    static func == (lhs: PersonState, rhs: PersonState) -> Bool {
        return lhs.person == rhs.person && lhs.position == rhs.position
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(person)
    }
}

extension Array where Element == PersonState {
    var isAlive: Bool {
        return !reduce(true, { $0 && !$1.person.isAlive })
    }
}

class BattleGround {
    let ourTeamSide: [PersonState]
    let enemyTeamSide: [PersonState]
    
    let ourTeam: Team
    let enemyTeam: Team
    
    private(set) var ground: [[Spot]]
    
    //TODO: fix ground logic
    init(ourTeam: Team, enemyTeam: Team) {
        self.ourTeam = ourTeam
        self.enemyTeam = enemyTeam
        
        print(ourTeam)
        print(enemyTeam)
        
        var convertedOur = [PersonState]()
        var convertedEnemy = [PersonState]()
        
        var ground = [[Spot]]()
        //TODO: finish refactoring all of this
        let hack = [["o"],["m"]]
        for (lineIndex, line) in hack.enumerated() {
            var groundLine = [Spot]()
            for (tileIndex, tile) in line.enumerated() {
                switch tile {
                case "e":
                    groundLine.append(.empty)
                case "o":
                    let extraSpace = enemyTeam.members.count - ourTeam.members.count
                    let firstHalf = extraSpace / 2
                    let secondHalf = extraSpace - firstHalf
                    
                    if firstHalf > 0 {
                        for _ in 0...firstHalf - 1 {
                            groundLine.append(.empty)
                        }
                    }
                    
                    convertedOur = ourTeam.members.enumerated().map({ (index, person) in
                        PersonState(person: person,
                                    teamType: .our,
                                    position: (groundLine.count + index + tileIndex, lineIndex))
                    })
                    
                    groundLine.append(contentsOf: convertedOur.map({ Spot.person($0) }))
                    
                    if secondHalf > 0 {
                        for _ in 0...secondHalf - 1 {
                            groundLine.append(.empty)
                        }
                    }
                case "m":
                    let extraSpace = ourTeam.members.count - enemyTeam.members.count
                    let firstHalf = extraSpace / 2
                    let secondHalf = extraSpace - firstHalf
                    
                    if firstHalf > 0 {
                        for _ in 0...firstHalf - 1 {
                            groundLine.append(.empty)
                        }
                    }
                    
                    convertedEnemy = enemyTeam.members.enumerated().map({ (index, person) in
                        PersonState(person: person,
                                    teamType: .enemy,
                                    position: (groundLine.count + index + tileIndex, lineIndex))
                    })
                    
                    groundLine.append(contentsOf: convertedEnemy.map({ Spot.person($0) }))
                    
                    if secondHalf > 0 {
                        for _ in 0...secondHalf - 1 {
                            groundLine.append(.empty)
                        }
                    }
                case "t":
                    groundLine.append(.terain("Tree"))
                default:
                    groundLine.append(.void)
                }
            }
            ground.append(groundLine)
        }
        self.ground = ground
        self.ourTeamSide = convertedOur
        self.enemyTeamSide = convertedEnemy
    }
    
    func fight(stateChanged: @escaping (() -> Void), completion: @escaping ((FightState) -> Void)) {
        
        DispatchQueue.global(qos: .background).async {
            while self.ourTeamSide.isAlive && self.enemyTeamSide.isAlive {
                DispatchQueue.main.sync {
                    self.teamAttack(attackingTeam: self.ourTeamSide, defendingTeam: self.enemyTeamSide)
                    self.teamAttack(attackingTeam: self.enemyTeamSide, defendingTeam: self.ourTeamSide)
                    //TODO: how do I clear these and compared to when they are applied.  To ensure they always get an effect off.
                    self.clearEffects()
                    stateChanged()
                }
                sleep(3)
            }
            
            let wonState = self.ourTeamSide.isAlive
            
            DispatchQueue.main.sync {
                completion(FightState(won: wonState))
            }
        }
    }
    
    func clearEffects() {
        ourTeamSide.forEach({ $0.person.clearEffects() })
        enemyTeamSide.forEach({ $0.person.clearEffects() })
    }
    
    //TODO:s
    //extra affects
    //is melee do anything
    //all
    //phases? Buffs
    //fix speed
    //unit test the math problems to guard againts bad numbers
    //sometimes we don't attack all valid if there are bad targets
    //attack less
    
    //summons
    //buffs
    //arc to support ^
    
    private func teamAttack(attackingTeam: [PersonState], defendingTeam: [PersonState]) {
        attackingTeam.enumerated().forEach({ (index, attackingPersonState) in
            let attackingPerson = attackingPersonState.person
            guard attackingPerson.isAlive else {
                return
            }
            
            print("\(attackingPerson) is attacking \(attackingPerson.attackMove.name)")
            
            let onOur = attackingPersonState.teamType == .our
            let defendingTeam = (onOur ? enemyTeamSide : ourTeamSide).filter({ $0.person.isAlive })
            let attackingTeam = (!onOur ? enemyTeamSide : ourTeamSide).filter({ $0.person.isAlive })
            let defendingTeamIndexs = defendingTeam.map({ $0.position.x })
            
            let attackMove = attackingPerson.attackMove
            let ourEffects = attackingPerson.effectMoves.filter({ $0.our })
            let enemyEffects = attackingPerson.effectMoves.filter({ !$0.our })
            
            //TODO: fix infinate range
            if attackMove.range == -1 {
                return
            }
            
            for ourEffect in ourEffects {
                var nonAffectedPeople = Set(attackingTeam)
                
                for _ in 1...ourEffect.targets {
                    if let effecty = nonAffectedPeople.randomElement() {
                        effecty.person.applyEffect(effect: ourEffect)
                        nonAffectedPeople.remove(effecty)
                    }
                }
            }
            
            for _ in 1...attackMove.targets {
                
                guard let leftMostDefending = defendingTeamIndexs.min(),
                    let rightMostDefending = defendingTeamIndexs.max() else {
                        return
                }
                
                print("Im \(attackingPersonState.position.x)")
                print("left most \(leftMostDefending) right most \(rightMostDefending)")
                
                //Find the closest index to our index if we are on the outside.
                let targetIndex = min(max(attackingPersonState.position.x, leftMostDefending), rightMostDefending)
                
                print("targeting \(targetIndex)")
                
                let minRange = max(targetIndex - attackMove.range, leftMostDefending)
                let maxRange = min(targetIndex + attackMove.range, rightMostDefending)
                
                let targetedIndex = (minRange...maxRange).randomElement() ?? 0
                
                print("updated target \(targetedIndex)")
                                
                let hitEnemies = defendingTeam.filter({ $0.position.x >= targetedIndex - attackMove.size && $0.position.x <= targetIndex + attackMove.size })
                
                //TODO: More math problems ensure this can't be 0
                print("hitting \(hitEnemies)")
                for hitEnemy in hitEnemies {
                    hitEnemy.person.currentHp -= Int(Float(attackMove.damage) * Float(attackingPerson.attack / hitEnemy.person.defense)) + 1
                }
            }
        })
    }
}
