//
//  Person.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/11/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import GameKit
import UIKit

let allRaces = loadRaces()
let allClasses = loadClasses()
let anyConstant = "any"

//Accepts 4 different race types of values raceId "elf", tribeType "civilized", id "forsestElf", any "any" to get the correct Race from the list
//Accepts 4 different class types of values groupId "magic", tribeType "civilized", id "wizard", any "any" to get the correct Race from the list
//TODO: to much of this is copy pasted.  Problem is there are strange edge cases in the pasted parts
func raceClass(globalRaceId: String, globalClassId: String) -> (race: Race?, class: Class?) {
    if globalRaceId == anyConstant && globalClassId == anyConstant {
        //If any/any then we just select a random allowed values for this
        let randomRace = allRaces.randomElement()!
        let randomClass = allClasses(ofClassType: randomRace.tribeType).randomElement()
        
        return (randomRace, randomClass)
    } else if globalRaceId == anyConstant {
        //If race is any then we need to know what class was selected and base the race off that value
        var preselectedClass: Class?
        
        if let tribeType = TribeType(rawValue: globalClassId) {
            preselectedClass = allClassesForceType(ofClassType: tribeType).randomElement()
        }
        
        let usingRaceId = allClasses(ofGroupId: globalClassId)
        
        if usingRaceId.count > 0 {
            preselectedClass = usingRaceId.randomElement()
        }
        
        let usingId = allClasses(ofId: globalClassId)
        
        if usingId.count > 0 {
            preselectedClass = usingId.randomElement()
        }
        
        if let preselectedClass = preselectedClass {
            var allowedRace: Race?
            
            if globalRaceId == anyConstant {
                allowedRace = allRaces(ofClassType: preselectedClass.tribeType).randomElement()
            }
            
            if let raceTribeType = TribeType(rawValue: globalRaceId) {
                if invalidTribeTypes(classTribeType: preselectedClass.tribeType, raceTribeType: raceTribeType) {
                    print("invalid race selected \(globalRaceId) \(globalClassId)")
                    allowedRace = allRaces(ofRaceType: preselectedClass.tribeType).randomElement()
                } else {
                    allowedRace = allRacesForceType(ofRaceType: raceTribeType).randomElement()
                }
            }
            
            let usingGroupId = allRaces(ofRaceId: globalRaceId)
            
            if usingGroupId.count > 0 {
                let purposedRace = usingGroupId.randomElement()!
                
                if invalidTribeTypes(classTribeType: preselectedClass.tribeType, raceTribeType: purposedRace.tribeType) {
                    print("invalid race selected \(globalRaceId) \(globalClassId)")
                    allowedRace = allRaces(ofRaceType: preselectedClass.tribeType).randomElement()
                } else {
                    allowedRace = purposedRace
                }
            }
            
            let usingId = allRaces(ofId: globalRaceId)
            
            if usingId.count > 0 {
                let purposedRace = usingId.randomElement()!
                
                if invalidTribeTypes(classTribeType: preselectedClass.tribeType, raceTribeType: purposedRace.tribeType) {
                    print("invalid race selected \(globalRaceId) \(globalClassId)")
                    allowedRace = allRaces(ofRaceType: preselectedClass.tribeType).randomElement()
                } else {
                    allowedRace = purposedRace
                }
            }
            
            return (allowedRace, preselectedClass)
        }
    } else {
        //Otherwise we can always find out the race and base the class off that
        var preselectedRace: Race?
        
        if let tribeType = TribeType(rawValue: globalRaceId) {
            preselectedRace = allRacesForceType(ofRaceType: tribeType).randomElement()
        }
        
        let usingRaceId = allRaces(ofRaceId: globalRaceId)
        
        if usingRaceId.count > 0 {
            preselectedRace = usingRaceId.randomElement()
        }
        
        let usingId = allRaces(ofId: globalRaceId)
        
        if usingId.count > 0 {
            preselectedRace = usingId.randomElement()
        }
        
        if let preselectedRace = preselectedRace {
            var allowedClass: Class?
            
            if globalClassId == anyConstant {
                allowedClass = allClasses(ofClassType: preselectedRace.tribeType).randomElement()
            }
            
            if let classTribeType = TribeType(rawValue: globalClassId) {
                if invalidTribeTypes(classTribeType: classTribeType, raceTribeType: preselectedRace.tribeType) {
                    print("invalid class selected \(globalRaceId) \(globalClassId)")
                    allowedClass = allClasses(ofClassType: preselectedRace.tribeType).randomElement()
                } else {
                    allowedClass = allClassesForceType(ofClassType: classTribeType).randomElement()
                }
            }
            
            let usingGroupId = allClasses(ofGroupId: globalClassId)
            
            if usingGroupId.count > 0 {
                let purposedClass = usingGroupId.randomElement()!
                
                if invalidTribeTypes(classTribeType: purposedClass.tribeType, raceTribeType: preselectedRace.tribeType) {
                    print("invalid class selected \(globalRaceId) \(globalClassId)")
                    allowedClass = allClasses(ofClassType: preselectedRace.tribeType).randomElement()
                } else {
                    allowedClass = purposedClass
                }
            }
            
            let usingId = allClasses(ofId: globalClassId)
            
            if usingId.count > 0 {
                let purposedClass = usingId.randomElement()!
                
                if invalidTribeTypes(classTribeType: purposedClass.tribeType, raceTribeType: preselectedRace.tribeType) {
                    print("invalid class selected \(globalRaceId) \(globalClassId)")
                    allowedClass = allClasses(ofClassType: preselectedRace.tribeType).randomElement()
                } else {
                    allowedClass = purposedClass
                }
            }
            
            return (preselectedRace, allowedClass)
        }
    }
    
    print("everything failed \(globalRaceId) \(globalClassId)")
    return (nil, nil)
}

func invalidTribeTypes(classTribeType: TribeType, raceTribeType: TribeType) -> Bool {
    //Currently the only invalid combo is wild race with civ class aka a Gnoll Wizard
    return classTribeType == .civilized && raceTribeType == .wild
}

func allClassesForceType(ofClassType: TribeType) -> [Class] {
    return allClasses.filter({ $0.tribeType == ofClassType })
}

func allRacesForceType(ofRaceType: TribeType) -> [Race] {
    return allRaces.filter({ $0.tribeType == ofRaceType })
}

func allClasses(ofClassType: TribeType) -> [Class] {
    if ofClassType == .civilized {
        return allClasses
    }
    
    return allClasses.filter({ $0.tribeType == ofClassType })
}

func allRaces(ofClassType: TribeType) -> [Race] {
    if ofClassType == .wild {
        return allRaces
    }
    
    return allRaces.filter({ $0.tribeType == ofClassType })
}

func allRaces(ofRaceType: TribeType) -> [Race] {
    if ofRaceType == .civilized {
        return allRaces
    }
    
    return allRaces.filter({ $0.tribeType == ofRaceType })
}

func allRaceIds() -> [String] {
    return Array(Set(allRaces.map({ $0.raceId })))
}

func allRaces(ofRaceId: String) -> [Race] {
    return allRaces.filter({ $0.raceId == ofRaceId })
}

func allRaces(ofId: String) -> [Race] {
    return allRaces.filter({ $0.id == ofId })
}

func allClasses(ofGroupId: String) -> [Class] {
    return allClasses.filter({ $0.groupId == ofGroupId })
}

func allClasses(ofId: String) -> [Class] {
    return allClasses.filter({ $0.id == ofId })
}

func classWithId(classId: String) -> Class? {
    return allClasses.first(where: { $0.id == classId })
}

let random = GKRandomSource()
let randomPersentage = GKGaussianDistribution(randomSource: random, mean: 100, deviation: 20)

enum TribeType: String, Decodable {
    case civilized
    case wild
    case custom
}

struct Race: Decodable {
    let name: String
    let raceId: String
    let id: String
    let tribeType: TribeType
    let description: String
    let buffs: [Buff]
    let debuffs: [Buff]
    let extraTags: [String]
    let animals: [String]
    let bounusSpeed: Int
    let alignmentLevel: AlignmentLevel
    let goodEvil: GoodEvil
    
    func tags() -> [String] {
        var allTags = [String]()

        allTags.append(raceId)
        allTags.append(id)
        
        return allTags
    }
}

struct Class: Decodable {
    let name: String
    let groupId: String
    let id: String
    let tribeType: TribeType
    let description: String
    let hp: Int
    let attack: Int
    let defense: Int
    let speed: Int
    let attackMove: Attack
    let alignmentLevel: AlignmentLevel
    let goodEvil: GoodEvil
    let buffs: [Buff]
    let debuffs: [Buff]
    let extraTags: [String]
    
    func tags() -> [String] {
        var allTags = [String]()

        allTags.append(groupId)
        allTags.append(id)
        allTags.append(tribeType.rawValue)
        
        return allTags
    }
}

struct Buff: Decodable {
    ///The condiition that needs to be true to trigger.
    let tag: String
    ///The amount of the buff.  Should always be positive.
    let amount: Int
    ///Acts as a not of the tag.  tag = "orc" and all others will buff all races that are not orc
    let allOthers: Bool
}

struct Attack: Decodable {
    let name: String
    //TODO: extra affect
    let targets: Int
    let range: Int
    let isMelee: Bool
    let size: Int
    let damage: Int
}

enum Color: Int, CaseIterable {
    case red
    case blue
    case green
    case white
    case black
}

enum GoodEvil: String, Decodable {
    case good
    case evil
    case neither
}

enum AlignmentLevel: String, Decodable {
    case total //Should only be used on class so Litch Angels are evil and Cleric Orcs are good
    case mega
    case major
    case minor
    case neither
    
    var value: Int {
        switch self {
        case .total:
            return 1000
        case .mega:
            return 10
        case .major:
            return 2
        case .minor:
            return 1
        case .neither:
            return 0
        }
    }
    
    //Rounds off to major so one one unit can't over power a team for alignment
    static func levelFor(value: Int) -> AlignmentLevel {
        if value == 0 {
            return .neither
        } else if value == 1 {
            return .minor
        } else {
            return .major
        }
    }
}

class Person: Battler, CustomStringConvertible {
    let id = UUID()
    let race: Race
    let pclass: Class
    let color: Color
    let hp: Int
    let attack: Int
    let defense: Int
    let speed: Int
    let alignmentLevel: AlignmentLevel
    let goodEvil: GoodEvil
    //TODO: Need a real object for this :)
    let buffs: [Buff]
    let debuffs: [Buff]
    let personTags: [String]
    
    let attackMove: Attack
    
    var currentHp: Int
    var currentAttack: Int
    var currentDefense: Int
    var currentSpeed: Int
    
    convenience init(globalRaceId: String, globalClassId: String) {
        let selectedPerson = raceClass(globalRaceId: globalRaceId, globalClassId: globalClassId)
        
        self.init(preRace: selectedPerson.race, preClass: selectedPerson.class)
    }
    
    //TODO: made debug only or move to test???
    class func testDummy() -> Person {
        let dummy = Person()
        
        dummy.currentHp = 1
        dummy.currentAttack = 0
        dummy.currentDefense = 0
        dummy.currentSpeed = 0
        
        return dummy
    }
    
    init(preRace: Race? = nil, preClass: Class? = nil, preColor: Color? = nil) {
        let selectedRace: Race
        let selectedClass: Class
        let selectedColor: Color
        
        if let preRace = preRace {
            selectedRace = preRace
        } else {
            let randomType = allRaceIds().randomElement()!
            selectedRace = allRaces(ofRaceId: randomType).randomElement()!
        }
        
        if let preClass = preClass {
            selectedClass = preClass
        } else {
            let validClasses: [Class]
            
            if selectedRace.tribeType == .wild {
                validClasses = allClasses(ofClassType: .wild)
            } else {
                validClasses = allClasses
            }
            
            selectedClass = validClasses.randomElement()!
        }
        
        if let preColor = preColor {
            selectedColor = preColor
        } else {
            selectedColor = Color.allCases.randomElement()!
        }
        
        race = selectedRace
        pclass = selectedClass
        color = selectedColor
        
        //TODO: math!  need to ensure we never get a 0 here
        hp = Int(Double(pclass.hp) * (Double(randomPersentage.nextInt()) / 100.0)) + 1
        attack = Int(Double(pclass.attack) * (Double(randomPersentage.nextInt()) / 100.0)) + 1
        defense = Int(Double(pclass.defense) * (Double(randomPersentage.nextInt()) / 100.0)) + 1
        speed = pclass.speed + race.bounusSpeed
        
        currentHp = hp
        currentAttack = attack
        currentDefense = defense
        currentSpeed = speed
        
        attackMove = pclass.attackMove
        
        buffs = race.buffs + pclass.buffs
        debuffs = race.debuffs + pclass.debuffs
        
        let raceValue = race.goodEvil == .evil ? -race.alignmentLevel.value : race.alignmentLevel.value
        let classValue = pclass.goodEvil == .evil ? -pclass.alignmentLevel.value : pclass.alignmentLevel.value
        let personAlignmentValue = raceValue + classValue
        
        if personAlignmentValue == 0 {
            goodEvil = .neither
            alignmentLevel = .neither
        } else if personAlignmentValue < 0 {
            goodEvil = .evil
            alignmentLevel = AlignmentLevel.levelFor(value: -personAlignmentValue)
        } else {
            goodEvil = .good
            alignmentLevel = AlignmentLevel.levelFor(value: personAlignmentValue)
        }
        
        var allTags = [String]()
        
        allTags.append(goodEvil.rawValue)
        allTags.append(contentsOf: pclass.tags())
        allTags.append(contentsOf: race.tags())
        
        personTags = allTags
    }
    
    var description: String {
        return "race: \(race.id) class: \(pclass.id) color: \(color)"
    }
    
    var isAlive: Bool {
        return currentHp > 0
    }
    
    func totalBuffs(team: Team) -> Int {
        return team.members.reduce(0) { (total, otherPerson) -> Int in
            if self.id == otherPerson.id {
                return total
            }
            
            let buffs = otherPerson.buffs.reduce(0) { (buffTotal, buff) -> Int in
                return total + self.buffAmount(buff: buff)
            }
            
            let debuffs = otherPerson.debuffs.reduce(0) { (buffTotal, buff) -> Int in
                return total + self.buffAmount(buff: buff)
            }
            
            return total + buffs + debuffs
        }
    }
    
    private func buffAmount(buff: Buff) -> Int {
        var applyBuff = personTags.contains(buff.tag)
        
        if buff.allOthers {
            applyBuff = !applyBuff
        }
        
        if applyBuff {
            return buff.amount
        }
        
        return 0
    }
    
    func personImage() -> UIImage {
        return imageFromString(string: NSString(string: race.name))
    }
    
    private func imageFromString(string: NSString) -> UIImage {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        string.draw(in: CGRect(x: 0, y: 0, width: 100, height: 100), withAttributes: nil)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
