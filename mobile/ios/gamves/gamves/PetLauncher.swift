//
//  PetLauncher.swift
//  gamves
//
//  Created by Jose Vigil on 07/12/2018.
//  Copyright © 2018 Gamves. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class PetView: UIView {

    var petLauncher:PetLauncher!
    var keyWindow: UIView!    

    var pet:GamvesPet!

    let titleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Love your pet!"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .left
        return label
    }()

    lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        var image = UIImage(named: "close_white")
        image = Global.resizeImage(image: image!, targetSize: CGSize(width:30, height:30))
        button.setImage(image, for: .normal)                 
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.gambesDarkColor
        button.tintColor = .white
        button.layer.cornerRadius = 5        
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
	
    let picView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        return view
    }()

    let picFrameView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesPetBackgroundColor
        return view
    }()

    let petImageView: UIImageView = {
        let imageView = UIImageView()
        //imageView.image = UIImage(named: "pet")

        imageView.backgroundColor = UIColor.black
        return imageView
    }()

    let buttonsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()      

    lazy var ballButton: UIButton = {
        let button = UIButton(type: .custom) 
        button.setImage(UIImage(named: "ball.png"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false                
        button.addTarget(self, action: #selector(handleBall), for: .touchUpInside)
        return button
    }()

    lazy var foodButton: UIButton = {
		let button = UIButton(type: .custom) 	
        button.setImage(UIImage(named: "food.png"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false        		
        button.addTarget(self, action: #selector(handleFood), for: .touchUpInside)
        return button
    }()      
        
    init(frame: CGRect, pet: GamvesPet) {
        super.init(frame: frame) 
        self.pet = pet          
    }   


    func setViews(view:UIView, petLauncher:PetLauncher) {
        self.petLauncher = petLauncher
        self.keyWindow = view
    }

    func layoutViews() {

    	let width = self.frame.width
    	let height = self.frame.height    	

    	self.addSubview(self.titleView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.titleView)

    	self.addSubview(self.picView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.picView)

        self.addSubview(self.buttonsView)
        self.addConstraintsWithFormat("H:|[v0]|", views: self.buttonsView)    
        
		self.addConstraintsWithFormat("V:|[v0(100)][v1(300)][v2]|", views: self.titleView, self.picView, self.buttonsView) 

		self.titleView.addSubview(self.titleLabel)
		self.addConstraintsWithFormat("V:|-50-[v0]|", views: self.titleLabel)

		self.titleView.addSubview(self.closeButton)
		self.addConstraintsWithFormat("V:|-20-[v0]-20-|", views: self.closeButton)

		let titleWidth = width - 80

        let petMetrics = ["titleWidth" : titleWidth] 

		self.titleView.addConstraintsWithFormat("H:|[v0(100)][v1(80)]-20-|", views: 
			self.titleLabel, 
			self.closeButton, 
			metrics: petMetrics) 

		self.picView.addSubview(self.picFrameView)
		self.picView.addConstraintsWithFormat("V:|-20-[v0]-20-|", views: self.picFrameView)
		self.picView.addConstraintsWithFormat("H:|-20-[v0]-20-|", views: self.picFrameView)
		
		self.buttonsView.addSubview(self.ballButton)
		self.buttonsView.addConstraintsWithFormat("V:|-20-[v0]-20-|", views: self.ballButton)

		self.buttonsView.addSubview(self.foodButton)
		self.buttonsView.addConstraintsWithFormat("V:|-20-[v0]-20-|", views: self.foodButton)

		let halfWidth = ( self.frame.width / 2 ) - 40

		let buttonsMetrics = ["halfWidth":halfWidth]

		self.buttonsView.addConstraintsWithFormat("H:|-20-[v0(halfWidth)][v1(halfWidth)]-20-|", views: 
			self.ballButton, 
			self.foodButton,
			metrics: buttonsMetrics)


    }
    
    override func layoutSubviews() {

    	self.titleLabel.text = pet.name
        self.petImageView.image = pet.thumbnail   

        let width = self.frame.width - 40 
        let height:CGFloat = 300 

		let marginHor = ( width - 147 ) / 2
		let marginVer = ( height - 121 ) / 2

		print(width)
		print(height)

		print(marginHor)
		print(marginVer)

		let picMetric = ["marginHor":marginHor, "marginVer":marginVer]

		self.picFrameView.addSubview(self.petImageView)		
		self.picFrameView.addConstraintsWithFormat("V:|-marginVer-[v0(121)]|", views: 
			self.petImageView,
			metrics: picMetric)

		self.picFrameView.addConstraintsWithFormat("H:|-marginHor-[v0(147)]|", views: 
			self.petImageView,
			metrics: picMetric)		
    }
    
    required init?(coder aDecoder: NSCoder) 
    {
        fatalError("init(coder:) has not been implemented")
    }    
    
    func closePet()
    {
        //REMOVE IF EXISTS VIDEO RUNNING
        for subview in (UIApplication.shared.keyWindow?.subviews)! {
            if (subview.tag == 1)
            {
                subview.removeFromSuperview()
            }
        }
    }  

    @objc func handleFood() {

    }

    @objc func handleBall() {
    	
    }  

    @objc func handleCancel() {        
        
        self.closePet()

         UIApplication.shared.setStatusBarHidden(false, with: .fade)
    }

}

class PetLauncher: UIView {

    class func className() -> String {
        return "PetLauncher"
    }        
    
    var petView:PetView!
    
    var view:UIView!    
    
    var yLocation = CGFloat()
    var xLocation = CGFloat()
    var lastX = CGFloat()   

    var keyWindoWidth = CGFloat()
    var keyWindoHeight = CGFloat()
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)

    func showPet(petGamves: GamvesPet){
        
        self.keyWindoWidth = (UIApplication.shared.keyWindow?.frame.size.width)!
        self.keyWindoHeight = (UIApplication.shared.keyWindow?.frame.size.height)!
        
        if let keyWindow = UIApplication.shared.keyWindow {

            self.view = UIView(frame: keyWindow.frame)
            
            //self.view.backgroundColor = UIColor.white           
            
            self.view.frame = CGRect(x: keyWindow.frame.width - 10, y: keyWindow.frame.height - 10, width: 10, height: 10)                       
            
            let petFrame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: keyWindow.frame.height)

            self.petView = PetView(frame: petFrame, pet: petGamves)                               

            self.view.addSubview(self.petView)

            self.view.tag = 1
            
            let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))                                 
            self.petView.addGestureRecognizer(panGesture)
            
            self.petView.setViews(view: self.view, petLauncher: self)
            self.petView.layoutViews()
            
            keyWindow.addSubview(self.view)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                
                self.view.frame = keyWindow.frame
                
                }, completion: { (completedAnimation) in                   
                    
                    UIApplication.shared.setStatusBarHidden(true, with: .fade)
            })
        }
    }

    @objc func handlePanGesture(sender: UIPanGestureRecognizer) {        

        let touchPoint = sender.location(in: self.view?.window)

        let touchY = touchPoint.y - initialTouchPoint.y

        if touchY > 100 {

            let alpha = self.view.alpha
            let remove = touchY/10000
            let finalAlpha = alpha - remove

            self.view.alpha = finalAlpha            

            if touchY > 500 {

                self.petView.closePet()

                UIApplication.shared.setStatusBarHidden(false, with: .fade)
            }
        }

        if sender.state == UIGestureRecognizerState.began {

            initialTouchPoint = touchPoint

        } else if sender.state == UIGestureRecognizerState.changed {

            if touchPoint.y - initialTouchPoint.y > 0 {

                self.view.frame = CGRect(x: 0, y: touchPoint.y - initialTouchPoint.y, width: self.view.frame.size.width, height: self.view.frame.size.height)
                
            }

        } else if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
            
            if touchPoint.y - initialTouchPoint.y > 200 {                               

                self.petView.closePet()
                
                UIApplication.shared.setStatusBarHidden(false, with: .fade)

            } else {
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                })
            }
        }

    }     
}
