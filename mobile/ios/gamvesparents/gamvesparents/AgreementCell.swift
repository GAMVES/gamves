//
//  LoginCell.swift
//  audible
//
//  Created by Jose Vigil 08/12/2017.
//

import UIKit
import Parse
import BEMCheckBox

class AgreementCell: UICollectionViewCell , BEMCheckBoxDelegate  {
    
    var tutorialController: TutorialController?

    var termsEnabled = Bool()
    var licenceEnabled = Bool()

    let titleContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        return view
    }()


     let labelsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gamvesColor
        return view
    }()

    let accountLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Parents account"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping        
        label.numberOfLines = 1
        return label
    }()


     lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit        
        imageView.isUserInteractionEnabled = true        
        return imageView
    }()

     let accountDescriptionLabel: PaddingLabel = {
        let label = PaddingLabel() 
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please accept the Terms of Service and Licence agreement."
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping        
        label.numberOfLines = 3
        return label
    }()

    //////////////////////

    let contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()


    let termsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()

    var checkboxTerms = BEMCheckBox()

    let termsAndConditionsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 18)
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: "I accept the Terms and Conditions", attributes: underlineAttribute)
        label.attributedText = underlineAttributedString
        label.numberOfLines = 2
        return label
    }()

    let licenceView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()

    var checkboxLicence = BEMCheckBox()
    
    let licenceAgreementLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 18)
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: "I accept the Licence Agreement", attributes: underlineAttribute)
        label.attributedText = underlineAttributedString
        label.numberOfLines = 2
        return label
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.gambesDarkColor
        button.setTitle("Next", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)        
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        return button
    }()
  
    
    override init(frame: CGRect) {
        super.init(frame: frame)

            self.backgroundColor = UIColor.white
        
            var metricsAgreement = [String:Int]()
            let totalHeight = self.frame.height
            let heatherHeight:CGFloat = 150
            let contentHeight:CGFloat = totalHeight - heatherHeight
            metricsAgreement = ["contentHeight": Int(contentHeight)]

            self.addSubview(self.titleContainerView)            
            self.addConstraintsWithFormat("H:|[v0]|", views: self.titleContainerView)            

            self.addSubview(self.contentContainerView)
            self.addConstraintsWithFormat("H:|[v0]|", views: self.contentContainerView)               
                  
            self.addConstraintsWithFormat("V:|[v0(170)][v1(contentHeight)]|", views: self.titleContainerView, self.contentContainerView, metrics: metricsAgreement)            

            self.titleContainerView.addSubview(self.logoImageView)
            self.titleContainerView.addConstraintsWithFormat("V:|-40-[v0(90)]|", views: self.logoImageView)

            self.titleContainerView.addSubview(self.labelsView)
            self.titleContainerView.addConstraintsWithFormat("V:|[v0]|", views: self.labelsView) 
            self.titleContainerView.addConstraintsWithFormat("H:|[v0(90)][v1]|", views: self.logoImageView, self.labelsView)

            self.labelsView.addSubview(self.accountLabel)
            self.labelsView.addConstraintsWithFormat("H:|[v0]|", views: self.accountLabel)
            
            self.labelsView.addSubview(self.accountDescriptionLabel)
            self.labelsView.addConstraintsWithFormat("H:|[v0]|", views: self.accountDescriptionLabel)

            self.labelsView.addConstraintsWithFormat("V:|-40-[v0][v1]-40-|", views: self.accountLabel, self.accountDescriptionLabel)

            self.contentContainerView.addSubview(self.termsView)
            self.contentContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.termsView)           

            self.contentContainerView.addSubview(self.licenceView)
            self.contentContainerView.addConstraintsWithFormat("H:|[v0]|", views: self.licenceView)           

            self.contentContainerView.addSubview(self.nextButton)
            self.contentContainerView.addConstraintsWithFormat("H:|-40-[v0]-40-|", views: self.nextButton)           

            self.contentContainerView.addConstraintsWithFormat("V:|-60-[v0(60)]-60-[v1(60)]-60-[v2]-20-|", 
                views: self.termsView, self.licenceView, self.nextButton)           

            self.checkboxTerms.tag = 0
            self.checkboxTerms.delegate = self
            self.termsView.addSubview(self.checkboxTerms)
            self.termsView.addConstraintsWithFormat("V:|[v0(60)]|", views: self.checkboxTerms)           

            self.termsView.addSubview(self.termsAndConditionsLabel)
            self.termsView.addConstraintsWithFormat("V:|[v0(60)]|", views: self.termsAndConditionsLabel)           
            
            self.termsView.addConstraintsWithFormat("H:|-30-[v0(60)]-20-[v1]-10-|", views: self.checkboxTerms, self.termsAndConditionsLabel)           
            
            self.checkboxLicence.tag = 1
            self.checkboxLicence.delegate = self
            self.licenceView.addSubview(self.checkboxLicence)
            self.licenceView.addConstraintsWithFormat("V:|[v0(60)]|", views: self.checkboxLicence)           

            self.licenceView.addSubview(self.licenceAgreementLabel)
            self.licenceView.addConstraintsWithFormat("V:|[v0(60)]|", views: self.licenceAgreementLabel)           
            
            self.licenceView.addConstraintsWithFormat("H:|-30-[v0(60)]-20-[v1]-10-|", views: self.checkboxLicence, self.licenceAgreementLabel)           
            
    }

    @objc func handleNext()
    {       
        self.tutorialController?.showLoginController(registered: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    

    @objc func didTap(_ checkBox: BEMCheckBox) {
        
        print(checkBox.on)

        if checkBox.tag == 0
        {
            termsEnabled = checkBox.on
            
        } else if checkBox.tag == 1
        {

            licenceEnabled = checkBox.on
        }

        print(termsEnabled)
        print(licenceEnabled)


        if licenceEnabled && termsEnabled
        {
            nextButton.isEnabled = true
        }
        
    }
    
    
}







