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
    
    //var actorCredits = NSMutableDictionary()
    var movieCredits = NSMutableDictionary()

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
            print("QIMBD connection went bad")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("QuizzSettingsViewController viewDidLoad")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "startQuizz" {
            // Create the game item
            let game = QuizzGame();
            
            // Set attributes from ui controls
            game.timeMode = self.limitedTimeSwitchButton.on ? .Limited : .Unlimited
            
            // Set game ressources to QuizzStartedViewController
            (segue.destinationViewController as! QuizzStartedViewController).imbdImagesBaseUrlString = self.imbdImagesBaseUrlString
            (segue.destinationViewController as! QuizzStartedViewController).movieCredits = self.movieCredits
            //(segue.destinationViewController as! QuizzStartedViewController).actorCredits = self.actorCredits
            (segue.destinationViewController as! QuizzStartedViewController).moviesList = self.moviesList
            (segue.destinationViewController as! QuizzStartedViewController).actorsList = self.actorsList
            (segue.destinationViewController as! QuizzStartedViewController).gameItem = game
        }
    }
    
    func launchGame() {
        if (self.moviesList.count > 0 && self.actorsList.count > 0) {
            
            // all credits downloaded
                // now we can laucnh a game
                if (startGameButton.enabled == false) {
                    performSegueWithIdentifier("startQuizz", sender: self)
                }
                
                // Re validate start game button
                startGameButton.enabled = true
                startGameButton.setTitle("Start", forState: .Normal)
        }
        else
        {
            print("ressources are still neeed")
        }
    }
    
    func initImbdClient() -> Bool {
        // Retrieve imbd api key form our app globals
        let appGlobals = QuizzGameHelper.getAppGlobalsDictionary()
        
        // If a default imbd api key is defined, we can started the game
        if let imbd_default_api_key: AnyObject = appGlobals["IMBD_DEFAULT_API_KEY"] {
            //println("imbd_default_api_key", imbd_default_api_key)
            
            self.imbdClient = ILMovieDBClient.sharedClient()
            self.imbdClient?.apiKey = imbd_default_api_key as! String
            return true
        }
        return false
    }

    func prepareGame() {
        
        print("Preparing ressources for the game")
        
        self.setImbdImagesBaseUrl()
        self.setPopularMoviesList(1)
        self.setPopularActorsList(1)
    }
    
    func setPopularMoviesList(pageValue: Int)
    {
        let paramaters = ["page": pageValue]
        
        self.imbdClient?.GET(ILMovieDB.kILMovieDBMoviePopular, parameters: paramaters, block: { (responseObject, error) -> Void in
            if (error != nil) {
                print("kILMovieDBMoviePopular error")
            }
            if let jsonResult = responseObject as? Dictionary<String, AnyObject> {
                if let movies: NSArray? = jsonResult["results"] as? NSArray {
                    
                    //var stop: Bool
                    movies?.enumerateObjectsUsingBlock({ (movie, index, stop) -> Void in
                        //print(movie)
                        let imbdMovieId = movie["id"] as! Int
                        self.findAndAddMovieCredits(imbdMovieId)
                    })
                    
                    self.moviesList = movies!
                }
            }
        })
    }
    
    func setPopularActorsList(pageValue: Int)
    {
        let paramaters = ["page": pageValue]
        
        self.imbdClient?.GET(ILMovieDB.kILMovieDBPeoplePopular, parameters: paramaters, block: { (responseObject, error) -> Void in
            if (error != nil) {
                print("kILMovieDBPeoplePopular error")
            }
            
            if let jsonResult = responseObject as? Dictionary<String, AnyObject> {
                if let actors: NSArray? = jsonResult["results"] as? NSArray {
                    //var actorsCount = actors?.count
                    
//                    var stop: Bool
//                    actors?.enumerateObjectsUsingBlock({ (actor, index, stop) -> Void in
//                        let imbdActorId = actor["id"] as! Int
//                        self.findAndAddActorCredits(imbdActorId)
//                    })
                    
                    self.actorsList = actors!
                }
            }
        })
    }

    func setImbdImagesBaseUrl() -> Void {
        
        self.imbdClient?.GET(ILMovieDB.kILMovieDBConfiguration, parameters: nil, block: { (responseObject, error) -> Void in
            if (error != nil) {
                print("kILMovieDBConfiguration error")
            }
            
            if let jsonResult = responseObject as? Dictionary<String, AnyObject> {
                //println(jsonResult["images"])
                if let images: NSDictionary? = jsonResult["images"] as? NSDictionary {
                    let base_url = images?.objectForKey("base_url") as! String
                    self.imbdImagesBaseUrlString = base_url.stringByAppendingString("w185")
                }
            }
        })
    }
    
    func findAndAddActorCredits(imbdActorId: Int) -> Void {
        
        let actor_credits_api_url = ILMovieDB.kILMovieDBPeopleMovieCredits.stringByReplacingOccurrencesOfString(":id", withString: String(imbdActorId))
        
        self.imbdClient?.GET(actor_credits_api_url, parameters: nil, block: { (responseObject, error) -> Void in
            if (error != nil) {
                print("kILMovieDBPeopleMovieCredits error")
            }
            
            if let jsonResult = responseObject as? Dictionary<String, AnyObject> {
                //println(jsonResult["cast"])
                if let actor_cast: NSArray? = jsonResult["cast"] as? NSArray {
                    print(actor_cast)
                    //self.actorCredits[imbdActorId] = actor_cast
                }
            }
        })
    }
    
    func findAndAddMovieCredits(imbdMovieId: Int) -> Void {
        
        let movie_credits_api_url = ILMovieDB.kILMovieDBMovieCredits.stringByReplacingOccurrencesOfString(":id", withString: String(imbdMovieId))
        
        self.imbdClient?.GET(movie_credits_api_url, parameters: nil, block: { (responseObject, error) -> Void in
            if (error != nil) {
                print("kILMovieDBMovieCredits error")
            }
            
            if let jsonResult = responseObject as? Dictionary<String, AnyObject> {
                //println(jsonResult)
                if let movie_cast: NSArray? = jsonResult["cast"] as? NSArray {
                    //println(movie_cast)
                    self.movieCredits[imbdMovieId] = movie_cast
                }
            }
        })
    }

}

