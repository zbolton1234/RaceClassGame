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

class PersonState {
    let person: Person
    let teamType: TeamType
    var position: Position
    
    init(person: Person, teamType: TeamType, position: Position) {
        self.person = person
        self.teamType = teamType
        self.position = position
    }
    
    func distance(otherPerson: PersonState) -> Double {
        let ourPosition = position
        let otherPosition = otherPerson.position
        
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
        
        print(ourTeam)
        print(enemyTeam)
        
        var convertedOur = [PersonState]()
        var convertedEnemy = [PersonState]()
        
        //TODO: are all my grounds equal size???
        let teamWidth = groundJson.ground[1].count - 2
        
        var ground = [[Spot]]()
        for (lineIndex, line) in groundJson.ground.enumerated() {
            var groundLine = [Spot]()
            for (tileIndex, tile) in line.enumerated() {
                switch tile {
                case "e":
                    groundLine.append(.empty)
                case "o":
                    convertedOur = ourTeam.members.enumerated().map({ (index, person) in
                        PersonState(person: person,
                                    teamType: .our,
                                    position: (index + tileIndex, lineIndex))
                    })
                    
                    let extraSpace = teamWidth - convertedOur.count
                    let firstHalf = extraSpace / 2
                    let secondHalf = extraSpace - firstHalf
                    
                    if firstHalf > 0 {
                        for _ in 0...firstHalf - 1 {
                            groundLine.append(.empty)
                        }
                    }
                    groundLine.append(contentsOf: convertedOur.map({ Spot.person($0) }))
                    if secondHalf > 0 {
                        for _ in 0...secondHalf - 1 {
                            groundLine.append(.empty)
                        }
                    }
                case "m":
                    convertedEnemy = enemyTeam.members.enumerated().map({ (index, person) in
                        PersonState(person: person,
                                    teamType: .enemy,
                                    position: (index + tileIndex, lineIndex))
                    })
                    
                    let extraSpace = teamWidth - convertedEnemy.count
                    let firstHalf = extraSpace / 2
                    let secondHalf = extraSpace - firstHalf
                    
                    if firstHalf > 0 {
                        for _ in 0...firstHalf - 1 {
                            groundLine.append(.empty)
                        }
                    }
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
            while self.ourTeam.isAlive && self.enemyTeam.isAlive {
                DispatchQueue.main.sync {
                    self.teamAttack(attackingTeam: self.ourTeamSide, defendingTeam: self.enemyTeamSide)
                    self.teamAttack(attackingTeam: self.enemyTeamSide, defendingTeam: self.ourTeamSide)
                    stateChanged()
                }
                sleep(3)
            }
            
            let wonState = self.ourTeam.isAlive
            
            DispatchQueue.main.sync {
                completion(FightState(won: wonState))
            }
        }
    }
    
    //TODO:s
    //aoe
    //extra affects
    //is melee do anything
    //dead bodies
    //all
    //phases?  like all move then all attack?
    //speed
    //unit test the math problems to guard againts bad numbers
    //sometimes we don't attack all valid if there are bad targets
    
    //summons
    //buffs
    //arc to support ^
    
    private func teamAttack(attackingTeam: [PersonState], defendingTeam: [PersonState]) {
        attackingTeam.enumerated().forEach({ (index, attackingPersonState) in
            let attackingPerson = attackingPersonState.person
            guard attackingPerson.currentHp > 0 else {
                return
            }
            
            print("\(attackingPerson.id) is attacking \(attackingPerson.attackMove.name)")
            
            let onOur = attackingPersonState.teamType == .our
            let defendingTeam = onOur ? enemyTeamSide : ourTeamSide
            let attackMove = attackingPerson.attackMove
            var targets = closestEnemy(attackingPerson: attackingPersonState,
                                       numberOfTargets: attackMove.targets,
                                       onlySee: true)
            
            guard let closestTarget = closestEnemy(attackingPerson: attackingPersonState,
                                             numberOfTargets: 1,
                                             onlySee: false).first else {
                                                return
            }

            //If our closest target is out of range or we can't hit it move closer.  Might not be the best spot to move to but not sure how to fix that yet.
            if (closestTarget.distance >= Double(attackMove.range) + 1.0 || sightBlocked(attackingPosition: attackingPersonState.position, defendingPosition: closestTarget.person.position) && attackMove.range != -1) {
                smartMove(personState: attackingPersonState, goalPosition: closestTarget.person.position)
                //we moved need to update the states as we might be in range now
                targets = closestEnemy(attackingPerson: attackingPersonState,
                                       numberOfTargets: attackMove.targets,
                                       onlySee: true)
            }

            for target in targets {
                //Check range and visibility
                if target.distance <= Double(attackMove.range) + 1.0 || attackMove.range == -1 {
                    //TODO: More math problems ensure this can't be 0
                    target.person.person.currentHp -= Int(Float(attackMove.damage) * attackingPerson.attackModifer(enemy: target.person.person)) + 1
                    
                    //If AOE then attack others near by
                    if attackMove.size > 1 {
                        for enemy in defendingTeam {
                            if target.person.distance(otherPerson: enemy) <= Double(attackMove.size) &&
                                !sightBlocked(attackingPosition: target.person.position, defendingPosition: enemy.position) {
                                enemy.person.currentHp -= Int(Float(attackMove.damage) * attackingPerson.attackModifer(enemy: enemy.person)) + 1
                            }
                        }
                    }
                }
            }
        })
    }
}

//MARK: State Helpers
extension BattleGround {
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
    
    typealias Distance = (distance: Double, person: PersonState)
    private func closestEnemy(attackingPerson: PersonState, numberOfTargets: Int, onlySee: Bool) -> [Distance] {
        let onOur = attackingPerson.teamType == .our
        let defendingTeam = onOur ? enemyTeamSide : ourTeamSide
        
        let distances = defendingTeam.compactMap({ (defender) -> Distance? in
            let blocked = sightBlocked(attackingPosition: attackingPerson.position, defendingPosition: defender.position)
            
            guard defender.person.currentHp > 0, (numberOfTargets == -1 || !(blocked && onlySee)) else {
                return nil
            }
            
            let distance = attackingPerson.distance(otherPerson: defender)
            return (distance, defender)
        }).sorted(by: { $0.distance < $1.distance })
        
        if numberOfTargets == -1 {
            return distances
        } else {
            return distances.count > numberOfTargets ? Array(distances[0...(numberOfTargets - 1)]) : distances
        }
    }
}

// MARK: Mutable Helpers
extension BattleGround {
    private func move(person: PersonState, position: Position) {
        guard spotEmpty(position: position) else {
            return
        }

        ground[position.y][position.x] = .person(person)

        let oldPosition = person.position
        ground[oldPosition.y][oldPosition.x] = .empty

        person.position = position
    }
    
    private func smartMove(personState: PersonState, goalPosition: Position) {
        let startPosition = personState.position
        
        if personState.person.currentSpeed == 0 {
            return
        }
        
        var openList = [PositionNode]()
        var closedList = [PositionNode]()
        
        let startNode = PositionNode(postion: startPosition)
        let endNode = PositionNode(postion: goalPosition)
        
        openList.append(startNode)
        
        while openList.count > 0 {
            var currentNode = openList.first!
            var currentIndex = 0
            
            for (index, item) in openList.enumerated() {
                if item.fScore < currentNode.fScore {
                    currentNode = item
                    currentIndex = index
                }
            }
            
            openList.remove(at: currentIndex)
            closedList.append(currentNode)
            
            if currentNode == endNode {
                if let nextNode = currentNode.nextNode(startNode: startNode,
                                                       endNode: endNode,
                                                       depth: 0/*personState.person.currentSpeed*/) {
                    move(person: personState, position: nextNode.position)
                }
                
                print("we got it")
                return
            }
            
            let validSpots = validNearSpots(position: currentNode.position).map({ PositionNode(postion: $0) })
            
            for validSpot in validSpots {
                if closedList.contains(validSpot) {
                    continue
                }
                
                validSpot.parent = currentNode
                validSpot.gScore = currentNode.gScore + 1
                validSpot.hScore = distanceHisc(position1: validSpot.position, position2: endNode.position)
                
                for openNode in openList {
                    if validSpot == openNode && validSpot.gScore > openNode.gScore {
                        continue
                    }
                }
                
                openList.append(validSpot)
            }
        }
        
        print("Did not find it")
    }
    
    private func spotValidPath(position: Position) -> Bool {
        switch ground[position.y][position.x] {
        case .terain(_):
            return false
        case .void:
            return false
        default:
            return true
        }
    }
    
    private func spotEmpty(position: Position) -> Bool {
        //TODO: do this better
        if case .person(let personInSpot) = ground[position.y][position.x] {
            if personInSpot.person.currentHp <= 0 {
                ground[position.y][position.x] = .empty
            }
        }
        
        guard case .empty = ground[position.y][position.x] else {
            return false
        }
        
        return true
    }
    
    private func validNearSpots(position: Position) -> [Position] {
        var spots = [Position]()
        
        for xChange in -1...1 {
            for yChange in -1...1 {
                let possiblePosition = Position(x: position.x + xChange, y: position.y + yChange)
                
                let validX = possiblePosition.x >= 0 && possiblePosition.x < ground.first!.count
                let validY = possiblePosition.y >= 0 && possiblePosition.y < ground.count
                let isStartSpot = xChange == 0 && yChange == 0
                if validX && validY && !isStartSpot && spotValidPath(position: possiblePosition) {
                    spots.append(possiblePosition)
                }
            }
        }
        
        return spots
    }
}

private class PositionNode: Hashable {
    let position: Position
    var parent: PositionNode?
    
    var gScore = 0.0
    var hScore = 0.0
    var fScore: Double {
        return gScore + hScore
    }
    
    init(postion: Position) {
        self.position = postion
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(position.x)
        hasher.combine(position.y)
    }
    
    //me (startnode) -> empty -> enemy (endnode)
    
    //TODO: putting a hard max of ... should fix or make better
    func nextNode(startNode: PositionNode, endNode: PositionNode, depth: Int) -> PositionNode? {
        var lookingAt: PositionNode?
        
        if let grandParent = self.parent?.parent?.parent, depth == 2 {
            lookingAt = grandParent
        } else if let grandParent = self.parent?.parent, depth >= 1 {
            lookingAt = grandParent
        } else {
            lookingAt = self.parent
        }
        
        if lookingAt == startNode {
            //We want to move more then 1 but did not move at all so need to try a shorter depth
            if self == endNode && depth > 0 {
                return self.nextNode(startNode: startNode, endNode: endNode, depth: depth - 1)
            }
            
            return self
        } else {
            return parent?.nextNode(startNode: startNode, endNode: endNode, depth: depth)
        }
    }
}

private func ==(lhs: PositionNode, rhs: PositionNode) -> Bool {
    return lhs.position == rhs.position
}
