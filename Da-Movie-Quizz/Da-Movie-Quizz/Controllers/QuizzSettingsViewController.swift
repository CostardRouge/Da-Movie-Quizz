//
//  QuizzSettingsViewController
//  Da-Movie-Quizz
//
//  Created by Steeve Pommier on 14/09/15.
//  Copyright (c) 2015 CostardRouge. All rights reserved.
//

import UIKit
import ILMovieDB

class QuizzSettingsViewController: UIViewController {
    
    var imbdClient: ILMovieDBClient?
    
    var moviesList:NSArray = [] {
        didSet {
            launchGame()
        }
    }

    var actorsList:NSArray = [] {
        didSet {
            launchGame()
        }
    }

    @IBOutlet weak var limitedTimeSwitchButton: UISwitch!
    @IBOutlet weak var startGameButton: UIButton!
    
    @IBAction func startGameButtonTouchedDown(sender: AnyObject) {
        // If IMBD connection is ok
        if self.initImbdClient() {
            // Retrieve top popular movies and actors
            self.prepareGame()
            
            // Invalidate start game button
            startGameButton.enabled = false
            startGameButton.setTitle("Loading...", forState: .Normal)
        }
        else
        {
            println("QIMBD connection went bad")
        }
    }
    
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
            
            // Create the game item
            var game = QuizzGame();
            
            // Fill default game value
            game.roundCount = 1;
            game.scoreCount = 0;
            
            // Set attributes from ui controls
            if (self.limitedTimeSwitchButton.on) {
                game.timeMode = .Limited
            }
            else {
                game.timeMode = .Unlimited
            }
            
            // Set game ressources to QuizzStartedViewController
            (segue.destinationViewController as! QuizzStartedViewController).moviesList = self.moviesList
            (segue.destinationViewController as! QuizzStartedViewController).actorsList = self.actorsList
            (segue.destinationViewController as! QuizzStartedViewController).gameItem = game
        }
    }
    
    func launchGame() {
        if (self.moviesList.count > 0 && self.actorsList.count > 0) {
            // now we can laucnh a game
            if (startGameButton.enabled == false) {
                println(startGameButton.titleLabel?.text)
                performSegueWithIdentifier("startQuizz", sender: self)
            }
            
            // Re validate start game button
            startGameButton.enabled = true
            startGameButton.setTitle("Start", forState: .Normal)
        }
        else
        {
            println("ressources are still neeed")
        }
    }
    
    func initImbdClient() -> Bool {
        // Retrieve imbd api key form our app globals
        let appGlobals = QuizzGameHelper.getAppGlobalsDictionary()
        
        // If a default imbd api key is defined, we can started the game
        if let imbd_default_api_key: AnyObject = appGlobals["IMBD_DEFAULT_API_KEY"] {
            println("imbd_default_api_key", imbd_default_api_key)
            
            self.imbdClient = ILMovieDBClient.sharedClient()
            self.imbdClient?.apiKey = imbd_default_api_key as! String
            return true
        }
        return false
    }

    func prepareGame() {
        println("Preparing ressources for the game")
        
        self.setPopularMoviesList(1)
        self.setPopularActorsList(1)
    }
    
    func setPopularMoviesList(pageValue: Int)
    {
        var paramaters = ["page": pageValue]
        
        self.imbdClient?.GET(ILMovieDB.kILMovieDBMoviePopular, parameters: paramaters, block: { (responseObject, error) -> Void in
            if (error != nil) {
                println("kILMovieDBMoviePopular error")
            }
            if let jsonResult = responseObject as? Dictionary<String, AnyObject> {
                if let movies: NSArray? = jsonResult["results"] as? NSArray {
                    self.moviesList = movies!
                    
//                    var moviesCount = movies?.count
//                    
//                    var stop: Bool
//                    movies?.enumerateObjectsUsingBlock({ (movie, index, stop) -> Void in
////                        println(movie)
//                        
//                        println(movie["original_title"])
//                        
////                        println(movie["original_language"])
////                        println(movie["id"])
////                        println(movie["poster_path"])
//                    })
                }
                
            }
        })
    }

    func setPopularActorsList(pageValue: Int)
    {
        var paramaters = ["page": pageValue]
        
        self.imbdClient?.GET(ILMovieDB.kILMovieDBPeoplePopular, parameters: paramaters, block: { (responseObject, error) -> Void in
            if (error != nil) {
                println("kILMovieDBPeoplePopular error")
            }
            
            if let jsonResult = responseObject as? Dictionary<String, AnyObject> {
                if let actors: NSArray? = jsonResult["results"] as? NSArray {
                    self.actorsList = actors!
                }
            }
        })
    }

}

