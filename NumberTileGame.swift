//
//  NumberTileGame.swift
//  swift-2048
//
//  Created by Spyc on 7/9/14.
//  Copyright (c) 2014 Spyc. All rights reserved.
//

import UIKit

class NumberTileGameViewController : UIViewController, GameModelProtocol {
  var dimension: Int
  var threshold: Int

  var board: GameboardView?
  var model: GameModel?

  var scoreView: ScoreViewProtocol?

  let boardWidth: CGFloat = 320.0
    // とりあえず320あたりで
    //let boardWidth: CGFloat = 230.0
  let thinPadding: CGFloat = 3.0
  let thickPadding: CGFloat = 6.0

  let viewPadding: CGFloat = 10.0

  let verticalViewOffset: CGFloat = 0.0

  init(dimension d: Int, threshold t: Int) {
    dimension = d > 2 ? d : 2
    threshold = t > 8 ? t : 8
    super.init(nibName: nil, bundle: nil)
    model = GameModel(dimension: dimension, threshold: threshold, delegate: self)
    view.backgroundColor = UIColor(red: 0.0/255.0, green: 120.0/255.0, blue: 180.0/255.0, alpha: 1.0)
    //view.backgroundColor = UIColor.whiteColor()
    setupSwipeControls()
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("fatalError")
  }

  func setupSwipeControls() {
    let upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("up:"))
    upSwipe.numberOfTouchesRequired = 1
    upSwipe.direction = UISwipeGestureRecognizerDirection.Up
    view.addGestureRecognizer(upSwipe)

    let downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("down:"))
    downSwipe.numberOfTouchesRequired = 1
    downSwipe.direction = UISwipeGestureRecognizerDirection.Down
    view.addGestureRecognizer(downSwipe)

    let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("left:"))
    leftSwipe.numberOfTouchesRequired = 1
    leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
    view.addGestureRecognizer(leftSwipe)

    let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("right:"))
    rightSwipe.numberOfTouchesRequired = 1
    rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
    view.addGestureRecognizer(rightSwipe)
  }


  override func viewDidLoad()  {
    super.viewDidLoad()
    setupGame()
  }

  func reset() {
    assert(board != nil && model != nil)
    let b = board!
    let m = model!
    b.reset()
    m.reset()
    m.insertTileAtRandomLocation(2)
    m.insertTileAtRandomLocation(2)
  }

  func setupGame() {
    let vcHeight = view.bounds.size.height
    let vcWidth = view.bounds.size.width

    func xPositionToCenterView(v: UIView) -> CGFloat {
      let viewWidth = v.bounds.size.width
      let tentativeX = 0.5*(vcWidth - viewWidth)
      return tentativeX >= 0 ? tentativeX : 0
    }
    func yPositionForViewAtPosition(order: Int, views: [UIView]) -> CGFloat {
      assert(views.count > 0)
      assert(order >= 0 && order < views.count)
      let viewHeight = views[order].bounds.size.height
      let totalHeight = CGFloat(views.count - 1)*viewPadding + views.map({ $0.bounds.size.height }).reduce(verticalViewOffset, { $0 + $1 })
      let viewsTop = 0.5*(vcHeight - totalHeight) >= 0 ? 0.5*(vcHeight - totalHeight) : 0

      var acc: CGFloat = 0
      for i in 0..<order {
        acc += viewPadding + views[i].bounds.size.height
      }
      return viewsTop + acc
    }

    let scoreView = ScoreView(backgroundColor: UIColor.blackColor(),
      textColor: UIColor.whiteColor(),
      font: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!,
      radius: 6)
    scoreView.score = 0

    let padding: CGFloat = dimension > 5 ? thinPadding : thickPadding
    let v1 = boardWidth - padding*(CGFloat(dimension + 1))
    let width: CGFloat = CGFloat(floorf(CFloat(v1)))/CGFloat(dimension)
    let gameboard = GameboardView(dimension: dimension,
      tileWidth: width,
      tilePadding: padding,
      cornerRadius: 2,
      backgroundColor: UIColor.darkGrayColor(),
      foregroundColor: UIColor.whiteColor())

    let views = [scoreView, gameboard]

    var f = scoreView.frame
    f.origin.x = xPositionToCenterView(scoreView)
    f.origin.y = yPositionForViewAtPosition(0, views)
    scoreView.frame = f

    f = gameboard.frame
    f.origin.x = xPositionToCenterView(gameboard)
    f.origin.y = yPositionForViewAtPosition(1, views)
    gameboard.frame = f

    view.addSubview(gameboard)
    board = gameboard
    view.addSubview(scoreView)
    self.scoreView = scoreView

    assert(model != nil)
    let m = model!
    m.insertTileAtRandomLocation(2)
    m.insertTileAtRandomLocation(2)
  }

  func followUp() {
    assert(model != nil)
    let m = model!
    let (userWon, winningCoords) = m.userHasWon()
    if userWon {
      let alertView = UIAlertView()
      alertView.title = "クリア!!"
      alertView.message = "2048 達成"
      alertView.addButtonWithTitle("OK")
      alertView.show()
      return
    }
    
    let randomVal = Int(arc4random_uniform(10))
    m.insertTileAtRandomLocation(randomVal == 1 ? 4 : 2)

    if m.userHasLost() {
      let alertView = UIAlertView()
      alertView.title = "ゲームオーバー"
      alertView.message = "残念orz……"
      alertView.addButtonWithTitle("OK")
      alertView.show()
    }
  }

  @objc(up:)
  func upCommand(r: UIGestureRecognizer!) {
    assert(model != nil)
    let m = model!
    m.queueMove(MoveDirection.Up,
      completion: { (changed: Bool) -> () in
        if changed {
          self.followUp()
        }
      })
  }

  @objc(down:)
  func downCommand(r: UIGestureRecognizer!) {
    assert(model != nil)
    let m = model!
    m.queueMove(MoveDirection.Down,
      completion: { (changed: Bool) -> () in
        if changed {
          self.followUp()
        }
      })
  }

  @objc(left:)
  func leftCommand(r: UIGestureRecognizer!) {
    assert(model != nil)
    let m = model!
    m.queueMove(MoveDirection.Left,
      completion: { (changed: Bool) -> () in
        if changed {
          self.followUp()
        }
      })
  }

  @objc(right:)
  func rightCommand(r: UIGestureRecognizer!) {
    assert(model != nil)
    let m = model!
    m.queueMove(MoveDirection.Right,
      completion: { (changed: Bool) -> () in
        if changed {
          self.followUp()
        }
      })
  }

  func scoreChanged(score: Int) {
    if scoreView == nil {
      return
    }
    let s = scoreView!
    s.scoreChanged(newScore: score)
  }

  func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
    assert(board != nil)
    let b = board!
    b.moveOneTile(from, to: to, value: value)
  }

  func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
    assert(board != nil)
    let b = board!
    b.moveTwoTiles(from, to: to, value: value)
  }

  func insertTile(location: (Int, Int), value: Int) {
    assert(board != nil)
    let b = board!
    b.insertTile(location, value: value)
  }
}
