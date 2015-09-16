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
    
    var imbdImagesBaseUrlString:String = "" {
        didSet {
            launchGame()
        }
    }
    
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
    
    var actorCredits = NSMutableDictionary()  {
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
            game.roundCount = 1
            game.scoreCount = 0
            game.timePlayed = 0
            
            // Set attributes from ui controls
            if (self.limitedTimeSwitchButton.on) {
                game.timeMode = .Limited
            }
            else {
                game.timeMode = .Unlimited
            }
            
            // Set game ressources to QuizzStartedViewController
            (segue.destinationViewController as! QuizzStartedViewController).imbdImagesBaseUrlString = self.imbdImagesBaseUrlString
            (segue.destinationViewController as! QuizzStartedViewController).actorCredits = self.actorCredits
            (segue.destinationViewController as! QuizzStartedViewController).moviesList = self.moviesList
            (segue.destinationViewController as! QuizzStartedViewController).actorsList = self.actorsList
            (segue.destinationViewController as! QuizzStartedViewController).gameItem = game
        }
    }
    
    func launchGame() {
        if (self.moviesList.count > 0 && self.actorsList.count > 0) {
            
            // all credits downloaded
            if (self.actorCredits.count == 20) {
                // now we can laucnh a game
                if (startGameButton.enabled == false) {
                    performSegueWithIdentifier("startQuizz", sender: self)
                }
                
                // Re validate start game button
                startGameButton.enabled = true
                startGameButton.setTitle("Start", forState: .Normal)
            }
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
        
        self.setImbdImagesBaseUrl()
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
                    //var actorsCount = actors?.count
                    
                    var stop: Bool
                    actors?.enumerateObjectsUsingBlock({ (actor, index, stop) -> Void in
                        let imbdActorId = actor["id"] as! Int
                        self.findAndAddActorCredits(imbdActorId)
                    })
                    
                    self.actorsList = actors!
                }
            }
        })
    }

    func setImbdImagesBaseUrl() -> Void {
        
        self.imbdClient?.GET(ILMovieDB.kILMovieDBConfiguration, parameters: nil, block: { (responseObject, error) -> Void in
            if (error != nil) {
                println("kILMovieDBConfiguration error")
            }
            
            if let jsonResult = responseObject as? Dictionary<String, AnyObject> {
                //println(jsonResult["images"])
                if let images: NSDictionary? = jsonResult["images"] as? NSDictionary {
                    var base_url = images?.objectForKey("base_url") as! String
                    self.imbdImagesBaseUrlString = base_url.stringByAppendingString("w185")
                }
            }
        })
    }
    
    func findAndAddActorCredits(imbdActorId: Int) -> Void {
    
        var actor_credits_api_url = ILMovieDB.kILMovieDBPeopleMovieCredits.stringByReplacingOccurrencesOfString(":id", withString: String(imbdActorId))
        
        self.imbdClient?.GET(actor_credits_api_url, parameters: nil, block: { (responseObject, error) -> Void in
            if (error != nil) {
                println("kILMovieDBPeopleMovieCredits error")
            }
            
            if let jsonResult = responseObject as? Dictionary<String, AnyObject> {
                //println(jsonResult["cast"])
                if let actor_cast: NSArray? = jsonResult["cast"] as? NSArray {
                    //println(actor_cast)
                    self.actorCredits[imbdActorId] = actor_cast
                }
            }
        })
    }

}

