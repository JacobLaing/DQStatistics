//
//  DrawersPopupViewController.swift
//  DQ Statistics
//
//  Created by Jacob Laing on 5/1/19.
//  Copyright © 2019 Jacob Laing. All rights reserved.
//

import UIKit

class DrawersPopupViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func cancelButton_TouchUpInside(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func addButton_TouchUpInside(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
