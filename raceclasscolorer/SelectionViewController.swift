//
//  SelectionViewController.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 3/5/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController {
    
    private var selectedEnemyTeam: Team?
    private var selectedOurTeam: Team?
    private var selectedCity: City?
    @IBOutlet weak var fontTestLabel: UILabel!
    @IBOutlet weak var worldScrollView: UIScrollView!
    private var testGold = 0
    private var worldImageView = UIImageView(image: UIImage(named: "world"))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fontTestLabel.font = UIFont(name: "YosterIslandReg", size: 20.0)
        
        let testView = FancyTextView()
        view.showFullScreen(view: testView)
        
        worldImageView.isUserInteractionEnabled = true
        worldScrollView.addSubview(worldImageView)
        worldScrollView.minimumZoomScale = 1.0
        worldScrollView.maximumZoomScale = 5.0
        
        for city in loadCities() {
            if city.locked {
                continue
            }
            
            showCityButton(city)
        }
    }
    
    private func showCityButton(_ city: City) {
        let cityButton = UIButton()
        cityButton.translatesAutoresizingMaskIntoConstraints = false
        cityButton.setTitle(city.name, for: .normal)
        cityButton.backgroundColor = .clear
        cityButton.titleLabel?.textColor = .black
        cityButton.tag = loadCities().firstIndex(of: city) ?? -1
        
        worldImageView.addSubview(cityButton)
        
        worldImageView.addConstraints([
            worldImageView.leftAnchor.constraint(equalTo: cityButton.leftAnchor, constant: -city.position.x),
            worldImageView.topAnchor.constraint(equalTo: cityButton.topAnchor, constant: -city.position.y)
        ])
        
        cityButton.addTarget(self,
                             action: #selector(selectedTown),
                             for: .touchUpInside)
        
        let infoButton = UIButton()
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.setTitle("\(city.name) Info", for: .normal)
        infoButton.backgroundColor = .clear
        infoButton.titleLabel?.textColor = .black
        infoButton.tag = loadCities().firstIndex(of: city) ?? -1
        
        worldImageView.addSubview(infoButton)
        
        worldImageView.addConstraints([
            cityButton.leftAnchor.constraint(equalTo: infoButton.leftAnchor),
            cityButton.bottomAnchor.constraint(equalTo: infoButton.topAnchor)
        ])
        
        infoButton.addTarget(self,
                             action: #selector(cityInfo),
                             for: .touchUpInside)
    }
    
    @IBAction func selectedOur(_ sender: UIButton) {
        selectedOurTeam = team(tag: sender.tag)
    }
    
    @objc func selectedTown(_ sender: UIButton) {
        selectedCity = loadCities()[sender.tag]
        performSegue(withIdentifier: "showBattleViewController", sender: nil)
    }
    
    @objc func cityInfo(_ sender: UIButton) {
        selectedCity = loadCities()[sender.tag]
        performSegue(withIdentifier: "showCityViewController", sender: nil)
    }
    
    func team(tag: Int) -> Team {
        var overriddenClass: Class?
        
        switch tag {
        case 0:
            overriddenClass = classWithId(classId: "barb")
        case 1:
            overriddenClass = classWithId(classId: "wizard")
        case 2:
            overriddenClass = classWithId(classId: "cleric")
        case 3:
            overriddenClass = classWithId(classId: "elementalist")
        default:
            break
        }
        
        //TODO: For testing please remember to remove
        let godPerson = Person(preClass: overriddenClass)
        godPerson.currentHp = 1000
        godPerson.currentAttack = 1000
        godPerson.currentDefense = 1000
        
        return Team(members: [godPerson, godPerson, godPerson])
    }
    
    @IBAction func selectedBattle(_ sender: Any) {
        performSegue(withIdentifier: "showBattleViewController", sender: nil)
    }
    
    @IBSegueAction func showCitySegue(_ coder: NSCoder) -> CityViewController? {
        guard let selectedCity = selectedCity else {
            return nil
        }
        
        return CityViewController(coder: coder, city: selectedCity)
    }
    
    @IBSegueAction func showBattleSegue(_ coder: NSCoder) -> BattleViewController? {
        guard let selectedOurTeam = selectedOurTeam,
            let selectedCity = selectedCity else {
            return nil
        }
        
        return BattleViewController(coder: coder,
                                    ourTeam: selectedOurTeam,
                                    encounter: selectedCity.randomEncounter(team: selectedOurTeam), completion: { (results) in
                                        self.testGold += results.gold
                                        self.fontTestLabel.text = "\(self.testGold)"
                                        
                                        for cityId in results.cities {
                                            for city in loadCities() {
                                                if city.id == cityId {
                                                    if city.locked {
                                                        city.locked = false
                                                        self.showCityButton(city)
                                                    }
                                                    break
                                                }
                                            }
                                        }
                                        
                                        for buildingId in results.buildings {
                                            for building in loadBuildings() {
                                                if building.id == buildingId {
                                                    for city in loadCities() {
                                                        if city.id == building.cityId {
                                                            if !city.buildings.contains(where: { $0.id == building.id }) {
                                                                city.buildings.append(Building(buildingJSON: building))
                                                            }
                                                            break
                                                        }
                                                    }
                                                }
                                            }
                                        }
        })
    }
}

extension SelectionViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return worldImageView
    }
}
