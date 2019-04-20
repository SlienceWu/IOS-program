//
//  TempViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/16.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire

class TempViewControll: UIViewController, UITextFieldDelegate {
    //挤出头
    @IBOutlet weak var extruderTemp: UITextField!
    @IBOutlet weak var extruderSwitch: UISwitch!
    @IBOutlet weak var extruderProgress: UIProgressView!
    @IBOutlet weak var extruderTempNow: UILabel!
    let extruderMaxTemp = 250
    var isExtruderSwitch = true
    //热床
    @IBOutlet weak var hotBedTemp: UITextField!
    @IBOutlet weak var hotbedSwitch: UISwitch!
    @IBOutlet weak var hotbedProgress: UIProgressView!
    @IBOutlet weak var hotbedTempNow: UILabel!
    let hotbedMaxTemp = 120
    var isHotbedSwitch = true
    //定时器
    private var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        extruderTemp.delegate = self
        hotBedTemp.delegate = self
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        extruderSwitch.addTarget(self, action: #selector(extruderSwitchDidChange), for: .valueChanged)
        hotbedSwitch.addTarget(self, action: #selector(hotbedSwitchDidChange), for: .valueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showTemp()
        creatTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    //返回键控制
    @objc func tapBack(){
        //timer.invalidate()
        extruderTemp.resignFirstResponder()
        hotBedTemp.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    //输入键盘控制消失
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == extruderTemp{
            if isExtruderSwitch{
                setTemp(type: "extruder")
            }
        } else if textField == hotBedTemp{
            if isHotbedSwitch{
                setTemp(type: "hotbed")
            }
        }
        creatTimer()
        textField.resignFirstResponder()
        return true
    }
    @objc func handleTap(sender: UITapGestureRecognizer){
        if sender.state == .ended{
            extruderTemp.resignFirstResponder()
            hotBedTemp.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
    //限制只能输入3位数字
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        timer.invalidate()
        let length = string.lengthOfBytes(using: String.Encoding.utf8)
        for loopIndex in 0..<length{
            let char = ( string as NSString).character(at: loopIndex)
            if char < 48 { return false}
            if char > 57 { return false}
        }
        let proposeLength = (textField.text?.lengthOfBytes(using: String.Encoding.utf8))! - range.length + string.lengthOfBytes(using: String.Encoding.utf8)
        if proposeLength > 3 { return false}
        return true
    }
    //设置温度
    func setTemp(type: String){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        let machineNumber = PersonInfo.Var.currentMachine
        if machineNumber == ""{
            return
        }
        let token = PersonInfo().token()
        let encryStr = PersonInfo().emailAes()
        let encryStrId = AES_ECB().encypted(need: machineNumber)
        let url = Url.baseUsers + encryStr + "/printers/" + encryStrId
        if type == "extruder"{
            var temp = 0
            if isExtruderSwitch{
                temp = Int((self.extruderTemp.text! as NSString).intValue)
            } else {
                temp = 0
            }
            let obj = ["extruder_num": 0, "value": temp]
            let params = ["action": "set", "target": "printer_extruder_temp", "token": token, "object": obj] as [String : Any]
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
                (response) in
                let code = response.response?.statusCode
                if code != 200{
                    if code != nil {
                        if code! >= 410{
                            ResponseError().error(target: self, code: code!)
                        }
                    } else{
                        let nsCode = (response.error! as NSError).code
                        ResponseError().errorNScode(target: self, code: nsCode)
                    }
                }
            }
        } else if type == "hotbed"{
            var temp = 0
            if isHotbedSwitch{
                temp = Int((self.hotBedTemp.text! as NSString).intValue)
            } else {
                temp = 0
            }
            let params = ["action": "set", "target": "printer_bed_temp", "token": token, "value": temp] as [String : Any]
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
                (response) in
                let code = response.response?.statusCode
                if code != 200{
                    if code != nil {
                        if code! >= 410{
                            ResponseError().error(target: self, code: code!)
                        }
                    } else{
                        let nsCode = (response.error! as NSError).code
                        ResponseError().errorNScode(target: self, code: nsCode)
                    }
                }
            }
        }
    }
    //温度显示
    func showTemp(){
        let extruderTemp = (PersonInfo.Var.currentExtruderTemp as NSString).intValue
        let hotbedTemp = (PersonInfo.Var.currentHotBedTemp as NSString).intValue
        let extruderSetTemp = (PersonInfo.Var.extruderSetTemp as NSString).intValue
        let hotbedSetTemp = (PersonInfo.Var.hotBedSetTemp as NSString).intValue
        if isExtruderSwitch{
            self.extruderTemp.text = String(extruderSetTemp)
        }
        if isHotbedSwitch{
            self.hotBedTemp.text = String(hotbedSetTemp)
        }
        self.extruderTempNow.text = String(extruderTemp) + "°C"
        self.hotbedTempNow.text = String(hotbedTemp) + "°C"
        let extruderProgress = Float(extruderTemp)/250
        let hotbedProgress = Float(hotbedTemp)/120
        self.extruderProgress.setProgress(Float(extruderProgress), animated: false)
        self.hotbedProgress.setProgress(Float(hotbedProgress), animated: false)
    }
    //创建轮播图定时器
    func creatTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerManager), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    //创建定时器管理者
    @objc func timerManager(){
        if PersonInfo().state() == "logout" || PersonInfo.Var.currentMachine == ""{
            return
        }
        showTemp()
    }
    //switch监听
    @objc func extruderSwitchDidChange(){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        if isExtruderSwitch{
            isExtruderSwitch = false
        } else {
            isExtruderSwitch = true
        }
        setTemp(type: "extruder")
    }
    @objc func hotbedSwitchDidChange(){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        if isHotbedSwitch{
            isHotbedSwitch = false
        } else {
            isHotbedSwitch = true
        }
        setTemp(type: "hotbed")
    }
}
