//
//  ViewController.swift
//  Heatmap_demo
//
//  Created by Detchat Boonpragob on 27/3/2562 BE.
//  Copyright © 2562 qmul. All rights reserved.
//

import UIKit



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        LocationSession.sharedInstance.startUpdateLocation()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            HeatmapSession.sharedInstance.addInteraction(touch.location(in: self.view))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            HeatmapSession.sharedInstance.addInteraction(touch.location(in: self.view))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            HeatmapSession.sharedInstance.addInteraction(touch.location(in: self.view))
        }
    }

    @IBAction func uploadLog(_ sender: Any) {
        HeatmapSession.sharedInstance.uploadLog()
    }
}

