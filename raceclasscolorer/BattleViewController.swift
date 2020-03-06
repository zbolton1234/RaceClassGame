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
    
    init?(coder: NSCoder, ourTeam: Team, encounter: Encounter) {
        self.ourTeam = ourTeam
        self.encounter = encounter
        self.battleGround = BattleGround(ourTeam: ourTeam, enemyTeam: encounter.enemyTeam)
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        battleFieldView.updateBattleGround(battleGround: battleGround)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func attack(_ sender: Any) {
        battleGround.fight(battleFieldView: battleFieldView) { (fightResult) in
            if fightResult.won {
                print("We won")
            } else {
                print("We lost")
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}
