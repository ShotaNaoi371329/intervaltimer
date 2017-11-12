//
//  TableTimerViewController.swift
//  intervaltimer
//
//  Created by 直井翔汰 on 2017/10/22.
//  Copyright © 2017年 AIT. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation
import EasyPeasy

class TableTimerViewController: UIViewController, UITableViewDelegate {
    
    var timer = Timer()
    let tableView = UITableView()
    
    let headerView = UIView()
    let plusButton = UIButton()
    let minusButton = UIButton()
    
    let footerView = UIView()
    let startPauseButton = UIButton()
    let stopButton = UIButton()
    let repeatSwitch = UISwitch()
    let repeatLabel = UILabel()
    
    var timerCounts: [Int] = [5]
    var timerMax: [Int] = [5]
    var timerNames: [String] = ["新規タイマー"]
    var secCount = 0
    var countNowTimer = 0
    var jiho:AVAudioPlayer! = nil
    var audioSession:AVAudioSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        initItem()
        initLayout()
        setAudio()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.plusButton.bounds.width > 0 {
            plusButton.layer.cornerRadius = plusButton.bounds.width / 2
            self.view.layoutIfNeeded()
        }
        
        if self.minusButton.bounds.width > 0 {
            minusButton.layer.cornerRadius = plusButton.bounds.width / 2
            self.view.layoutIfNeeded()
        }
    
        if startPauseButton.bounds.width > 0 {
            startPauseButton.layer.cornerRadius = startPauseButton.bounds.width / 2
            self.view.layoutIfNeeded()
        }
        
        if stopButton.bounds.width > 0 {
            stopButton.layer.cornerRadius = stopButton.bounds.width / 2
            self.view.layoutIfNeeded()
        }
    }
}

extension TableTimerViewController {
    
    @objc func plusButtonAction(sender: UIButton) {
        timerNames.append("新規タイマー")
        timerCounts.append(5)
        timerMax.append(5)
        tableView.reloadData()
    }
    
    @objc func minusButtonAction(sender: UIButton) {
        if timerNames.count > 1 {
            timerNames.removeLast()
            timerCounts.removeLast()
            tableView.reloadData()
        }
    }
    
    @objc func startPauseButtonAction(sender: UIButton) {
        startPauseChange(tag: sender.tag)
    }
    
    @objc func stopButtonAction(sender: UIButton) {
        startPauseChange(tag: startPauseButton.tag)
        tableView.reloadData()
        if jiho.isPlaying == true {
            jiho.stop()
        }
        self.timer.invalidate()
    }
    
    func emergingView<T: UIView>(view: T) {
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = 1.0
        })
    }
    
    func hideView<T: UIView>(view: T) {
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = 0.0
        })
    }
    
    func startPauseChange(tag: Int) {
        if tag == 0 {
            startPauseButton.setTitle("pause", for: .normal)
            emergingView(view: stopButton)
            setTimer()
            startPauseButton.tag = 1
        } else {
            startPauseButton.setTitle("start", for: .normal)
            hideView(view: stopButton)
            startPauseButton.tag = 0
        }
    }
    
    func setTimer() {
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            
            print("timerCounter:\(self.secCount)")
            
            var second = self.secCount
            second += 1
            var countTimer = self.countNowTimer
            var nowTimerCount = self.timerCounts[countTimer] - 1
            let repeatSwitchValue = self.repeatSwitch.isOn
            
            print("second = \(second) countTimer = \(countTimer) nowTimerCount = \(nowTimerCount)")
            //対象のtimerViewのテキストをカウントダウン
            if nowTimerCount == 2 { //2秒になったら音を出す。
                
                self.jiho.play()
            }
            
            //            timerLabels[countTimer].text = String(Int(timerLabels[countNowTimer].text!)! - 1)
            
            if nowTimerCount == 0 {
                
                //バイブレーション
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                //                timerLabels[self?.countNowTimer].text = String(timerSets[countNowTimer])
                second = 1
                countTimer += 1
                
                print("次のタイマー")
                
                if countTimer == self.timerCounts.count && repeatSwitchValue {
                    
                    //repeat　させる
                    countTimer = 0
                    print("timerrepeat")
                    //                jiho.stop()
                    //                try! audioSession.setActive(false)
                } else if countTimer == self.timerCounts.count && !repeatSwitchValue {
                    
                    countTimer = 0
                    //timer破棄
                    self.timer.invalidate()
                    
                    self.startPauseButton.tag = 0
                    self.startPauseButton.setTitle("start", for: .normal)
                    
                    
                    self.stopButton.isHidden = true
                    
                    self.stopButton.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    
                    print("timerReset")
                    self.timerCounts = self.timerMax
                    self.tableView.reloadData()
                } else {
                    self.timerCounts[countTimer] -= 1
                    self.tableView.reloadData()
                }
            }
            
            self.timerCounts[countTimer] -= 1
            self.tableView.reloadData()
            self.secCount = second
        }
    }
}

extension TableTimerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timerNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimerViewCell", for: indexPath) as! TimerViewCell
        cell.nameLabel.text = timerNames[indexPath.row]
        cell.timerLabel.text = String(describing: timerCounts[indexPath.row])
        cell.timerMaxLabel.text = String(describing: timerMax[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension TableTimerViewController: InputTextTableCellDelegate {
    
    func doneButtonAction(cell: TimerViewCell, value: String, tag: Int) {
        let path = tableView.indexPathForRow(at: cell.convert(cell.bounds.origin, to: tableView))
        NSLog("row = %d, value = %@", path!.row, value)
        if tag == 0 { //名前ラベル
            timerNames[path!.row] = value
        } else { //タイマーラベル
            timerCounts[path!.row] = Int(value)!
            timerMax[path!.row] = Int(value)!
            tableView.reloadRows(at: [path!], with: UITableViewRowAnimation.none)
        }
    }
}

extension TableTimerViewController: AVAudioPlayerDelegate {
    
    func setAudio () {
        let soundFilePath : String = Bundle.main.path(forResource: "/data/jihou", ofType: "caf")!
        let fileURL : URL = URL(fileURLWithPath: soundFilePath)
        
        do{
            // AVAudioPlayerのインスタンス化
            jiho = try AVAudioPlayer(contentsOf: fileURL)
            
            // AVAudioPlayerのデリゲートをセット
            jiho.delegate = self
        }
        catch{
            
            print("Failed AVAudioPlayer Instance")
        }
        //出来たインスタンスをバッファに保持する。
        jiho.prepareToPlay()
    }
}

extension TableTimerViewController {
    
    func createImageFromUIColor(color: UIColor) -> UIImage {
        // 1x1のbitmapを作成
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        // bitmapを塗りつぶし
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        // UIImageに変換
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func initItem() {
        
        plusButton.setTitle("+", for: .normal)
        plusButton.setTitleColor(UIColor.black, for: .normal)
        plusButton.layer.borderWidth = 1.0
        plusButton.layer.borderColor = UIColor.red.cgColor
        plusButton.layer.masksToBounds = true
        plusButton.addTarget(self, action: #selector(plusButtonAction(sender:)), for: .touchUpInside)
        plusButton.setBackgroundImage(self.createImageFromUIColor(color: UIColor(red: 191/255, green: 49/255, blue: 49/255, alpha: 1.0)), for: .highlighted)
        
        minusButton.setTitle("-", for: .normal)
        minusButton.setTitleColor(UIColor.black, for: .normal)
        minusButton.layer.borderWidth = 1.0
        minusButton.layer.borderColor = UIColor.blue.cgColor
        minusButton.layer.masksToBounds = true
        minusButton.addTarget(self, action: #selector(minusButtonAction(sender:)), for: .touchUpInside)
        minusButton.setBackgroundImage(self.createImageFromUIColor(color: UIColor(red: 48/255, green: 45/255, blue: 196/255, alpha: 1.0)), for: .highlighted)
        
        //        headerView.backgroundColor = UIColor.black
        headerView.addSubview(plusButton)
        headerView.addSubview(minusButton)
        
        tableView.register(TimerViewCell.self, forCellReuseIdentifier: "TimerViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        startPauseButton.setTitle("start", for: .normal)
        startPauseButton.setTitleColor(UIColor.black, for: .normal)
        startPauseButton.addTarget(self, action: #selector(startPauseButtonAction(sender:)), for: .touchUpInside)
        startPauseButton.layer.borderColor = UIColor.green.cgColor
        startPauseButton.layer.borderWidth = 1.0
        startPauseButton.tag = 0
        startPauseButton.layer.masksToBounds = true
        
        stopButton.setTitle("stop", for: .normal)
        stopButton.setTitleColor(UIColor.black, for: .normal)
        stopButton.addTarget(self, action: #selector(stopButtonAction(sender:)), for: .touchUpInside)
        stopButton.layer.borderColor = UIColor.red.cgColor
        stopButton.layer.borderWidth = 1.0
        stopButton.alpha = 0.0
        stopButton.layer.masksToBounds = true
        
        repeatSwitch.isOn = false
        repeatLabel.text = "repeat"
        
        footerView.addSubview(startPauseButton)
        footerView.addSubview(stopButton)
        footerView.addSubview(repeatSwitch)
        footerView.addSubview(repeatLabel)
        
        self.view.addSubview(headerView)
        self.view.addSubview(tableView)
        self.view.addSubview(footerView)
    }
    
    func initLayout() {
        
        layout: do {
            
            
            headerViewLayout: do {
                plusButton.easy.layout([
                    Top(UIApplication.shared.statusBarFrame.height),
                    Right(0),
                    Left(1).to(minusButton, .right),
                    Bottom(0),
                    Size(self.view.bounds.width/8)
                    ])
                
                //        print(plusButton.bounds.width)
                minusButton.easy.layout([
                    Top(UIApplication.shared.statusBarFrame.height),
                    Bottom(0),
                    Size(self.view.bounds.width/8)
                    ])
            }
            
            footerViewLayout: do {
                startPauseButton.easy.layout([
                    Top(0),
                    Bottom(0),
                    CenterX(),
                    Size(self.view.bounds.width/4)
                    ])
                
                stopButton.easy.layout([
                    CenterY(),
                    Right(5).to(startPauseButton, .left),
                    Size(self.view.bounds.width/6)
                    ])
                
                repeatSwitch.easy.layout([
                    CenterY(),
                    Left(10).to(startPauseButton, .right),
                    ])
                
                repeatLabel.easy.layout([
                    Bottom(0).to(repeatSwitch, .top),
                    Left(10).to(startPauseButton, .right)
                    ])
                
            }
            
            headerView.easy.layout([
                Top(0),
                Left(0),
                Right(0),
                Bottom(0).to(tableView, .top)
                ])
            
            tableView.easy.layout([
                Left(0),
                Right(0),
                Bottom(0).to(footerView, .top)
                ])
            
            footerView.easy.layout([
                Left(0),
                Right(0),
                Bottom(0)
                ])
            
        }
    }
}
