//
//  ViewController.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/11/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var enemyTeamView: UIStackView!
    @IBOutlet weak var ourTeamView: UIStackView!
    
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

        ourTeamView.show(spots: encounter.battleGround.ourTeamSide, team: humanTeam)
        enemyTeamView.show(spots: encounter.battleGround.enemyTeamSide, team: otherTeam)
    }
    
    @IBAction func attack(_ sender: Any) {
        guard let encounter = encounter else {
            return
        }
        
        encounter.fight()
    }
}

extension UIStackView {
    //TODO: make combo view and show BattleGround?
    func show(spots: [Spot], team: Team) {
        arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        spots.forEach({ (spot) in
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            
            switch spot {
            case .void:
                label.backgroundColor = .black
                label.text = "v"
            case .empty:
                label.backgroundColor = .lightGray
                label.text = "e"
            case .terain(let name):
                label.backgroundColor = .lightGray
                label.text = name
            case .person(let personInSpot):
                label.backgroundColor = .lightGray
                
                label.text = "\(personInSpot.race.name)\n\(personInSpot.pclass.name)\n\(personInSpot.color)\n\(personInSpot.hp) \(personInSpot.attack) \(personInSpot.defense)\n\(personInSpot.totalBuffs(team: team))"
            }
            
            addArrangedSubview(label)
        })
    }
}
