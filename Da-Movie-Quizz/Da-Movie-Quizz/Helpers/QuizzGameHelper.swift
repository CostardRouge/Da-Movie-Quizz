//
//  QuizzGameHelper
//  Da-Movie-Quizz
//
//  Created by Steeve Pommier on 15/09/15.
//  Copyright (c) 2015 CostardRouge. All rights reserved.
//

import UIKit

class QuizzGameHelper
{
    class func getAppGlobalsDictionary() -> NSDictionary
    {
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                if let globals: AnyObject = dict["Globals"] {
                    return globals as! NSDictionary
                }
            }
        }
        return NSDictionary()
    }
}


