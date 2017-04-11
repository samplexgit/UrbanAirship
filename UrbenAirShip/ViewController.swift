//
//  ViewController.swift
//  UrbenAirShip
//
//  Created by Shilp_m on 4/5/17.
//  Copyright © 2017 Photon. All rights reserved.
//

import UIKit
import AirshipKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let dt = UAirship.push().deviceToken
        print(dt as Any)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func addTag(_ sender: Any) {
        UAirship.push().addTag("TestTag")
        UAirship.push().updateRegistration()
    }
    
    @IBAction func RemoveTag(_ sender: Any) {
        UAirship.push().removeTag("TestTag")
        UAirship.push().updateRegistration()
    }
    
    
}

