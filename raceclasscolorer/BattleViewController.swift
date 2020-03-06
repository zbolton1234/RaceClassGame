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
    let enemyTeam: Team
    let encounter: Encounter
    
    init?(coder: NSCoder, ourTeam: Team, enemyTeam: Team) {
        self.ourTeam = ourTeam
        self.enemyTeam = enemyTeam
        encounter = Encounter(ourTeam: ourTeam, enemyTeam: enemyTeam)
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        battleFieldView.updateBattleGround(battleGround: encounter.battleGround)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func attack(_ sender: Any) {
        encounter.fight(battleFieldView: battleFieldView) { (fightResult) in
            if fightResult.won {
                print("We won")
            } else {
                print("We lost")
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}
