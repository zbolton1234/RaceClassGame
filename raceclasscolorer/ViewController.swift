//
//  ViewController.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/11/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(Person.generate())
        print(Person.generate())
        print(Person.generate())
        print(Person.generate())
        print(Person.generate())
        print(Person.generate())
        print(Person.generate())
        print(Person.generate())
        print(Person.generate())
        print(Person.generate())
        
        let randomEnounter = Encounter()
        print(randomEnounter.fight(team: [Person.generate()]))
        print(randomEnounter.fight(team: [Person.generate()]))
        print(randomEnounter.fight(team: [Person.generate()]))
        print(randomEnounter.fight(team: [Person.generate()]))
        print(randomEnounter.fight(team: [Person.generate()]))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

