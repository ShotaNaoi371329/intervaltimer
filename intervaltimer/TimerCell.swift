//
//  TimerCell.swift
//  intervaltimer
//
//  Created by 直井翔汰 on 2017/10/26.
//  Copyright © 2017年 AIT. All rights reserved.
//

import UIKit
import EasyPeasy

protocol InputTextTableCellDelegate {
    func doneButtonAction(cell: TimerViewCell, value: String, tag: Int) -> ()
}

class TimerViewCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: InputTextTableCellDelegate! = nil
    let nameLabel = UITextField()
    let timerLabel = UITextField()
    let slashLabel = UILabel()
    let timerMaxLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel.text = "新規タイマー"
        nameLabel.isUserInteractionEnabled = true
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.tag = 0
        nameLabel.minimumFontSize = 8
        nameLabel.textAlignment = NSTextAlignment.center
        nameLabel.contentVerticalAlignment = UIControlContentVerticalAlignment.bottom
        nameLabel.font = UIFont.systemFont(ofSize: (nameLabel.font?.pointSize)!, weight: UIFontWeightUltraLight)
        addDoneButtonOnKeyboard(nameLabel)
        //        nameLabel.backgroundColor = UIColor.black
        
        timerLabel.text = "5"
        timerLabel.isUserInteractionEnabled = true
        timerLabel.adjustsFontSizeToFitWidth = true
        timerLabel.tag = 1
        timerLabel.keyboardType = UIKeyboardType.numberPad
        timerLabel.textAlignment = NSTextAlignment.center
        timerLabel.minimumFontSize = 8
        timerLabel.contentVerticalAlignment = UIControlContentVerticalAlignment.bottom
        timerLabel.font = UIFont.systemFont(ofSize: (timerLabel.font?.pointSize)!, weight: UIFontWeightUltraLight)
        //        timerLabel.backgroundColor = UIColor.black
        addDoneButtonOnKeyboard(timerLabel)
        
        //        slashLabel.isUserInteractionEnabled = true
        slashLabel.text = "/"
        slashLabel.adjustsFontSizeToFitWidth = true
        slashLabel.textAlignment = NSTextAlignment.center
        //        slashLabel.minimumFontSize = 8
        //        slashLabel.contentVerticalAlignment = UIControlContentVerticalAlignment.bottom
        slashLabel.font = UIFont.systemFont(ofSize: (slashLabel.font?.pointSize)!, weight: UIFontWeightUltraLight)
        //        slashLabel.backgroundColor = UIColor.black
        
        timerMaxLabel.text = "5"
        timerMaxLabel.adjustsFontSizeToFitWidth = true
        //        timerMaxLabel.textAlignment = NSTextAlignment.left
        //        timerMaxLabel.contentVerticalAlignment = UIControlContentVerticalAlignment.bottom
        timerMaxLabel.textAlignment = NSTextAlignment.center
        //        timerMaxLabel.minimumFontSize = 8
        timerMaxLabel.font = UIFont.systemFont(ofSize: (timerMaxLabel.font?.pointSize)!, weight: UIFontWeightUltraLight)
        //        timerMaxLabel.backgroundColor = UIColor.black
        
        self.addSubview(nameLabel)
        self.addSubview(timerLabel)
        self.addSubview(slashLabel)
        self.addSubview(timerMaxLabel)
        
        nameLabel.easy.layout([
            CenterY(),
            Right(>=10).to(timerLabel, .left),
            Left(<=16),
            Width((self.bounds.width/2))
            ])
        
        timerLabel.easy.layout([
            CenterY(),
            Right(>=8).to(slashLabel, .left),
            Width(50)
            ])
        
        slashLabel.easy.layout([
            CenterY(),
            Right(>=8).to(timerMaxLabel, .left),
            Width(25)
            ])
        
        timerMaxLabel.easy.layout([
            CenterY(),
            Right(<=16),
            Width(50)
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addDoneButtonOnKeyboard(_ textField: UITextField) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction(sender:)))
        done.tag = textField.tag
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction(sender: UIBarButtonItem) {
        print(sender.tag)
        self.endEditing(true)
        
        if sender.tag == 0 {
            self.delegate.doneButtonAction(cell: self, value: nameLabel.text!, tag: sender.tag)
        } else {
            self.delegate.doneButtonAction(cell: self, value: timerLabel.text!, tag: sender.tag)
        }
    }
}
