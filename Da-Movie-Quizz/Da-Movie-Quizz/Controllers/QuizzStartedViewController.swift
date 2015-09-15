//
//  QuizzStartedViewController
//  Da-Movie-Quizz
//
//  Created by Steeve Pommier on 14/09/15.
//  Copyright (c) 2015 CostardRouge. All rights reserved.
//

import UIKit

class QuizzStartedViewController: UIViewController {
    
    var count = 0
    var seconds = 0
    var timer = NSTimer()
    
    var gameItem: QuizzGame?
    var moviesList = NSArray()
    var actorsList = NSArray()

    @IBOutlet weak var scoreCountLabel: UILabel!
    @IBOutlet weak var roundCountLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    
    // GUI : Button actions
    @IBAction func trueAnswerButtonTouchedDown(sender: AnyObject) {
        println("trueAnswerButtonTouchedDown")
        
        self.updateRoundCountLabelText(self.gameItem!.roundCount++)
    }
    
    @IBAction func falseAnswerButtonTouchedDown(sender: AnyObject) {
        println("falseAnswerButtonTouchedDown")
        
        self.updateRoundCountLabelText(self.gameItem!.roundCount++)
    }
    
    @IBAction func skipButtonTouchedDown(sender: AnyObject) {
        println("skipButtonTouchedDown")
        
        self.gameItem!.scoreCount -= 10;
        
        self.updateRoundCountLabelText(self.gameItem!.roundCount++)
        self.updateScoreCountLabelText(self.gameItem!.scoreCount)
    }
    
    // GUI : Label handlers
    func getRoundCountLabelText(roundCount: Int) -> String {
        return String(format: "#%d", roundCount)
    }
    
    func getScoreCountLabelText(scoreCount: Int) -> String {
        return String(format: "%dpt", scoreCount)
    }
    
    func updateScoreCountLabelText(scoreCount: Int) {
        if let _scoreCountLabel = self.scoreCountLabel {
            _scoreCountLabel.text = self.getScoreCountLabelText(scoreCount)
        }
    }
    
    func updateRoundCountLabelText(roundCount: Int) {
        if let _roundCountLabel = self.roundCountLabel {
            _roundCountLabel.text = self.getRoundCountLabelText(roundCount)
        }
    }
    
    func loadQuizzQuestion() {
        

    }
    
    func setupGame()  {
        
        if let game: QuizzGame = self.gameItem {
            
            if (game.timeMode == .Limited) {
                seconds = 5
            }
            else {
                seconds = 0
            }
            
            count = 0
            
            if let _timeValueLabel = self.timeValueLabel {
                _timeValueLabel.text = String(format: "%d sec.", seconds)
            }
            
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("subtractTime"), userInfo: nil, repeats: true)
        }
    }
    
    func subtractTime() {
        if ((moviesList.count == 0) && (actorsList.count == 0)) {
            println("moviesList \(moviesList.count )")
            println("actorsList \(actorsList.count )")
        }
        else if let game: QuizzGame = self.gameItem {
            
            if (game.timeMode == .Limited) {
                seconds--
                
                if(seconds == 0)  {
                    timer.invalidate()
                    println("Game over")
                }
            }
            else {
                seconds++
            }
            
            self.timeValueLabel.text = String(format: "%d sec.", seconds)
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        
        if let game: QuizzGame = self.gameItem {
            self.updateScoreCountLabelText(game.scoreCount)
            self.updateRoundCountLabelText(game.roundCount)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        println("QuizzStartedViewController viewDidLoad")
        
        self.configureView()
        self.setupGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }


}

