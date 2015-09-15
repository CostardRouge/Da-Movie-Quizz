//
//  QuizzSettingsViewController
//  Da-Movie-Quizz
//
//  Created by Steeve Pommier on 14/09/15.
//  Copyright (c) 2015 CostardRouge. All rights reserved.
//

import UIKit

class QuizzSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        println("QuizzSettingsViewController viewDidLoad")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "startQuizz" {
            
            // Create the game
            var game = QuizzGame();
            
            game.roundCount = 1;
            game.scoreCount = 0;
            
            (segue.destinationViewController as! QuizzStartedViewController).gameItem = game
        }
    }


}

