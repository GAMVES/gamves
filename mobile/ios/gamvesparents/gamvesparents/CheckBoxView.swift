//
//  CheckBoxView.swift
//  gamvesparents
//
//  Created by Jose Vigil on 11/4/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit
import BEMCheckBox

class CheckBoxView: UIView, BEMCheckBoxDelegate {
    
    let checkboxView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let labelFather: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = UIFont(name: label.font.fontName, size: 13)
        label.textAlignment = .left
        return label
    }()
    
    let labelMoter: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = UIFont(name: label.font.fontName, size: 13)
        label.textAlignment = .left
        return label
    }()
    
    let group = BEMCheckBoxGroup()
    var checkboxFather = BEMCheckBox()
    var checkboxMother = BEMCheckBox()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.checkboxView)
        
        let height = frame.height
        
        let metricsDict = ["height":height]
        
        self.addConstraintsWithFormat("V:[v0(height)]|", views: self.checkboxView, metrics: metricsDict)
        self.addConstraintsWithFormat("H:[v0]|", views: self.checkboxView)
        
        //https://github.com/Boris-Em/BEMCheckBox
        
        self.checkboxFather.tag = 0
        self.checkboxFather.tintColor = UIColor.white
        self.checkboxFather.delegate = self
        self.checkboxFather.tintColor = UIColor.white
        self.checkboxFather.onTintColor = UIColor.white
        self.checkboxFather.onCheckColor = UIColor.white
        self.checkboxFather.lineWidth = 1
        self.labelFather.text = "Father"
        
        self.checkboxMother.tag = 1
        self.checkboxMother.delegate = self
        self.checkboxMother.tintColor = UIColor.white
        self.checkboxMother.onTintColor = UIColor.white
        self.checkboxMother.onCheckColor = UIColor.white
        self.checkboxMother.lineWidth = 1
        self.labelMoter.text = "Mother"
        
        self.checkboxView.addSubview(self.checkboxFather)
        self.checkboxView.addSubview(self.labelFather)
        self.checkboxView.addSubview(self.checkboxMother)
        self.checkboxView.addSubview(self.labelMoter)
        
        self.checkboxView.addConstraintsWithFormat("V:|[v0(height)]|", views: self.checkboxFather, metrics: metricsDict)
        self.checkboxView.addConstraintsWithFormat("V:|[v0(height)]|", views: self.labelFather, metrics: metricsDict)
        self.checkboxView.addConstraintsWithFormat("V:|[v0(height)]|", views: self.checkboxMother, metrics: metricsDict)
        self.checkboxView.addConstraintsWithFormat("V:|[v0(height)]|", views: self.labelMoter, metrics: metricsDict)
        
        self.checkboxView.addConstraintsWithFormat("H:|-20-[v0(height)]-10-[v1]-20-[v2(height)]-10-[v3]|", views: self.checkboxFather, self.labelFather, self.checkboxMother, self.labelMoter, metrics: metricsDict)
        
        self.group.addCheckBox(toGroup: self.checkboxFather)
        self.group.addCheckBox(toGroup: self.checkboxMother)
    
        self.checkboxFather.on = true
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTap(_ checkBox: BEMCheckBox) {
        
        print(checkBox.on)
        
    }
    
}
