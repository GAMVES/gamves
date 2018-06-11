//
//  InfoView.swift
//  gamves
//
//  Created by Jose Vigil on 9/4/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class InfoApprovalView: UIView {
    
    var videoGamves:VideoGamves!
    var fanpageGamves:FanpageGamves!

	let infoContView: UIView = {
        let view = UIView()
        //view.backgroundColor = UIColor(white: 0, alpha: 1)
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleContView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = UIColor.blue
        return view
    }()

    let titleLabel: VerticalAlignLabel = {
        let label = VerticalAlignLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.text = "  Title:"
        //label.font = UIFont.boldSystemFont(ofSize: 17)
        label.font = label.font.withSize(14)
        label.textAlignment = .left
        return label
    }()

    let infoTitleLabel: VerticalAlignLabel = {
        let label = VerticalAlignLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 3
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let descContView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = UIColor.yellow
        return view
    }()
    
    let descLabel: VerticalAlignLabel = {
        let label = VerticalAlignLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.text = "  Description:"
        label.font = label.font.withSize(14)
        label.textAlignment = .left
        return label
    }()
    
     let infoDescLabel: VerticalAlignLabel = {
        let label = VerticalAlignLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        //label.font = UIFont.boldSystemFont(ofSize: 10)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        label.numberOfLines = 5
        //label.backgroundColor = UIColor.lightGray
        return label
    }()

    ///////////////////////////////////////////////////


    init(frame: CGRect, obj: AnyObject) {
        super.init(frame: frame)    
        
        if (obj is VideoGamves) {
            
            let video = obj as! VideoGamves
            
            self.videoGamves = video
            
            let paddTitle = "            \(video.title)"
            self.infoTitleLabel.text =  paddTitle

            let paddDesc =  "                       \(video.description)"
            self.infoDescLabel.text = paddDesc
        
        } else if (obj is FanpageGamves) {
            
            let fanpage = obj as! FanpageGamves
            
            self.fanpageGamves = fanpage
            
            self.infoTitleLabel.text = fanpage.name
            self.infoDescLabel.text = fanpage.about
            
        }

        self.infoContView.frame = frame

        self.addSubview(self.infoContView)
        
        self.addConstraintsWithFormat("H:|[v0]|", views: self.infoContView)
        self.addConstraintsWithFormat("V:|[v0]|", views: self.infoContView)    

        //self.infoContView.backgroundColor = UIColor.white
        
        self.infoContView.addSubview(self.titleContView)
        self.infoContView.addSubview(self.descContView)

        self.infoContView.addConstraintsWithFormat("H:|[v0]|", views: self.titleContView)
        self.infoContView.addConstraintsWithFormat("H:|[v0]|", views: self.descContView)
        
        self.infoContView.addConstraintsWithFormat("V:|[v0(80)][v1]|", views:
            self.titleContView,
            self.descContView)        
        
        self.titleContView.addSubview(self.infoTitleLabel)
        self.titleContView.addSubview(self.titleLabel)

        //self.titleLabel.backgroundColor = UIColor.brown
        //self.infoTitleLabel.backgroundColor = UIColor.cyan

        /*self.titleContView.addConstraintsWithFormat("H:|-5-[v0(50)][v1]|", views:
            self.titleLabel,
            self.infoTitleLabel)*/

        self.titleContView.addConstraintsWithFormat("H:|-5-[v0(80)]|", views: self.titleLabel)
        self.titleContView.addConstraintsWithFormat("H:|-5-[v0]|", views: self.infoTitleLabel)           
        
        self.titleContView.addConstraintsWithFormat("V:|-5-[v0(35)]-40-|", views: self.titleLabel)

        self.titleContView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.infoTitleLabel)
        
        self.descContView.addSubview(self.infoDescLabel)
        self.descContView.addSubview(self.descLabel)

        self.descContView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: self.descLabel)
        self.descContView.addConstraintsWithFormat("H:|-5-[v0]-5-|", views: self.infoDescLabel)
        
        /*self.descContView.addConstraintsWithFormat("V:|-20-[v0(20)][v1]|", views:
            self.descLabel,
            self.infoDescLabel)*/

        self.descContView.addConstraintsWithFormat("V:|-5-[v0(40)]|", views: self.descLabel)
        self.descContView.addConstraintsWithFormat("V:|-5-[v0]-5-|", views: self.infoDescLabel)
        
    } 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

  
}


public class VerticalAlignLabel: UILabel {
    enum VerticalAlignment {
        case top
        case middle
        case bottom
    }

    var verticalAlignment : VerticalAlignment = .top {
        didSet {
            setNeedsDisplay()
        }
    }

    override public func textRect(forBounds bounds: CGRect, limitedToNumberOfLines: Int) -> CGRect {
        let rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: limitedToNumberOfLines)

        if UIView.userInterfaceLayoutDirection(for: .unspecified) == .rightToLeft {
            switch verticalAlignment {
            case .top:
                return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y, width: rect.size.width, height: rect.size.height)
            case .middle:
                return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y + (bounds.size.height - rect.size.height) / 2, width: rect.size.width, height: rect.size.height)
            case .bottom:
                return CGRect(x: self.bounds.size.width - rect.size.width, y: bounds.origin.y + (bounds.size.height - rect.size.height), width: rect.size.width, height: rect.size.height)
            }
        } else {
            switch verticalAlignment {
            case .top:
                return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: rect.size.width, height: rect.size.height)
            case .middle:
                return CGRect(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height) / 2, width: rect.size.width, height: rect.size.height)
            case .bottom:
                return CGRect(x: bounds.origin.x, y: bounds.origin.y + (bounds.size.height - rect.size.height), width: rect.size.width, height: rect.size.height)
            }
        }
    }

    override public func drawText(in rect: CGRect) {
        let r = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: r)
    }
}
