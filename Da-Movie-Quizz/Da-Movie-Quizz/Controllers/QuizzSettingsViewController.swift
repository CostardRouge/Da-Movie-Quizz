//
//  QuizzSettingsViewController
//  Da-Movie-Quizz
//
//  Created by Steeve Pommier on 14/09/15.
//  Copyright (c) 2015 CostardRouge. All rights reserved.
//

import UIKit

class QuizzSettingsViewController: UIViewController {

    @IBOutlet weak var limitedTimeSwitchButton: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        println("QuizzSettingsViewController viewDidLoad")
        
        
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                // use swift dictionary as normal
                
                if let globals = dict["Globals"] {
                    if let imbd_default_api_key = globals["IMBD_DEFAULT_API_KEY"] {
                        println("imbd_default_api_key", imbd_default_api_key)
                    }
                }
                
            }
        }
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
            
            if (self.limitedTimeSwitchButton.on) {
                game.timeMode = .Limited
            }
            else {
                game.timeMode = .Unlimited
            }
            
            
            (segue.destinationViewController as! QuizzStartedViewController).gameItem = game
        }
    }


}

