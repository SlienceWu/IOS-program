//
//  MenuViewControll.swift
//  Easyprint
//
//  Created by app on 2018/8/28.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class MenuViewControll: UIViewController{
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    //屏幕宽度
    let width = UIScreen.main.bounds.size.width
    //打印机在线列表
    var onlineList = [JSON()]
    //打印机不在线列表
    var offlineList = [JSON()]
    //定时器
    var timer:Timer!
    var isTimerOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(skipToLogin))
        if PersonInfo().state() == "login"{
            userName.text = PersonInfo().name()
            if PersonInfo().avatar() != ""{
                let url = URL(string: PersonInfo().avatar())
                userImg.kf.setImage(with: url)
            }
        } else{
            userName.isUserInteractionEnabled = true
            userName.addGestureRecognizer(tap)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        print("menu show")
        print(PersonInfo.Var.currentMachineList)
        if PersonInfo().state() == "login"{
            //getListInfo()
            creatTimer()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("menu hide")
        if isTimerOn{
            isTimerOn = false
            timer.invalidate()
        }
    }
    
    //创建定时器 获取打印机列表信息
    func creatTimer(){
        self.isTimerOn = true
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getListInfo), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    @objc func getListInfo(){
        let encryStr = PersonInfo().emailAes()
        let token = PersonInfo().token()
        let url = Url.baseUsers + encryStr + "/printersinfo?token=" + token;
        AlamofireCustom.alamofireFast.request(url).responseJSON{
            (response) in
            if response.response?.statusCode == 200{
                let json = response.result.value as Any
                let list = JSON(json)
                self.scrollView.subviews.forEach({$0.removeFromSuperview()})
                self.onlineList.removeAll()
                self.offlineList.removeAll()
                if list.count == 0{
                    return
                }
                for i in 0 ... (list.count - 1){
                    print(list[i])
                    //let name = list[i]["name"].stringValue
                    let state = list[i]["state"].stringValue
                    //let number = list[i]["serial_num"].stringValue
                    
                    if state == "0" || state == "1"{
                        self.offlineList.append(list[i])
                    } else{
                        self.onlineList.append(list[i])
                    }
                }
                if self.onlineList.count != 0{
                    for i in 0...(self.onlineList.count - 1){
                        let avatar = self.onlineList[i]["image"].stringValue
                        let progress = self.onlineList[i]["progress"].stringValue
                        let heatbed = self.onlineList[i]["bed_current_temp"].stringValue
                        let extruder = self.onlineList[i]["extruder_current_temp"].stringValue
                        
                        let state = self.onlineList[i]["state"].stringValue
                        let number = self.onlineList[i]["serial_num"].stringValue
                        
                        let view = UIView()
                        view.frame = CGRect(x: 0, y: i * 100, width: Int(self.width - 60), height: 120)
                        let machineImg = UIImageView()
                        machineImg.frame = CGRect(x: 10, y: 10, width: 80, height: 80)
                        if avatar == ""{
                            if number.contains("E180"){
                                machineImg.image = UIImage(named: "icon_e180")
                            } else if number.contains("D200"){
                                machineImg.image = UIImage(named: "icon_d200")
                            } else if number.contains("A30"){
                                machineImg.image = UIImage(named: "icon_a30")
                            } else {
                                machineImg.image = UIImage(named: "icon_3dwifi")
                            }
                        }else{
                            let url = URL(string: avatar)
                            machineImg.kf.setImage(with: url)
                        }
                        view.addSubview(machineImg)
                        
                        let nameLabel = UILabel()
                        nameLabel.frame = CGRect(x: 100, y: 0, width: (self.width - 160)/2, height: 30)
                        nameLabel.textAlignment = .left
                        nameLabel.font = UIFont.systemFont(ofSize: 14)
                        nameLabel.text = self.onlineList[i]["name"].stringValue
                        view.addSubview(nameLabel)
                        
                        let stateLabel = UILabel()
                        stateLabel.frame = CGRect(x: self.width/2 + 20, y: 0, width: (self.width - 180)/2, height: 30)
                        stateLabel.textAlignment = .right
                        stateLabel.font = UIFont.systemFont(ofSize: 14)
                        if state == "2"{
                            stateLabel.text = "Online"
                        } else if state == "3"{
                            stateLabel.text = "Printing"
                        } else if state == "4"{
                            stateLabel.text = "Pause"
                        }
                        stateLabel.textColor = UIColor(red: 24/255, green: 128/255, blue: 1, alpha: 1)
                        view.addSubview(stateLabel)
                        
                        let backView = UIView()
                        backView.frame = CGRect(x: 100, y: 30, width: self.width - 170, height: 20)
                        backView.backgroundColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1)
                        let progressView = UIProgressView(progressViewStyle: .default)
                        progressView.frame = CGRect(x: 1, y: 9, width: self.width - 172, height: 18)
                        //progressView.progressTintColor = UIColor.white
                        progressView.trackTintColor = UIColor.white
                        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 9.0)
                        progressView.progress = Float(progress)!
                        backView.addSubview(progressView)
                        view.addSubview(backView)
                        let progressNum = UILabel()
                        progressNum.frame = CGRect(x: 100, y: 30, width: self.width - 170, height: 20)
                        progressNum.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
                        progressNum.text = String(progressView.progress * 100) + "%"
                        progressNum.textAlignment = .center
                        progressNum.font = UIFont.systemFont(ofSize: 14)
                        view.addSubview(progressNum)
                        
                        let label1 = UILabel()
                        label1.frame = CGRect(x: 100, y: 54, width: (self.width - 170)/2, height: 18)
                        label1.textAlignment = .center
                        label1.font = UIFont.systemFont(ofSize: 14)
                        label1.text = "Heatbed"
                        view.addSubview(label1)
                        let label2 = UILabel()
                        label2.frame = CGRect(x: 100, y: 72, width: (self.width - 170)/2, height: 18)
                        label2.textAlignment = .center
                        label2.font = UIFont.systemFont(ofSize: 14)
                        label2.text = heatbed + "°C"
                        view.addSubview(label2)
                        
                        let borderView = UIView()
                        borderView.frame = CGRect(x: 100 + (self.width - 170)/2, y: 54, width: 2, height: 36)
                        borderView.backgroundColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1)
                        view.addSubview(borderView)
                        
                        let label3 = UILabel()
                        label3.frame = CGRect(x: 100 + (self.width - 170)/2, y: 54, width: (self.width - 170)/2, height: 18)
                        label3.textAlignment = .center
                        label3.font = UIFont.systemFont(ofSize: 14)
                        label3.text = "Extruder"
                        view.addSubview(label3)
                        let label4 = UILabel()
                        label4.frame = CGRect(x: 100 + (self.width - 170)/2, y: 72, width: (self.width - 170)/2, height: 18)
                        label4.textAlignment = .center
                        label4.font = UIFont.systemFont(ofSize: 14)
                        label4.text = extruder + "°C"
                        view.addSubview(label4)
                        
                        let borderBottom = UIView()
                        borderBottom.frame = CGRect(x: 0, y: 99, width: self.width, height: 1)
                        borderBottom.backgroundColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1)
                        view.addSubview(borderBottom)
                        
                        view.isUserInteractionEnabled = true
                        view.isMultipleTouchEnabled = true
                        view.tag = i
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onlineMachine(sender:)))
                        view.addGestureRecognizer(tap)
                        self.scrollView.addSubview(view)
                    }
                }
                if self.offlineList.count != 0{
                    //未在线打印机
                    for i in 0 ... (self.offlineList.count - 1){
                        let view = UIView()
                        view.frame = CGRect(x: 0, y: (i + self.onlineList.count) * 100 , width: Int(self.width - 60), height: 120)
                        let machineImg = UIImageView()
                        machineImg.frame = CGRect(x: 10, y: 10, width: 80, height: 80)
                        machineImg.image = UIImage(named: "printer_off")
                        view.addSubview(machineImg)
                        
                        let nameLabel = UILabel()
                        nameLabel.frame = CGRect(x: 100, y: 0, width: (self.width - 160)/2, height: 30)
                        nameLabel.textAlignment = .left
                        nameLabel.font = UIFont.systemFont(ofSize: 14)
                        nameLabel.text = self.offlineList[i]["name"].stringValue
                        view.addSubview(nameLabel)
                        
                        let stateLabel = UILabel()
                        stateLabel.frame = CGRect(x: self.width/2 + 20, y: 0, width: (self.width - 180)/2, height: 30)
                        stateLabel.textAlignment = .right
                        stateLabel.font = UIFont.systemFont(ofSize: 14)
                        stateLabel.text = "Offline"
                        stateLabel.textColor = UIColor(red: 24/255, green: 128/255, blue: 1, alpha: 1)
                        view.addSubview(stateLabel)
                        
                        let backView = UIView()
                        backView.frame = CGRect(x: 100, y: 30, width: self.width - 170, height: 20)
                        backView.backgroundColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1)
                        let progressView = UIProgressView(progressViewStyle: .default)
                        progressView.frame = CGRect(x: 1, y: 9, width: self.width - 172, height: 18)
                        //progressView.backgroundColor = UIColor.white
                        //progressView.progressTintColor = UIColor.white
                        progressView.trackTintColor = UIColor.white
                        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 9.0)
                        progressView.progress = 0.0
                        backView.addSubview(progressView)
                        view.addSubview(backView)
                        let progressNum = UILabel()
                        progressNum.frame = CGRect(x: 100, y: 30, width: self.width - 170, height: 20)
                        progressNum.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
                        progressNum.text = "0%"
                        progressNum.textAlignment = .center
                        progressNum.font = UIFont.systemFont(ofSize: 14)
                        view.addSubview(progressNum)
                        
                        let label1 = UILabel()
                        label1.frame = CGRect(x: 100, y: 54, width: (self.width - 170)/2, height: 18)
                        label1.textAlignment = .center
                        label1.font = UIFont.systemFont(ofSize: 14)
                        label1.text = "Heatbed"
                        view.addSubview(label1)
                        let label2 = UILabel()
                        label2.frame = CGRect(x: 100, y: 72, width: (self.width - 170)/2, height: 18)
                        label2.textAlignment = .center
                        label2.font = UIFont.systemFont(ofSize: 14)
                        label2.text = "0°C"
                        view.addSubview(label2)
                        
                        let borderView = UIView()
                        borderView.frame = CGRect(x: 100 + (self.width - 170)/2, y: 54, width: 2, height: 36)
                        borderView.backgroundColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1)
                        view.addSubview(borderView)
                        
                        let label3 = UILabel()
                        label3.frame = CGRect(x: 100 + (self.width - 170)/2, y: 54, width: (self.width - 170)/2, height: 18)
                        label3.textAlignment = .center
                        label3.font = UIFont.systemFont(ofSize: 14)
                        label3.text = "Extruder"
                        view.addSubview(label3)
                        let label4 = UILabel()
                        label4.frame = CGRect(x: 100 + (self.width - 170)/2, y: 72, width: (self.width - 170)/2, height: 18)
                        label4.textAlignment = .center
                        label4.font = UIFont.systemFont(ofSize: 14)
                        label4.text = "0°C"
                        view.addSubview(label4)
                        
                        let borderBottom = UIView()
                        borderBottom.frame = CGRect(x: 0, y: 99, width: self.width, height: 1)
                        borderBottom.backgroundColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1)
                        view.addSubview(borderBottom)
                        
                        view.isUserInteractionEnabled = true
                        view.isMultipleTouchEnabled = true
                        view.tag = i
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.offlineMachine(sender:)))
                        view.addGestureRecognizer(tap)
                        self.scrollView.addSubview(view)
                    }
                }
                let all = (self.onlineList.count + self.offlineList.count) * 100
                self.scrollView.contentSize = CGSize(width: self.width - 60, height: CGFloat(all))
            }
        }
    }
    //选中在线打印机
    @objc func onlineMachine(sender: UIGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        print(self.onlineList[tag!]["serial_num"])
        PersonInfo.Var.currentMachine = self.onlineList[tag!]["serial_num"].stringValue
        PersonInfo.Var.currentMachineName = self.onlineList[tag!]["name"].stringValue
        PersonInfo.Var.currentMachineImg = self.onlineList[tag!]["image"].stringValue
        let a = self.parent as! ViewController
        a.animateMainView(shouldExpand: false)
    }
    //选中未在线打印机
    @objc func offlineMachine(sender: UIGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        print(self.offlineList[tag!]["serial_num"])
        PersonInfo.Var.currentMachine = self.offlineList[tag!]["serial_num"].stringValue
        PersonInfo.Var.currentMachineName = self.offlineList[tag!]["name"].stringValue
        PersonInfo.Var.currentMachineImg = self.offlineList[tag!]["image"].stringValue
        let a = self.parent as! ViewController
        a.animateMainView(shouldExpand: false)
    }
    //未登录跳转
    @objc func skipToLogin(){
        let a = self.parent as! ViewController
        a.animateMainView(shouldExpand: false)
        let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView")
        let c = a.childViewControllers[0].childViewControllers[0] as! UITabBarController
        c.selectedViewController?.childViewControllers[0].navigationController!.pushViewController(loginView, animated: true)
        //print("123")
    }
}
