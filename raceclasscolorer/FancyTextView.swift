//
//  FancyTextView.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 4/13/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class FancyTextView: UIView {

    let label: UILabel
    private var dismiss: (() -> Void)?
    
    convenience init(text: String, dismiss: (() -> Void)? = nil) {
        self.init(frame: CGRect.zero)
        
        label.text = text
        self.dismiss = dismiss
    }
    
    override init(frame: CGRect) {
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        label.font = UIFont(name: "YosterIslandReg", size: 20.0)
        label.textColor = .white
        label.backgroundColor = UIColor(red: 54.0/255.0,
                                        green: 89.0/255.0,
                                        blue: 74.0/255.0,
                                        alpha: 1.0)
        
        let labelBackground = UIView()
        labelBackground.translatesAutoresizingMaskIntoConstraints = false
        labelBackground.backgroundColor = label.backgroundColor
        
        labelBackground.layer.cornerRadius = 15
        labelBackground.layer.borderWidth = 3
        labelBackground.layer.borderColor = UIColor(red: 84.0/255.0,
                                                    green: 59.0/255.0,
                                                    blue: 73.0/255.0,
                                                    alpha: 1.0).cgColor
                
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(labelBackground)
        
        self.addConstraints([
            labelBackground.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            labelBackground.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),
            labelBackground.topAnchor.constraint(equalTo: self.topAnchor, constant: 16)
        ])
        
        labelBackground.addSubview(label)
        
        labelBackground.addConstraints([
            label.leftAnchor.constraint(equalTo: labelBackground.leftAnchor, constant: 16),
            label.rightAnchor.constraint(equalTo: labelBackground.rightAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: labelBackground.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: labelBackground.bottomAnchor, constant: -16)
        ])
        
        self.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        
        label.text = "Welcome to the game.  Hope you have a great time.  This is really just test text that I want to see how it works.  Really love how this it working.  Yup!"
        
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        self.addGestureRecognizer(dismiss)
    }
    
    @objc private func dismissView() {
        self.removeFromSuperview()
        dismiss?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
