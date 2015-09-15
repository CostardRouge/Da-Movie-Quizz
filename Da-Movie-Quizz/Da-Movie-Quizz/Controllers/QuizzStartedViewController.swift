//
//  QuizzStartedViewController
//  Da-Movie-Quizz
//
//  Created by Steeve Pommier on 14/09/15.
//  Copyright (c) 2015 CostardRouge. All rights reserved.
//

import UIKit

class QuizzStartedViewController: UIViewController {

    @IBOutlet weak var scoreCountLabel: UILabel!
    @IBOutlet weak var roundCountLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    
    @IBAction func trueAnswerButtonTouchedDown(sender: AnyObject) {
        println("trueAnswerButtonTouchedDown")
    }
    
    @IBAction func falseAnswerButtonTouchedDown(sender: AnyObject) {
        println("falseAnswerButtonTouchedDown")
    }
    
    @IBAction func skipButtonTouchedDown(sender: AnyObject) {
        println("skipButtonTouchedDown")
    }
    
    var gameItem: QuizzGame?
    
    func configureView() {
        // Update the user interface for the detail item.
        
        if let game: QuizzGame = self.gameItem {
            
            if let _scoreCountLabel = self.scoreCountLabel {
                _scoreCountLabel.text = String(format: "%dpt", game.scoreCount)
            }
            
            if let _roundCountLabel = self.roundCountLabel {
                _roundCountLabel.text = String(format: "#%d", game.roundCount)
            }
            
            if let _timeValueLabel = self.timeValueLabel {
                _timeValueLabel.text = String(format: "%d", game.timePlayed)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        println("QuizzStartedViewController viewDidLoad")
        
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }


}

