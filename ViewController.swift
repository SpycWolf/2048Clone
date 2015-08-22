//
//  ViewController.swift
//  swift-2048
//
//  Created by Spyc on 7/9/14.
//  Copyright (c) 2014 Spyc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  @IBAction func startGameButtonTapped(sender : UIButton) {
    // dimension 8とかだと死ぬ
    let game = NumberTileGameViewController(dimension: 8, threshold: 2048)
    self.presentViewController(game, animated: true, completion: nil)
  }
}

