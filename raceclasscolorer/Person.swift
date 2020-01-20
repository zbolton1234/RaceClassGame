//
//  Person.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/11/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

let allRaces = loadRaces()
let allClasses = loadClasses()

struct Person: CustomStringConvertible {
    let race: Race
    let pclass: Class
    let color: Color
    
    static func generate(preRace: Race? = nil, preClass: Class? = nil, preColor: Color? = nil) -> Person {
        let selectedRace: Race
        let selectedClass: Class
        let selectedColor: Color
        
        if let preRace = preRace {
            selectedRace = preRace
        } else {
            selectedRace = allRaces.randomElement()!
        }
        
        if let preClass = preClass {
            selectedClass = preClass
        } else {
            selectedClass = allClasses.randomElement()!
        }
        
        if let preColor = preColor {
            selectedColor = preColor
        } else {
            selectedColor = Color.allCases.randomElement()!
        }
        
        return Person(race: selectedRace, pclass: selectedClass, color: selectedColor)
    }
    
    var description: String {
        return "race: \(race) class: \(pclass) color: \(color)"
    }
}

enum TribeType: String, Decodable {
    case civilized = "civilized"
}

struct Race: Decodable {
    let name: String
    let raceId: String
    let id: String
    let tribeType: TribeType
    let description: String
    let friendlyRaces: [String]
    let animals: [String]
    let hatedRaces: [String]
}

struct Class: Decodable {
    let name: String
    let groupId: String
    let id: String
    let tribeType: TribeType
    let description: String
}

enum Color: Int, CaseIterable {
    case red
    case blue
    case green
}
