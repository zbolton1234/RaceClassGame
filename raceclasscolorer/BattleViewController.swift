//
//  BattleViewController.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/11/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class BattleViewController: UIViewController {

    @IBOutlet weak var battleFieldView: BattleFieldView!

    let ourTeam: Team
    let encounter: Encounter
    let battleGround: BattleGround
    let completion: ((EncounterResults) -> Void)
    
    init?(coder: NSCoder, ourTeam: Team, encounter: Encounter, completion: @escaping ((EncounterResults) -> Void)) {
        self.ourTeam = ourTeam
        self.encounter = encounter
        self.battleGround = BattleGround(ourTeam: ourTeam,
                                         enemyTeam: encounter.enemyTeam,
                                         groundJson: encounter.groundJson)
        self.completion = completion
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        battleFieldView.updateBattleGround(battleGround: battleGround)
        
        let introView = FancyTextView(text: encounter.introString)
        view.showFullScreen(view: introView)
    }
    
    @IBAction func attack(_ sender: Any) {
        battleGround.fight(stateChanged: {
            self.battleFieldView.updateBattleGround(battleGround: self.battleGround)
        }, completion: { (fightResult) in
            var displayText = fightResult.won ? self.encounter.winString : self.encounter.lossString
            
            var gold = 0
            var people = [Person]()
            var npcs = [String]()
            var cities = [String]()
            var buildings = [String]()
            
            if fightResult.won {
                displayText.append(contentsOf: "\n\nRewards:")
                
                for reward in self.encounter.rewards {
                    switch reward {
                    case .gold(let amount):
                        gold += amount
                        displayText.append("gold:\(amount)")
                    case .person(let race, let pclass):
                        let newPerson = Person(globalRaceId: race, globalClassId: pclass)
                        people.append(newPerson)
                        displayText.append("person:\(newPerson)")
                    case .npc(let id):
                        npcs.append(id)
                        displayText.append("npc:\(id)")
                    case .city(let id):
                        cities.append(id)
                        displayText.append("city:\(id)")
                    case .building(let id):
                        buildings.append(id)
                        displayText.append("building:\(id)")
                    }
                }
            }
            
            let resultView = FancyTextView(text: displayText, dismiss: {
                let encounterResult = EncounterResults(fightState: fightResult,
                                                       gold: gold,
                                                       people: people,
                                                       npcs: npcs,
                                                       buildings: buildings,
                                                       cities: cities)
                
                self.navigationController?.popViewController(animated: true)
                self.completion(encounterResult)
            })
            self.view.showFullScreen(view: resultView)
        })
    }
}
