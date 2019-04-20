//
//  FilamentViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/16.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire

class FilamentViewControll: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var extruderProgress: UIProgressView!
    @IBOutlet weak var extruderTemp: UILabel!
    @IBOutlet weak var extruderSetTemp: UILabel!
    @IBOutlet weak var heatUp: UIButton!
    @IBOutlet weak var load: UIView!
    @IBOutlet weak var unLoad: UIView!
    //定时器
    var timer:Timer!
    //挤出头当前状态
    var mState = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        
        heatUp.addTarget(self, action: #selector(textFieldAlert), for: UIControlEvents.touchUpInside)
        
        let tapLoad = UITapGestureRecognizer(target: self, action: #selector(loadFilament))
        load.addGestureRecognizer(tapLoad)
        let tapUnLoad = UITapGestureRecognizer(target: self, action: #selector(unloadFilament))
        unLoad.addGestureRecognizer(tapUnLoad)
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
        self.navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
    @objc func textFieldAlert(){
        
        if PersonInfo().state() == "logout" {
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        } else if PersonInfo.Var.currentMachine == ""{
            self.present(Alert().singleAlert(message: "Please bind a print."), animated: true, completion: nil)
            return
        }
        if PersonInfo.Var.currentMachineState == "0" || PersonInfo.Var.currentMachineState == "1"{
            self.present(Alert().singleAlert(message: "Machine is offline."), animated: true, completion: nil)
            return
        }
        let alert = UIAlertController(title: "", message: "Set printer extruder temp", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "0-250"
            textField.delegate = self
        })
        let cancel = UIAlertAction(title: "cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let ok = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: {(UIAlertAction) in
            let temp = alert.textFields![0]
            let need = Int(temp.text!)
            
            if PersonInfo().state() == "logout" || PersonInfo.Var.currentMachine == ""{
                return
            }
            if need == nil{
                self.present(Alert().singleAlert(message: "Please write something."), animated: true, completion: nil)
                return
            }
            let machineNumber = PersonInfo.Var.currentMachine
            let token = PersonInfo().token()
            let encryStr = PersonInfo().emailAes()
            let encryStrId = AES_ECB().encypted(need: machineNumber)
            let url = Url.baseUsers + encryStr + "/printers/" + encryStrId
            if need! > 250{
                self.present(Alert().singleAlert(message: "Param is too large."), animated: true, completion: nil)
            }
            let obj = ["extruder_num": 0, "value": need]
            let params = ["action": "set", "target": "printer_extruder_temp", "token": token, "object": obj] as [String : Any]
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
                (response) in
                let code = response.response?.statusCode
                if code != 200{
                    if code != nil{
                        ResponseError().error(target: self, code: code!)
                    } else{
                        let nsCode = (response.error! as NSError).code
                        ResponseError().errorNScode(target: self, code: nsCode)
                    }
                }
            }
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    //限制只能输入3位数字
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
    func showTemp(){
        let extruderInt = (PersonInfo.Var.currentExtruderTemp as NSString).intValue
        extruderTemp.text = PersonInfo.Var.currentExtruderTemp + "°C"
        extruderSetTemp.text = PersonInfo.Var.extruderSetTemp + "°C"
        let progress = Float(extruderInt)/250
        extruderProgress.setProgress(progress, animated: false)
    }
    //进料出料
    @objc func loadFilament(){
        if mState == 0{
            mState = 1
            setFilament(step: "step_in")
        }
    }
    @objc func unloadFilament(){
        if mState == 0{
            mState = 2
            setFilament(step: "step_out")
        }
    }
    func setFilament(step: String){
        if PersonInfo().state() == "logout" {
            mState = 0
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        } else if PersonInfo.Var.currentMachine == ""{
            mState = 0
            self.present(Alert().singleAlert(message: "Please bind a print."), animated: true, completion: nil)
            return
        }
        if PersonInfo.Var.currentMachineState == "0" || PersonInfo.Var.currentMachineState == "1"{
            mState = 0
            self.present(Alert().singleAlert(message: "Machine is offline."), animated: true, completion: nil)
            return
        }
        let machineNumber = PersonInfo.Var.currentMachine

        let token = PersonInfo().token()
        let encryStr = PersonInfo().emailAes()
        let encryStrId = AES_ECB().encypted(need: machineNumber)
        let url = Url.baseUsers + encryStr + "/printers/" + encryStrId
        let obj = ["extruder_num": 0, "direction": step, "value": 20] as [String : Any]
        let params = ["action": "set", "target": "printer_extruder_feed", "token": token, "object": obj] as [String : Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            self.mState = 0
            let code = response.response?.statusCode
            if code != 200{
                if code != nil {
                    ResponseError().error(target: self, code: code!)
                } else{
                    let nsCode = (response.error! as NSError).code
                    ResponseError().errorNScode(target: self, code: nsCode)
                }
            }
        }
    }
    //
    
}
//自定义view点击效果
class UIViewEffect: UIView {
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        backgroundColor = UIColor(red: 28/255, green: 132/255, blue: 1, alpha: 1)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.backgroundColor = UIColor(red: 28/255, green: 142/255, blue: 1, alpha: 1)
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.backgroundColor = UIColor(red: 28/255, green: 142/255, blue: 1, alpha: 1)
        })
    }
}
