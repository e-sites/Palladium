//
//  ViewController.swift
//  PalladiumExample
//
//  Created by Bas van Kuijck on 10/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import UIKit
import UserNotifications
import Palladium

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func tapAuthorize() {
        Palladium.shared.requestAuthorization { error in
            print("Authorization result: \(String(describing: error))")
        }
    }

    @IBAction func tapSchedule() {
        let content = UNMutableNotificationContent()
        content.body = "This is a notification"
        content.title = "\(Date())"
        var metaData = MetaData(id: "123")
        metaData.tags = [ "tag1", "tag2" ]
        let date = Date(timeIntervalSinceNow: 5)
        Palladium.shared.add(content: content, in: metaData, at: date) { request, error in
            print("Scheduled: \(String(describing: request)), error: \(String(describing: error))")
        }
    }

    @IBAction func tapCancel() {
        Palladium.shared.cancelNotifications(tags: [ "tag2" ]) { identifiers, error in
            print("Cancelled: \(identifiers?.count ?? 0), error: \(String(describing: error))")
        }
    }
}

