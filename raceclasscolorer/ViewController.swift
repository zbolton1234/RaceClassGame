//
//  ViewController.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/11/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var battleFieldView: BattleFieldView!
    
    //TODO: can I fix this?
    var ourTeam: Team!
    var enemyTeam: Team!
    var encounter: Encounter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //need a race/class by id
        let human1 = Person(preRace: allRaces[0], preClass: allClasses[2], preColor: .red)
        let human2 = Person(preRace: allRaces[0], preClass: allClasses[2], preColor: .blue)
        
        let humanTeam = Team(members: [human1, human2])
        //print(human1.totalBuffs(team: humanTeam))
        
        let elf1 = Person(preRace: allRaces[1], preClass: allClasses[2], preColor: .green)
        humanTeam.members.append(elf1)
        //print(human1.totalBuffs(team: humanTeam))
        
        ourTeam = humanTeam
        
        let otherTeam = Team(members: [Person(), Person(), Person()])
        enemyTeam = otherTeam
        
        encounter = Encounter(ourTeam: ourTeam, enemyTeam: enemyTeam)

        battleFieldView.updateBattleGround(battleGround: encounter.battleGround)
    }
    
    @IBAction func attack(_ sender: Any) {
        guard let encounter = encounter else {
            return
        }
        
        let fightResult = encounter.fight()
        if fightResult.won {
            print("We won")
        } else {
            print("We lost")
        }
    }
}
