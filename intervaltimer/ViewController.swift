//
//  ViewController.swift
//  intervaltimer
//
//  Created by x15071xx on 2017/06/22.
//  Copyright © 2017年 AIT. All rights reserved.
//
import UIKit
import AudioToolbox
import AVFoundation
import EasyPeasy

class ViewController: UIViewController, UITextFieldDelegate, UIToolbarDelegate, AVAudioPlayerDelegate {
    
    var backGroundTimer: Timer = Timer()
    
    //ボタンとか場所が動いたりとかはしない比較的静的なアイテム
    var advertisementLabel: UILabel!
    var startStopLabel: UIButton!
    var stopLabel: UIButton!
    var plusLabel: UIButton!
    var minusLabel: UIButton!
    var statusBarH: CGFloat!
    var pmlabelHeight: CGFloat!
    var startStopLabelSide: CGFloat!
    
    var timerScrollView: UIScrollView!
    
    var scrollheihght: CGFloat!
    var timerLabelHeight: CGFloat!
    var middlePoint: CGFloat!
    var LRMargin: CGFloat!
    var LabelsWidth:CGFloat!
    
    var makeView = makeUIView()

    var timerCount: Int!
    var nameLabels: [UITextField] = []
    var timerLabels: [UITextField] = []
    var hugeNum = 10000000
    var slashLabels:[UITextField] = []
    var timermaxLabels:[UITextField] = []
    
    var tagCount: Int = 6
    var timerSets: [Int] = []
    var timer: Timer!
    var timerSecCount: Int = 0
    var countSetsnow: Int = 0
    var timerflag: Bool = false
    var repeatSwitch: UISwitch!
    var repeatLabel:UILabel!
    var jiho:AVAudioPlayer! = nil
    var audioSession:AVAudioSession!
    var AnimateAlpha: CGFloat! = 0.8
    
    //編集中のtextFieldのtagを記憶する変数
    var editingTexttag: Int = -1
    var tmpTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        //updating()
        statusBarH = UIApplication.shared.statusBarFrame.height
        pmlabelHeight = self.view.bounds.height/10
        startStopLabelSide = self.view.bounds.height*2.5/16
        
        //あまり動きのないラベルを追加する関数
        initLabels()
        
        //timerCountの初期設定
        timerCount = 0
        //timerLabelHeight の初期設定
        timerLabelHeight = makeUIView().timerLabelHeight
        middlePoint = makeUIView().middlePoint
        LRMargin = makeUIView().LRMargin
        LabelsWidth = makeUIView().LabelsWidth
        
        //scrollview
        setScrollView()
        //nameLabel, timerLabel, slashLabel, timermaxLabelの追加
        addLabels()
        
        setRepeatSwitch()
        setAudio()
    }
    
    func ButtonTap(sender: UIButton){
        
        //1,2 startstopLabelの処理
        //3   stopLabelの処理
        //4,5 プラスマイナスラベルの処理
        
        if sender.tag == -1 {
            //timerを作る
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            
            if !timerflag {
                //timerflagがtrueならpauseから戻ってきた時なので減らさない
                timerLabels[countSetsnow].text = String(Int(timerLabels[countSetsnow].text!)! - 1)
            }
            
            startStopLabel.tag = -2
            startStopLabel.setTitle("pause", for: .normal)
            
            UIView.animate(withDuration: 0.5,
                           animations:{
                                            self.startStopLabel.backgroundColor = UIColor(red: 49/255, green: 247/255, blue: 46/255, alpha: self.AnimateAlpha)
                                       },
                           completion: nil
            )
            
            stopLabel.isHidden = false
            UIView.animate(withDuration: 0.5,
                           animations:{
                            self.stopLabel.backgroundColor = UIColor(red: 224/255, green: 57/255, blue: 57/255, alpha: self.AnimateAlpha)
            },
                           completion: nil
            )
            
            //
            if timerSets[countSetsnow] - timerSecCount <= 2{ //音
//                audioSession = AVAudioSession.sharedInstance()
//                try! audioSession.setCategory(AVAudioSessionCategoryPlayback, with: .duckOthers)
                self.jiho.play()
            }
            
            //timermaxLabelsを見えるようにする
            timermaxLabelsisHidden()
            
            timerflag = false
        } else if sender.tag == -2 {
            //timer破棄
            timer.invalidate()
            
            startStopLabel.tag = -1
            startStopLabel.setTitle("start", for: .normal)
            UIView.animate(withDuration: 0.3,
                           animations:{
                            self.startStopLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: self.AnimateAlpha)
            },
                           completion: nil
            )
            stopLabel.isHidden = true
            
            stopLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            if timerSets[countSetsnow] - timerSecCount <= 2 && jiho.isPlaying{ //音
                self.jiho.pause()
            }
            
            //timermaxLabelsを消す
            timermaxLabelsisHidden()
            
            timerflag = true
        } else if sender.tag == -3 {
            //timer破棄
            timer.invalidate()
            if jiho.isPlaying {
                jiho.stop()
            }
            //カウントダウンしちゃった分をもどす
            timerLabels[countSetsnow].text = String(timerSets[countSetsnow])
            
            //カウント初期化
            timerSecCount = 0
            startStopLabel.tag = -1
            UIView.animate(withDuration: 0.3,
                           animations:{
                            self.stopLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: self.AnimateAlpha)
            },
                           completion: nil
            )
            startStopLabel.setTitle("start", for: .normal)
            UIView.animate(withDuration: 0.3,
                           animations:{
                            self.startStopLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: self.AnimateAlpha)
            },
                           completion: nil
            )
            
            stopLabel.isHidden = true
            
            stopLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else if sender.tag == -4 {
            
            print("plusLabel")
            plusLabelFunc()
        } else if sender.tag == -5 {
            
            print("minusLabel")
            minusLabelFunc()
        }
    }
    
    //文字が入力可能になった直後
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //tagを記憶
        print("\n\\n\n\n\n\ntextfiel.tag ======== \(textField.tag)\n\n\n\n")
        
        if textField.tag >= hugeNum { //slashLabel timermaxLabel
            
            textField.resignFirstResponder()
        } else {
            
            editingTexttag = (textField.tag) / 2
            tmpTextField = textField
        }
        
    }
    
    //入力が完了する前
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        //奇数の時はtimerLabel
        if textField.tag%2 == 1 {
            
            timerSets[(textField.tag-1)%2] = Int(textField.text!)!
            
            timermaxLabels[(textField.tag-1)%2].text = textField.text!
        }
        
        textField.resignFirstResponder()
        return true
        
    }
    
    //plusLabelが押されたときの処理
    func plusLabelFunc() {
        
        print(timerCount)
        
        //nameLabel, timerLabel, slashLabel, timermaxLabelの追加
        
        if timerCount > 0 {
            addLabels()
        }
        
        timerScrollView.contentSize = CGSize(width: self.view.bounds.width, height: CGFloat(timerCount)*timerLabelHeight)
        
    }
    
    func minusLabelFunc() {
        
        let tmpCount = Int(timerCount)
        
        print("\n\n\(tmpCount)")
        
        if timerCount-1 > 0 {
            
            timerCount = timerCount - 1
            //+5はタグの初期値分
            let delview1 = timerScrollView.viewWithTag(timerCount*2)
            let delview2 = timerScrollView.viewWithTag(timerCount*2 + 1)
            let delmaxTimer = timerScrollView.viewWithTag(hugeNum + timerCount)
            
            delview1?.removeFromSuperview()
            delview2?.removeFromSuperview()
            delmaxTimer?.removeFromSuperview()
            
            nameLabels.removeLast()
            timerLabels.removeLast()
            timermaxLabels.removeLast()
            
            //timerSetsの中身を消す
            timerSets.removeLast()
        }
    }

    //ナンバーパッドにdoneボタンをつける
    func addDoneButtonOnKeyboard(_ textField: UITextField) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        
//        print(editingTexttag)
        //timerを入れ替える
        timerSets[editingTexttag] = Int(tmpTextField.text!)!

        //timerSet中身確認用
//        var count: Int = 0
//        for x in timerSets {
//            print("count \(count):\(x)")
//            count += 1
//        }
        
        //textLineを閉じる
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    var counttmpmtmpmtp:Int = 0
    
    func update(_ timer: Timer) {
        
        timerSecCount += 1
        
        print("timerCountr:\(timerSecCount)")
        //対象のtimerViewのテキストをカウントダウン
        if timerSets[countSetsnow] - timerSecCount == 2 { //2秒になったら音を出す。
            
            self.jiho.play()
        }
        
        timerLabels[countSetsnow].text = String(Int(timerLabels[countSetsnow].text!)! - 1)
        
        if timerSets[countSetsnow] == timerSecCount {
            
            //バイブレーション
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            timerLabels[countSetsnow].text = String(timerSets[countSetsnow])
            timerSecCount = 0
            countSetsnow += 1
            
            print("次のタイマー")
            counttmpmtmpmtp+=1
            print(counttmpmtmpmtp)
            if countSetsnow == timerSets.count && repeatSwitch.isOn {

                //repeat　させる
                countSetsnow = 0
                print("timerrepeat")
//                jiho.stop()
//                try! audioSession.setActive(false)
            } else if countSetsnow == timerSets.count && !repeatSwitch.isOn {
                
                countSetsnow = 0
                //timer破棄
                timer.invalidate()
                
                startStopLabel.tag = -1
                startStopLabel.setTitle("start", for: .normal)
                UIView.animate(withDuration: 0.3,
                               animations:{
                                self.startStopLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: self.AnimateAlpha)
                },
                               completion: nil
                )
                stopLabel.isHidden = true
                
                stopLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                
                timermaxLabelsisHidden()
                
                print("timerReset")
            } else {
                
                timerLabels[countSetsnow].text = String(Int(timerLabels[countSetsnow].text!)! - 1)
            }
        }
    }
    
    func timermaxLabelsisHidden() {
        
        var bool = true
        
        if timermaxLabels[0].isHidden == true { //消えている状態
            
            bool = false
        }
        
        for tmLabel in timermaxLabels {
            
            
          
            if bool == true {
                //徐々に消す
                tmLabel.alpha = 1.0
                
                UIView.animate(withDuration: 0.5,
                               animations:{
                                
                                    tmLabel.alpha = 0.0
                                
                                },
                               completion: { _ in
                                    tmLabel.isHidden = bool
                                }
                )
                
                
            } else if bool == false {
                //徐々に見えるように
                tmLabel.isHidden = bool
                tmLabel.alpha = 0.0
                UIView.animate(withDuration: 0.5,
                               animations:{
                                
                                    tmLabel.alpha = 1.0
                                },
                               completion: nil
                )
            }
        }
    }
}

//layout関連
extension ViewController {
    
    func setScrollView() {
        
        scrollheihght = self.view.bounds.height-advertisementLabel.bounds.height-startStopLabel.bounds.height-pmlabelHeight
        
        timerScrollView = UIScrollView(frame: CGRect(x: 0, y: pmlabelHeight, width: self.view.bounds.width, height: scrollheihght))
        
        timerScrollView.contentSize = CGSize(width: self.view.bounds.width, height: CGFloat(1)*timerLabelHeight)
        timerScrollView.backgroundColor = UIColor.white
        timerScrollView.isUserInteractionEnabled = true
        timerScrollView.tag = 0
        self.view.addSubview(timerScrollView)
    }
    
    func setRepeatSwitch() {
        
        repeatSwitch = UISwitch()
        
        repeatSwitch.layer.position = CGPoint(x: self.view.bounds.width*5/6, y: self.view.bounds.height - advertisementLabel.bounds.height - startStopLabelSide/2)
        
        repeatSwitch.tintColor = UIColor.black
        
        self.view.addSubview(repeatSwitch)
        
        //        let repeatLabelHeight =
        repeatLabel = UILabel(frame: CGRect(x:self.view.bounds.width*5/6 - startStopLabelSide/2, y: repeatSwitch.layer.position.y, width: startStopLabelSide, height: startStopLabelSide/2))
        repeatLabel.text = "repeat"
        //        repeatLabel.backgroundColor = UIColor.blue
        repeatLabel.textAlignment = NSTextAlignment.center
        
        self.view.addSubview(repeatLabel)
    }
    
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
    func initLabels(){
        
        //ひとまず広告のサイズがわからないので設定しておく
        let admobheight = self.view.bounds.height/16
        
        //広告ラベル　（大きさは決め打ち）
        advertisementLabel = UILabel(frame: CGRect(x: 0, y: self.view.bounds.height - admobheight, width: self.view.bounds.width, height: admobheight))
        
        advertisementLabel.text = "広告が入るよ"
        
        self.view.addSubview(advertisementLabel)
        
        //スタートストップラベル
        
        startStopLabel = UIButton(frame: CGRect(x: self.view.bounds.width/2 - startStopLabelSide/2, y: self.view.bounds.height - advertisementLabel.bounds.height - startStopLabelSide , width: startStopLabelSide, height: startStopLabelSide))
        
        startStopLabel.layer.masksToBounds = true
        // コーナーの半径を設定する.
        startStopLabel.layer.cornerRadius = startStopLabel.bounds.width/2
        startStopLabel.layer.borderWidth = 1
        startStopLabel.layer.borderColor = UIColor(red: 49/255, green: 247/255, blue: 46/255, alpha: 1.0).cgColor
        startStopLabel.setTitle("start", for: .normal)
        startStopLabel.titleLabel?.font = UIFont.systemFont(ofSize: startStopLabelSide*3 / 16, weight: UIFontWeightUltraLight)
        startStopLabel.setTitleColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), for: .normal)
        startStopLabel.tag = -1
        //startStopLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        startStopLabel.addTarget(self, action: #selector(ButtonTap(sender:)), for: .touchUpInside)
        startStopLabel.setBackgroundImage(self.createImageFromUIColor(color: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0/2)), for: .highlighted)
        
        self.view.addSubview(startStopLabel)
        
        //エンドラベル
        stopLabel = UIButton(frame: CGRect(x: self.view.bounds.width/2 - startStopLabelSide*1.5, y: self.view.bounds.height - advertisementLabel.bounds.height - startStopLabelSide*3 / 4, width: startStopLabelSide*3 / 4 , height: startStopLabelSide*3 / 4))
        
        stopLabel.layer.borderWidth = 1
        stopLabel.layer.borderColor = UIColor(red: 224/255, green: 57/255, blue: 57/255, alpha: 1.0).cgColor
        
        stopLabel.layer.masksToBounds = true //コーナの有効化
        stopLabel.layer.cornerRadius = stopLabel.bounds.width/2// コーナーの半径を設定する.
        stopLabel.setTitle("stop", for: .normal)
        stopLabel.titleLabel?.font = UIFont.systemFont(ofSize: startStopLabelSide*3 / 16, weight: UIFontWeightUltraLight)
        stopLabel.setTitleColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), for: .normal)
        stopLabel.tag = -3
        stopLabel.addTarget(self, action: #selector(ButtonTap(sender:)), for: .touchUpInside)
        //stopLabel.backgroundColor = UIColor.blue
        stopLabel.isHidden = true
        stopLabel.setBackgroundImage(self.createImageFromUIColor(color: UIColor(red: 191/255, green: 49/255, blue: 49/255, alpha: 1.0)), for: .highlighted)
        self.view.addSubview(stopLabel)
        
        
        //プラスラベル
        plusLabel = UIButton(frame: CGRect(x: self.view.bounds.width-(pmlabelHeight+statusBarH)/1.8, y: statusBarH, width: pmlabelHeight-statusBarH, height: pmlabelHeight-statusBarH))
        
        plusLabel.layer.masksToBounds = true //コーナの有効化
        plusLabel.layer.cornerRadius = plusLabel.bounds.width/2// コーナーの半径を設定する.
        plusLabel.layer.borderWidth = 1
        plusLabel.layer.borderColor = UIColor(red: 224/255, green: 57/255, blue: 57/255, alpha: 1.0).cgColor
        plusLabel.setTitle("+", for: .normal)
        plusLabel.setTitleColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), for: .normal)
        plusLabel.titleLabel?.font = UIFont.systemFont(ofSize: startStopLabelSide*3 / 16, weight: UIFontWeightUltraLight)
        plusLabel.addTarget(self, action: #selector(ButtonTap(sender:)), for: .touchUpInside)
        //plusLabel.backgroundColor = UIColor(red: 224/255, green: 57/255, blue: 57/255, alpha: 1.0)
        plusLabel.tag = -4
        plusLabel.setBackgroundImage(self.createImageFromUIColor(color: UIColor(red: 191/255, green: 49/255, blue: 49/255, alpha: 1.0)), for: .highlighted)
        self.view.addSubview(plusLabel)
        
        //マイナスラベル
        minusLabel = UIButton(frame: CGRect(x: self.view.bounds.width - (pmlabelHeight+statusBarH)*1.2, y: statusBarH, width: plusLabel.bounds.height, height: plusLabel.bounds.height))
        minusLabel.layer.masksToBounds = true //コーナの有効化
        minusLabel.layer.cornerRadius = minusLabel.bounds.width/2// コーナーの半径を設定する.
        minusLabel.layer.borderWidth = 1
        minusLabel.layer.borderColor = UIColor(red: 60/255, green: 57/255, blue: 247/255, alpha: 1.0).cgColor
        minusLabel.setTitle("-", for: .normal)
        minusLabel.setTitleColor(UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0), for: .normal)
        minusLabel.titleLabel?.font = UIFont.systemFont(ofSize: startStopLabelSide*3 / 16, weight: UIFontWeightUltraLight)
        minusLabel.addTarget(self, action: #selector(ButtonTap(sender:)), for: .touchUpInside)
        //minusLabel.backgroundColor = UIColor(red: 60/255, green: 57/255, blue: 247/255, alpha: 1.0)
        minusLabel.tag = -5
        minusLabel.setBackgroundImage(self.createImageFromUIColor(color: UIColor(red: 48/255, green: 45/255, blue: 196/255, alpha: 1.0)), for: .highlighted)
        
        self.view.addSubview(minusLabel)
    }
    
    func addLabels() {
        
        let tmpname = makeView.getname()
        let tmptimer = makeView.gettimer()
        let tmpmaxtimer = makeView.gettimermax()
        
        //frameを追加
        tmpname.frame = CGRect(x: 0 + LRMargin, y: timerLabelHeight*CGFloat(timerCount), width: LabelsWidth/2 - LRMargin, height: timerLabelHeight)
        tmptimer.frame = CGRect(x: self.view.bounds.width/2 , y: timerLabelHeight*CGFloat(timerCount), width: LabelsWidth/4, height: timerLabelHeight)
        tmpmaxtimer.frame = CGRect(x: self.view.bounds.width/2 + LabelsWidth/4, y: timerLabelHeight*CGFloat(timerCount), width: LabelsWidth/4, height: timerLabelHeight)
        
        //Labelに下線を追加
        addUnderline(view: tmpname, width: 1.0, color: UIColor.gray)
        addUnderline(view: tmptimer, width: 1.0, color: UIColor.gray)
        addUnderline(view: tmpmaxtimer, width: 1.0, color: UIColor.gray)
        
        //tmpmaxtimerを隠しておく
        tmpmaxtimer.isHidden = true
        
        //配列に追加
        nameLabels.append(tmpname)
        timerLabels.append(tmptimer)
        timermaxLabels.append(tmpmaxtimer)
        
        //タグ付け
        nameLabels[timerCount].tag = timerCount * 2
        timerLabels[timerCount].tag = timerCount * 2 + 1
        timermaxLabels[timerCount].tag = hugeNum + timerCount
        
        //デリゲートを設定
        nameLabels[timerCount].delegate = self
        timerLabels[timerCount].delegate = self
        timermaxLabels[timerCount].delegate = self
        
        addDoneButtonOnKeyboard(timerLabels[timerCount])
        
        timerSets.append(5)
        
        timerScrollView.addSubview(nameLabels[timerCount])
        timerScrollView.addSubview(timerLabels[timerCount])
        timerScrollView.addSubview(timermaxLabels[timerCount])
        
        timerCount = timerCount + 1
    }
    
    func addUnderline<T: UIView>(view: T, width: CGFloat, color: UIColor) {
        
        let border = CALayer()
        border.frame = CGRect(x: 0, y: view.frame.height - width, width: view.frame.width, height: width)
        border.backgroundColor = color.cgColor
        view.layer.addSublayer(border)
    }
    
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
}

