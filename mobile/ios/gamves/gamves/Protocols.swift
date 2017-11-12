//
//  Protocols.swift
//  gamves
//
//  Created by Jose Vigil on 10/18/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit


protocol KeyboardDelegate : class
{
    func keyboardOpened(keybordHeight: CGFloat)
    func keyboardclosed()
}

protocol NavBarDelegate : class
{
    func updateTitle(latelText:String)
    func updateSubTitle(latelText:String)
}

protocol FeedDelegate : class
{
    func uploadData()
    func fetchFeed()
}
