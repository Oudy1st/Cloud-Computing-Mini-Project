//
//  InAppViewController.swift
//  Heatmap_demo
//
//  Created by Detchat Boonpragob on 28/3/2562 BE.
//  Copyright © 2562 qmul. All rights reserved.
//

import UIKit

class InAppViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let task = HeatmapService.getHeatmapInApp("", handler: { (wsResponse, error) in
          var errorMsg = ""
            if error != nil {
                errorMsg = error!.localizedDescription
            }
            else if let response = wsResponse
            {
                if let str = response.data {
                    
                    do {
                        let list = try JSONDecoder().decode([HeatmapScreen].self, from: str.data(using: String.Encoding.utf8)!)
                        
                        DispatchQueue.main.async {
                            self.genHeatmap(list)
                        }
                    }
                    catch {
                        errorMsg = response.message ?? "no data"
                    }
                    
                    return
                }
                else
                {
                    errorMsg = response.message ?? "no data"
                }
            }
            
            print(errorMsg)
            
        })
        
        task.resume()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func genHeatmap(_ heatmapScreenList:[HeatmapScreen]) {
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        let displaySize = self.view.frame.size
        let max = heatmapScreenList.max { $0.count! < $1.count! }?.count ?? 0
        
        if max == 0 {
            print("cannot display")
            return
        }
        for heatmap in heatmapScreenList {
            if let x = heatmap.position?[0],
                let y = heatmap.position?[1],
                let counter = heatmap.count{
                
                let margin:CGFloat  = 2
                let view = UIView.init(frame: CGRect.init(x: x*displaySize.width - margin, y: y*displaySize.height - margin, width: 1 + (margin*2), height:1 + (margin*2)))
                view.backgroundColor = UIColor.init(red: 255, green: 0, blue: 0, alpha: CGFloat(counter)/CGFloat(max))
                self.view.addSubview(view)
            }
        }
    }
}
