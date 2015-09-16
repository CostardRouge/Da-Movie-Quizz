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
    var actorCredits = NSMutableDictionary()
    var imbdImagesBaseUrlString = String()

    @IBOutlet weak var scoreCountLabel: UILabel!
    @IBOutlet weak var roundCountLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    @IBOutlet weak var statementLabel: UILabel!
    @IBOutlet weak var actorImageView: UIImageView!
    @IBOutlet weak var movieImageView: UIImageView!
    
    // GUI : Button actions
    @IBAction func trueAnswerButtonTouchedDown(sender: AnyObject) {
        println("trueAnswerButtonTouchedDown")
        
        if self.hasActorPlayedInMovie(self.actorImageView.tag, imbdMovieId:self.movieImageView.tag) == true {
            self.gameItem!.scoreCount += 10
            self.updateScoreCountLabelText(self.gameItem!.scoreCount)
            self.loadQuizzQuestion()
        }
        else {
            self.gameOver()
        }
        
        self.updateRoundCountLabelText(self.gameItem!.roundCount++)
    }
    
    @IBAction func falseAnswerButtonTouchedDown(sender: AnyObject) {
        println("falseAnswerButtonTouchedDown")
        
        if self.hasActorPlayedInMovie(self.actorImageView.tag, imbdMovieId:self.movieImageView.tag) == false {
            self.gameItem!.scoreCount += 10
            self.updateScoreCountLabelText(self.gameItem!.scoreCount)
            self.loadQuizzQuestion()
        }
        else {
            self.gameOver()
        }
        
        self.updateRoundCountLabelText(self.gameItem!.roundCount++)
    }
    
    @IBAction func skipButtonTouchedDown(sender: AnyObject) {
        println("skipButtonTouchedDown")
        
        self.gameItem!.scoreCount -= 5;
        
        self.updateRoundCountLabelText(self.gameItem!.roundCount++)
        self.updateScoreCountLabelText(self.gameItem!.scoreCount)
        self.loadQuizzQuestion()
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
        // Get random actor
        let actorsListCount = self.actorsList.count
        let actor: AnyObject = self.actorsList.objectAtIndex(Int(arc4random_uniform(UInt32(actorsListCount))))
        let actor_id = actor["id"] as! Int;
        let actor_name = actor["name"] as! String;
        let actor_profile_path = actor["profile_path"] as! String;
        
        // Set actor image
        let actorProfileUrlString = self.imbdImagesBaseUrlString.stringByAppendingString(actor_profile_path)
        
        if let url = NSURL(string: actorProfileUrlString) {
            if let data = NSData(contentsOfURL: url){
                self.actorImageView.contentMode = UIViewContentMode.ScaleAspectFit
                self.actorImageView.image = UIImage(data: data)
            }
        }
        
        // Get random movie entry
        let moviesListCount = self.moviesList.count
        let movie: AnyObject = self.moviesList.objectAtIndex(Int(arc4random_uniform(UInt32(moviesListCount))))
        let movie_id = movie["id"] as! Int;
        let movie_original_title = movie["original_title"] as! String;
        let movie_poster_path = movie["poster_path"] as! String;
        
        // Set movie image
        let moviePosterUrlString = self.imbdImagesBaseUrlString.stringByAppendingString(movie_poster_path)
        
        if let url = NSURL(string: moviePosterUrlString) {
            if let data = NSData(contentsOfURL: url){
                self.movieImageView.contentMode = UIViewContentMode.ScaleAspectFit
                self.movieImageView.image = UIImage(data: data)
            }
        }
        
        // Technique de gros porc, il est bientot 5h du mat...
        self.actorImageView.tag = actor_id
        self.movieImageView.tag = movie_id
        
        // Update question statement
        self.statementLabel.text = String(format: "'%@' in '%@' ?!", actor_name, movie_original_title)
    }
    
    func setupGame()  {
        
        if let game: QuizzGame = self.gameItem {
            
            if (game.timeMode == .Limited) {
                seconds = 60
            }
            else {
                seconds = 0
            }
            
            game.timePlayed = 0
            
            if let _timeValueLabel = self.timeValueLabel {
                _timeValueLabel.text = String(format: "%d sec.", seconds)
            }
            
            // Load 1st question 
            loadQuizzQuestion()
            
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("subtractTime"), userInfo: nil, repeats: true)
        }
    }
    
    func subtractTime() {
        if ((moviesList.count == 0) || (actorsList.count == 0)) {
            println("moviesList \(moviesList.count )")
            println("actorsList \(actorsList.count )")
        }
        else if let game: QuizzGame = self.gameItem {
            
            if (game.timeMode == .Limited) {
                seconds--
                
                if(seconds == 0)  {
                    self.gameOver()
                }
            }
            else {
                seconds++
            }
            
            game.timePlayed++
            self.timeValueLabel.text = String(format: "%d sec.", seconds)
        }
    }
    
    func gameOver() {
        println("Game over")
        timer.invalidate()
        performSegueWithIdentifier("gameOver", sender: self)
    }
    
    func hasActorPlayedInMovie(imbdActorId:Int, imbdMovieId:Int) -> Bool {
        
        var result = false
        var stop: Bool
        
        self.actorCredits[imbdActorId]?.enumerateObjectsUsingBlock({ (credit, index, stop) -> Void in
            let movie_id = credit["id"] as! Int
            
            if (movie_id == imbdMovieId) {
                result = true
            }
        })
        
        return result
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "gameOver" {
            // Set game ressources to QuizzEndedViewController (GAME OVER SCREEN)
            (segue.destinationViewController as! QuizzEndedViewController).gameItem = self.gameItem
        }
    }
}

