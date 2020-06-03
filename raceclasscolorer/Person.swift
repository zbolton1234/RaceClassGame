//
//  Person.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/11/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import GameKit
import UIKit

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
    let effectMoves: [Effect]
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

class Effect: Decodable, Hashable {
    let id = UUID()
    let name: String
    let stat: Stat
    let amount: Int
    let targets: Int
    var length: Int
    let our: Bool
    
    static func == (lhs: Effect, rhs: Effect) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum Stat: String, Decodable {
    case health
    case attack
    case defense
    case multi
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

class BattlePerson: Person {
    var currentHp: Int
    var currentAttack: Int
    var currentDefense: Int
    var currentSpeed: Int
    
    var extraAttacks = 0
    var regen = 0
    
    private var currentEffects = Set<Effect>()
    
    //TODO: made debug only or move to test???
//    class func testDummy() -> BattlePerson {
//        let dummy = BattlePerson()
//
//        dummy.currentHp = 1
//        dummy.currentAttack = 0
//        dummy.currentDefense = 0
//        dummy.currentSpeed = 0
//
//        return dummy
//    }
    
    override init(person: Person) {
        currentHp = 0
        currentAttack = 0
        currentDefense = 0
        currentSpeed = 0
        
        super.init(person: person)
        
        currentHp = health
        currentAttack = attack
        currentDefense = defense
        currentSpeed = speed
    }
    
    required convenience init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isAlive: Bool {
        return currentHp > 0
    }
    
    func applyEffect(effect: Effect) {
        currentEffects.insert(effect)
        
        switch effect.stat {
        case .health:
            currentHp += effect.amount
        case .attack:
            currentAttack += effect.amount
        case .defense:
            currentDefense += effect.amount
        case .multi:
            //uuuuummmmm
            break
        }
    }
    
    func clearEffects() {
        for effect in currentEffects {
            effect.length -= 1
            
            if effect.length <= 0 {
                switch effect.stat {
                case .health:
                    //uuuuummmmm
                    break
                case .attack:
                    currentAttack -= effect.amount
                case .defense:
                    currentDefense -= effect.amount
                case .multi:
                    //uuuuummmmm
                    break
                }
                
                currentEffects.remove(effect)
            }
        }
    }
}

class Person: NSObject, NSCoding {
    private let id: UUID
    let race: Race
    let pclass: Class
    let color: Color
    let health: Int
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
    let effectMoves: [Effect]
    
    convenience init(globalRaceId: String, globalClassId: String, preselectedColor: Int? = nil, preAttack: Int? = nil, preDefense: Int? = nil, preHealth: Int? = nil) {
        let selectedPerson = raceClass(globalRaceId: globalRaceId, globalClassId: globalClassId)
        
        let color: Color?
        
        if let preselectedColor = preselectedColor {
            color = Color(rawValue: preselectedColor)
        } else {
            color = nil
        }
        
        self.init(preRace: selectedPerson.race, preClass: selectedPerson.class, preColor: color, preAttack: preAttack, preDefense: preDefense, preHealth: preHealth)
    }
    
    init(person: Person) {
        id = person.id
        race = person.race
        pclass = person.pclass
        color = person.color
        health = person.health
        attack = person.attack
        defense = person.defense
        speed = person.speed
        alignmentLevel = person.alignmentLevel
        goodEvil = person.goodEvil
        buffs = person.buffs
        debuffs = person.debuffs
        personTags = person.personTags
        attackMove = person.attackMove
        effectMoves = person.effectMoves
    }
    
    init(preRace: Race? = nil, preClass: Class? = nil, preColor: Color? = nil, preAttack: Int? = nil, preDefense: Int? = nil, preHealth: Int? = nil) {
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
        if let preHealth = preHealth {
            health = preHealth
        } else {
            health = Int(Double(pclass.hp) * (Double(randomPersentage.nextInt()) / 100.0)) + 1
        }
        
        if let preAttack = preAttack {
            attack = preAttack
        } else {
            attack = Int(Double(pclass.attack) * (Double(randomPersentage.nextInt()) / 100.0)) + 1
        }
        
        if let preDefense = preDefense {
            defense = preDefense
        } else {
            defense = Int(Double(pclass.defense) * (Double(randomPersentage.nextInt()) / 100.0)) + 1
        }
        
        speed = pclass.speed + race.bounusSpeed
        
        attackMove = pclass.attackMove
        effectMoves = pclass.effectMoves
        
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
        
        id = UUID()
    }
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }
    
//    override func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
    
    override var description: String {
        return "race: \(race.id) class: \(pclass.id) color: \(color)"
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

    //MARK: NSCoding
    struct PropertyKey {
        static let race = "race"
        static let pclass = "pclass"
        static let color = "color"
        
        static let attack = "attack"
        static let defense = "defense"
        static let health = "health"
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(race.id, forKey: PropertyKey.race)
        coder.encode(pclass.id, forKey: PropertyKey.pclass)
        coder.encode(color.rawValue, forKey: PropertyKey.color)
        
        coder.encode(attack, forKey: PropertyKey.attack)
        coder.encode(defense, forKey: PropertyKey.defense)
        coder.encode(health, forKey: PropertyKey.health)
    }
    
    required convenience init?(coder: NSCoder) {
        guard let raceId = coder.decodeObject(forKey: PropertyKey.race) as? String,
            let classId = coder.decodeObject(forKey: PropertyKey.pclass) as? String else {
                return nil
        }
        
        let colorRaw = coder.decodeInteger(forKey: PropertyKey.color)
        
        let attack = coder.decodeInteger(forKey: PropertyKey.attack)
        let defense = coder.decodeInteger(forKey: PropertyKey.defense)
        let health = coder.decodeInteger(forKey: PropertyKey.health)
        
        self.init(globalRaceId: raceId, globalClassId: classId, preselectedColor: colorRaw, preAttack: attack, preDefense: defense, preHealth: health)
    }
}
