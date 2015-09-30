//
//  QuizzEndedViewController
//  Da-Movie-Quizz
//
//  Created by Steeve Pommier on 14/09/15.
//  Copyright (c) 2015 CostardRouge. All rights reserved.
//

import UIKit

class QuizzEndedViewController: UIViewController {

    @IBOutlet weak var scoreValueLabel: UILabel!
    @IBOutlet weak var roundValueLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    
    var gameItem: QuizzGame?
    
    // GUI : Label handlers
    func getRoundCountLabelText(roundCount: Int) -> String {
        return String(format: "#%d", roundCount)
    }
    
    func getScoreCountLabelText(scoreCount: Int) -> String {
        return String(format: "%dpt", scoreCount)
    }
    
    func updateScoreCountLabelText(scoreCount: Int) {
        if let _scoreCountLabel = self.scoreValueLabel {
            _scoreCountLabel.text = self.getScoreCountLabelText(scoreCount)
        }
    }
    
    func updateRoundCountLabelText(roundCount: Int) {
        if let _roundCountLabel = self.roundValueLabel {
            _roundCountLabel.text = self.getRoundCountLabelText(roundCount)
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let game: QuizzGame = self.gameItem {
            updateScoreCountLabelText(game.scoreCount)
            updateRoundCountLabelText(game.roundCount)
            timeValueLabel.text = String(format: "%d sec.", game.timePlayed)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("QuizzEndedViewController viewDidLoad")
        self.configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        print("QuizzEndedViewController viewWillAppear")
        
        let leftButton = UIBarButtonItem(title: "Replay", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("popToRoot"))
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    func popToRoot() {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

