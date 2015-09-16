//
//  QuizzGame.swift
//  Da-Movie-Quizz
//
//  Created by Steeve Pommier on 14/09/15.
//  Copyright (c) 2015 CostardRouge. All rights reserved.
//

import UIKit

enum eQuizzTimeMode {
    case Unlimited, Limited
}

enum eMoviesNationality {
    case Unlimited, Limited
}

enum eActorsGender {
    case All, Male, Female
}

class QuizzGame: NSObject {
    
    var roundCount:Int = 0
    var scoreCount:Int = 0
    var timePlayed:Int = 0
    
    var timeMode:eQuizzTimeMode = .Limited
    var actorsGender:eActorsGender = .All
    
    var playerUsername:String = "DMQ"
    
    func currentOrder() {
    
    }
}
