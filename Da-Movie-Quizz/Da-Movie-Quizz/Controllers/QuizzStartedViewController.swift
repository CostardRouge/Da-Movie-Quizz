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
    //var actorCredits = NSMutableDictionary()
    var movieCredits = NSMutableDictionary()
    var imbdImagesBaseUrlString = String()
    var headsOrTailsCoin = Bool(true)

    @IBOutlet weak var scoreCountLabel: UILabel!
    @IBOutlet weak var roundCountLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    @IBOutlet weak var statementLabel: UILabel!
    @IBOutlet weak var actorImageView: UIImageView!
    @IBOutlet weak var movieImageView: UIImageView!
    
    // GUI : Button actions
    @IBAction func trueAnswerButtonTouchedDown(sender: AnyObject) {
        if self.hasActorPlayedInMovie(self.actorImageView.tag, imbdMovieId:self.movieImageView.tag) == true {
            self.gameItem!.scoreCount += 10
            self.updateScoreCountLabelText(self.gameItem!.scoreCount)
            self.updateRoundCountLabelText(++self.gameItem!.roundCount)
            self.loadQuizzQuestion()
        }
        else {
            self.gameOver()
        }
    }
    
    @IBAction func falseAnswerButtonTouchedDown(sender: AnyObject) {
        if self.hasActorPlayedInMovie(self.actorImageView.tag, imbdMovieId:self.movieImageView.tag) == false {
            self.gameItem!.scoreCount += 10
            self.updateRoundCountLabelText(++self.gameItem!.roundCount)
            self.updateScoreCountLabelText(self.gameItem!.scoreCount)
            self.loadQuizzQuestion()
        }
        else {
            self.gameOver()
        }
    }
    
    @IBAction func skipButtonTouchedDown(sender: AnyObject) {
        self.gameItem!.scoreCount -= 5;
        
        self.updateRoundCountLabelText(++self.gameItem!.roundCount)
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
        
        // Get an actor arbitrarily or not
        let choosenActor:NSDictionary = self.chooseActor(movie_id)

        let actor_id = choosenActor["id"] as! Int
        let actor_name = choosenActor["name"] as! String
        
        if let actor_profile_path = choosenActor["profile_path"] as? String {
            // Set actor image
            let actorProfileUrlString = self.imbdImagesBaseUrlString.stringByAppendingString(actor_profile_path)
            
            if let url = NSURL(string: actorProfileUrlString) {
                if let data = NSData(contentsOfURL: url){
                    self.actorImageView.contentMode = UIViewContentMode.ScaleAspectFit
                    self.actorImageView.image = UIImage(data: data)
                }
            }
        }
        
        // Technique de gros porc, il etait bientot 5h du mat...
        self.actorImageView.tag = actor_id
        self.movieImageView.tag = movie_id
        
        // Update question statement
        self.statementLabel.text = String(format: "'%@' in '%@' ?!", actor_name, movie_original_title)
    }
    
    func chooseActor(imbdMovieId:Int) -> NSDictionary {
        var choosenActor = NSDictionary()
        
        // Heads coin = true -> random mechanism
        if (self.headsOrTailsCoin == true) {
            let actorsListCount = self.actorsList.count
            let actor: AnyObject = self.actorsList.objectAtIndex(Int(arc4random_uniform(UInt32(actorsListCount))))
            choosenActor = actor as! NSDictionary
        }
        // Tails coin = false -> movie cast mechanism
        else if (self.headsOrTailsCoin == false) {
            let movieCredit: NSArray? = self.movieCredits[imbdMovieId] as? NSArray
            let movieCreditCount = movieCredit!.count
            //var actor: AnyObject = movieCredit!.objectAtIndex(Int(arc4random_uniform(UInt32(movieCreditCount))))
            var actor: AnyObject = movieCredit!.objectAtIndex(0)
            choosenActor = actor as! NSDictionary
        }
        
        headsOrTailsCoin = (arc4random_uniform(UInt32(2)) == 1 ? true : false)
        return choosenActor
    }
    
    func setupGame() {
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
        timer.invalidate()
        performSegueWithIdentifier("gameOver", sender: self)
    }
    
    func hasActorPlayedInMovie(imbdActorId:Int, imbdMovieId:Int) -> Bool {
        
        var result = false
        var stop: Bool
        
        if let movie: NSArray? = self.movieCredits[imbdMovieId] as? NSArray
        {
            movie!.enumerateObjectsUsingBlock({ (credit, index, stop) -> Void in
                
                let actor_id = credit["id"] as! Int
                if (imbdActorId == actor_id) {
                    result = true
                }
            })

        }
        return result
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        
        if let game: QuizzGame = self.gameItem {
            self.updateScoreCountLabelText(game.scoreCount)
            self.updateRoundCountLabelText(game.roundCount)
            
            println(game.roundCount)
            println(gameItem?.roundCount)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        println("QuizzStartedViewController viewDidLoad")
        
        self.configureView()
        self.setupGame()
    }
    
    override func viewWillAppear(animated: Bool) {
        println("QuizzStartedViewController viewWillAppear")
        
        var leftButton = UIBarButtonItem(title: "Back to settings", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("popToRoot"))
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    func popToRoot() {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gameOver" {
            // Set game ressources to QuizzEndedViewController (GAME OVER SCREEN)
            (segue.destinationViewController as! QuizzEndedViewController).gameItem = gameItem
        }
    }
}

