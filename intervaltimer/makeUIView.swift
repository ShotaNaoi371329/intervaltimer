//
//  makeUIView.swift
//  intervaltimer
//
//  Created by x15071xx on 2017/06/25.
//  Copyright © 2017年 AIT. All rights reserved.
//

extension UIView
{
    func copyView<T: Any>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
    
}



import UIKit

class makeUIView: UIViewController, UIToolbarDelegate{
    
    private var nameLabel: UITextField!
    private var timerLabel: UITextField!
    private var timermaxLabel: UILabel!
    var timerLabelHeight: CGFloat!
    var middlePoint: CGFloat!
    var fontSize: CGFloat!
    private var Labels: [UITextField]! = []
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    func setup() {
        // init のなかみ
        timerLabelHeight = self.view.bounds.height / 6
        
        middlePoint = (self.view.bounds.width/2 - ((self.view.bounds.width/32+self.view.bounds.width/2 + self.view.bounds.width/16+self.view.bounds.width/4)/2)) / 2
        
        nameLabel = UITextField(frame: CGRect(x: self.view.bounds.width/32+middlePoint, y: 0, width: self.view.bounds.width/2 - self.view.bounds.width/32, height: timerLabelHeight))
        
        //nameLabel.backgroundColor = UIColor.white
        nameLabel.tag = 1
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addUnderline(width: 2.0, color: UIColor.gray)
        nameLabel.text = "新規タイマー"
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumFontSize = 8
        nameLabel.textAlignment = NSTextAlignment.center
        nameLabel.contentVerticalAlignment = UIControlContentVerticalAlignment.bottom
        fontSize = nameLabel.bounds.width/8
        nameLabel.font = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightUltraLight)
//        nameLabel.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        
        timerLabel = UITextField(frame: CGRect(x: self.view.bounds.width/2 + self.view.bounds.width/16+middlePoint, y: 0, width: self.view.bounds.width/4, height: timerLabelHeight))
        //timerLabel.backgroundColor = UIColor.white
        timerLabel.isUserInteractionEnabled = true
        timerLabel.tag = 2
        timerLabel.addUnderline(width: 1.0, color: UIColor.black)
        timerLabel.keyboardType = UIKeyboardType.numberPad
        timerLabel.text = "5"
        timerLabel.adjustsFontSizeToFitWidth = true
        timerLabel.textAlignment = NSTextAlignment.center
        timerLabel.minimumFontSize = 8
        timerLabel.contentVerticalAlignment = UIControlContentVerticalAlignment.bottom
        timerLabel.font = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightUltraLight)
        
        timermaxLabel = UILabel(frame: CGRect(x: self.timerLabel.layer.position.x + self.timerLabel.bounds.width*3/4, y: timerLabelHeight/2, width: self.view.bounds.width/4, height: timerLabelHeight/2))
        //timermaxLabel.isUserInteractionEnabled = true
        timermaxLabel.text = "/ 5"
        timermaxLabel.adjustsFontSizeToFitWidth = true
        timermaxLabel.textAlignment = NSTextAlignment.left
        //timermaxLabel.baselineAdjustment = UIBaselineAdjustment.alignCenters
        timermaxLabel.font = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightUltraLight)
        
//        Labels.append(nameLabel)
//        Labels.append(timerLabel)
        
    }

    
    func getname() -> UITextField {
        return nameLabel.copyView()
    }
    
    func gettimer() -> UITextField {
        return timerLabel.copyView()
    }
    
    func gettimermax() -> UILabel {
        return timermaxLabel.copyView()
    }
}
