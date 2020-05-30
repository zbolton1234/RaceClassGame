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
    
    func teamTags() -> [String] {
        return members.flatMap({ $0.personTags })
    }
    
    func teamGoodEvil() -> (goodEvil: GoodEvil, level: AlignmentLevel) {
        let alignmentTotal = members.reduce(0) { (total, person) -> Int in
            if person.goodEvil == .evil {
                return total - person.alignmentLevel.value
            } else {
                return total + person.alignmentLevel.value
            }
        }
        
        if alignmentTotal < 0 {
            return (.evil, AlignmentLevel.levelFor(value: -alignmentTotal))
        } else if alignmentTotal == 0 {
            return (.neither, .neither)
        } else {
            return (.good, AlignmentLevel.levelFor(value: alignmentTotal))
        }
    }
    
    func teamColors() -> [Color: Int] {
        return teamCounts(personValue: { $0.color })
    }
    
    func teamRaces() -> [String: Int] {
        return teamCounts(personValue: { $0.race.raceId })
    }
    
    func teamClass() -> [String: Int] {
        return teamCounts(personValue: { $0.pclass.groupId })
    }
    
    func teamTribe() -> [TribeType: Int] {
        return teamCounts(personValue: { $0.pclass.tribeType })
    }
    
    private func teamCounts<T: Equatable>(personValue: ((Person) -> T)) -> [T: Int] {
        return members.reduce([T: Int]()) { (dictonary, person) -> [T: Int] in
            let value = personValue(person)
            var copy = dictonary
            if dictonary.keys.contains(where: { $0 == value }) {
                copy[value]! += 1
                return copy
            } else {
                //copy.append((value, 1))
                copy[value] = 1
                return copy
            }
        }
    }
}
