//
//  QuizzStartedViewController
//  Da-Movie-Quizz
//
//  Created by Steeve Pommier on 14/09/15.
//  Copyright (c) 2015 CostardRouge. All rights reserved.
//

import UIKit
import ILMovieDB

class QuizzStartedViewController: UIViewController {
    
    var count = 0
    var seconds = 0
    var timer = NSTimer()
    
    var gameItem: QuizzGame?
    var imbdClient: ILMovieDBClient?

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
    
    func getPopularMoviesList(pageValue: Int) -> NSArray // ok that is stupid
    {
        var paramaters = ["page": pageValue]
        var popularMoviesList = NSArray()
        
        //println(ILMovieDB.kILMovieDBMoviePopular)
        
        self.imbdClient?.GET(ILMovieDB.kILMovieDBMoviePopular, parameters: paramaters, block: { (responseObject, error) -> Void in
            if (error != nil) {
                println("error")
            }
            println("kILMovieDBMoviePopular")
            //println(responseObject)
            
            if let jsonResult = responseObject as? Dictionary<String, AnyObject> {
                //println(jsonResult)
                
                //var results = jsonResult.indexForKey("results");
                //println(results)
                
                if let results = jsonResult["results"] as? NSArray {
                    //return results
                    //print(results)
                    popularMoviesList = results
                }
            }
         })
        return popularMoviesList
    }
    
    func loadQuizzQuestion() {
        
        let popularMoviesList = self.getPopularMoviesList(1)
        print(popularMoviesList.count)
        
        
//        extern NSString * const kILMovieDBMovieLatest;
//        extern NSString * const kILMovieDBMovieUpcoming;
//        extern NSString * const kILMovieDBMovieTheatres;
//        extern NSString * const kILMovieDBMoviePopular;
//        extern NSString * const kILMovieDBMovieTopRated;
        
        
    }
    
    func setupGame()  {
        
        if let game: QuizzGame = self.gameItem {
            
            // Retrieve imbd api key form our app globals
            let appGlobals = QuizzGameHelper.getAppGlobalsDictionary()
            
            // If a default imbd api key is defined, we can started the game
            if let imbd_default_api_key: AnyObject = appGlobals["IMBD_DEFAULT_API_KEY"] {
                println("imbd_default_api_key", imbd_default_api_key)
                
                self.imbdClient = ILMovieDBClient.sharedClient()
                self.imbdClient?.apiKey = imbd_default_api_key as! String
                
                self.loadQuizzQuestion()
            }
            else {
                println("NO API KEY DEFINED!")
            }
            
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
        if let game: QuizzGame = self.gameItem {
            
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

