//
//  BattleFieldView.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 2/28/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class BattleFieldView: UIView {
    
    //TODO: Current logic forces 6 tall is that bad?
    @IBOutlet private var stackViews: [UIStackView]!

    private var currentBattleGround: BattleGround?
    
    func updateBattleGround(battleGround: BattleGround) {
        currentBattleGround = battleGround

        //TODO: Make the views off the model not this
        stackViews.enumerated().forEach({ (index, stackView) in
            stackView.show(spots: battleGround.ground[index])
        })
    }
}

extension UIStackView {
    //TODO: make combo view and show BattleGround?
    func show(spots: [Spot]) {
        arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        spots.forEach({ (spot) in
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 10)
            
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
  
                label.text = "\(personInSpot.person.race.name)\n\(personInSpot.person.pclass.name)\n\(personInSpot.person.color) \(personInSpot.person.currentHp)"//"\n\(personInSpot.hp) \(personInSpot.attack) \(personInSpot.defense)\n\(personInSpot.totalBuffs(team: team))"
            }
            
            addArrangedSubview(label)
        })
    }
}
