//
//  PetViewController.swift
//  gamves
//
//  Created by Jose Vigil on 07/12/2018.
//  Copyright © 2018 Gamves. All rights reserved.
//

import UIKit

class PetViewController: UIViewController {

    var homeController:HomeController!

    let frameView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()

    let petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pet")
        return imageView
    }()

    let buttonsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()

    lazy var ballButton: UIButton = {
        let button = UIButton(type: .system) 
        let image = UIImage(named: "ball")        
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white
        button.tintColor = .white
        button.layer.cornerRadius = 5        
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleBall), for: .touchUpInside)
        return button
    }()

    lazy var foodButton: UIButton = {
        let button = UIButton(type: .system) 
        let image = UIImage(named: "food")        
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white
        button.tintColor = .white
        button.layer.cornerRadius = 5        
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()        

        self.view.addSubview(self.frameView)
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.frameView)
        self.view.addConstraintsWithFormat("H:|-50-[v0]-50-|", views: self.frameView)

        self.frameView.addSubview(self.petImageView)
        self.frameView.addConstraintsWithFormat("H:|[v0]|", views: self.petImageView)

        self.frameView.addSubview(self.buttonsView)
        self.frameView.addConstraintsWithFormat("H:|[v0]|", views: self.buttonsView)

        self.frameView.addConstraintsWithFormat("V:|[v0(180)][v1(60)]|", views: self.petImageView, self.buttonsView) 

        self.view?.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
       

    @objc func handleSave() {

    }

    @objc func handleBall() {

        
    }

    @objc func handleCancel() {        
        
    }

}
