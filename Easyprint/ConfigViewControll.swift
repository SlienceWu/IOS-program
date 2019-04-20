//
//  ConfigViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/16.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ConfigViewControll: UIViewController {
    
    @IBOutlet weak var chooseRateView: UIView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var sizeView: UIView!
    @IBOutlet weak var currentSizeView: UILabel!
    @IBOutlet weak var sizeBtn1: UIButton!
    @IBOutlet weak var sizeBtn2: UIButton!
    @IBOutlet weak var sizeBtn3: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        saveBtn.addTarget(self, action: #selector(saveRate), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSize))
        chooseRateView.addGestureRecognizer(tap)
        sizeBtn1.addTarget(self, action: #selector(changeSizeView1), for: .touchUpInside)
        sizeBtn2.addTarget(self, action: #selector(changeSizeView2), for: .touchUpInside)
        sizeBtn3.addTarget(self, action: #selector(changeSizeView3), for: .touchUpInside)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if PersonInfo().state() == "login" && PersonInfo.Var.currentMachine != ""{
            getBaudRate()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //显示隐藏列表
    @objc func showSize(){
        
        if sizeView.isHidden{
            saveBtn.isEnabled = false
            sizeView.isHidden = false
        } else{
            saveBtn.isEnabled = true
            sizeView.isHidden = true
        }
    }
    @objc func changeSizeView1(){
        saveBtn.isEnabled = true
        sizeView.isHidden = true
        currentSizeView.text = sizeBtn1.currentTitle
    }
    @objc func changeSizeView2(){
        saveBtn.isEnabled = true
        sizeView.isHidden = true
        currentSizeView.text = sizeBtn2.currentTitle
    }
    @objc func changeSizeView3(){
        saveBtn.isEnabled = true
        sizeView.isHidden = true
        currentSizeView.text = sizeBtn3.currentTitle
    }
    //保存波特率
    @objc func saveRate(){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        if PersonInfo.Var.currentMachine == ""{
            self.present(Alert().singleAlert(message: "Please bind a machine."), animated: true, completion: nil)
            return
        }
        if PersonInfo.Var.currentMachineState == "0"||PersonInfo.Var.currentMachineState == "1"{
            self.present(Alert().singleAlert(message: "Printer is offline."), animated: true, completion: nil)
            return
        }
        let encryStr = PersonInfo().emailAes()
        let encryStrId = AES_ECB().encypted(need: PersonInfo.Var.currentMachine)
        let url = Url.baseUsers + encryStr + "/printers/" + encryStrId
        let params = ["action": "set", "target": "printer_printing_com_baudrate", "value": currentSizeView.text! as String, "token": PersonInfo().token()] as [String: Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                self.present(Alert().singleAlert(message: "Set success."), animated: true, completion: nil)
            } else {
                if code != nil {
                    ResponseError().error(target: self, code: code!)
                } else{
                    let nsCode = (response.error! as NSError).code
                    ResponseError().errorNScode(target: self, code: nsCode)
                }
            }
        }
    }
    //获取当前波特率
    func getBaudRate(){
        let url = Url.baseUsers + PersonInfo().emailAes() + "/printers/" + AES_ECB().encypted(need: PersonInfo.Var.currentMachine)
        let params = ["action": "get", "target": "printer_printing_com_baudrate", "token": PersonInfo().token()]
        AlamofireCustom.alamofireFast.request(url, method: .post, parameters: params).responseJSON{
            response in
            let code = response.response?.statusCode
            if code == 200{
                let json = JSON(response.result.value as Any)
                let baud = json["baudrate"].stringValue
                if baud != ""{
                    self.currentSizeView.text = baud
                }
            }
        }
    }
    //返回键控制
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
    }
}
