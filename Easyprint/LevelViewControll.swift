//
//  LevelViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/16.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire

class LevelViewControll: UIViewController {
    
    @IBOutlet weak var topLeft: UIButton!
    @IBOutlet weak var topRight: UIButton!
    @IBOutlet weak var center: UIButton!
    @IBOutlet weak var bottomLeft: UIButton!
    @IBOutlet weak var bottomRight: UIButton!
    @IBOutlet weak var moveUp: UIButton!
    @IBOutlet weak var moveDown: UIButton!
    @IBOutlet weak var moveSave: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        topLeft.addTarget(self, action: #selector(tap1), for: UIControlEvents.touchUpInside)
        topRight.addTarget(self, action: #selector(tap2), for: UIControlEvents.touchUpInside)
        center.addTarget(self, action: #selector(tap5), for: UIControlEvents.touchUpInside)
        bottomLeft.addTarget(self, action: #selector(tap4), for: UIControlEvents.touchUpInside)
        bottomRight.addTarget(self, action: #selector(tap3), for: UIControlEvents.touchUpInside)
        moveUp.addTarget(self, action: #selector(tap6), for: UIControlEvents.touchUpInside)
        moveDown.addTarget(self, action: #selector(tap7), for: UIControlEvents.touchUpInside)
        moveSave.addTarget(self, action: #selector(tap8), for: UIControlEvents.touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        setHome()
    }
    override func viewWillDisappear(_ animated: Bool) {
        getBack()
    }
    //返回键控制
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
    }
    //调平控制
    @objc func tap1(){
        setLevel(move: "move", position: "1")
    }
    @objc func tap2(){
        setLevel(move: "move", position: "2")
    }
    @objc func tap3(){
        setLevel(move: "move", position: "3")
    }
    @objc func tap4(){
        setLevel(move: "move", position: "4")
    }
    @objc func tap5(){
        setLevel(move: "move", position: "5")
    }
    @objc func tap6(){
        setLevel(move: "up", position: "0.5")
    }
    @objc func tap7(){
        setLevel(move: "down", position: "0.5")
    }
    @objc func tap8(){
        setLevel(move: "save", position: "0.5")
    }
    func setLevel(move: String, position: String){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        if PersonInfo.Var.currentMachine == ""{
            self.present(Alert().singleAlert(message: "Please bind a machine."), animated: true, completion: nil)
            return
        }
        if PersonInfo.Var.currentMachineState == "0"{
            self.present(Alert().singleAlert(message: "Printer is offline."), animated: true, completion: nil)
            return
        } else if PersonInfo.Var.currentMachineState == "1"{
            self.present(Alert().singleAlert(message: "Printer is logout."), animated: true, completion: nil)
            return
        } else if PersonInfo.Var.currentMachineState == "3"||PersonInfo.Var.currentMachineState == "4"{
            self.present(Alert().singleAlert(message: "Printer is printing."), animated: true, completion: nil)
            return
        }
        let token = PersonInfo().token()
        let encryStr = PersonInfo().emailAes()
        let machineNumber = PersonInfo.Var.currentMachine
        let encryStrId = AES_ECB().encypted(need: machineNumber)
        let obj = ["do": move, "value": position]
        let url = Url.baseUsers + encryStr + "/printers/" + encryStrId
        let params = ["action": "set", "target": "printer_leveling", "token": token, "object": obj] as [String : Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
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
    //开始调平归位
    func setHome(){
        if PersonInfo().state() == "logout"{
            return
        }
        if PersonInfo.Var.currentMachine == ""{
            return
        }
        if PersonInfo.Var.currentMachineState == "2"{
            let token = PersonInfo().token()
            let encryStr = PersonInfo().emailAes()
            let machineNumber = PersonInfo.Var.currentMachine
            let encryStrId = AES_ECB().encypted(need: machineNumber)
            let url = Url.baseUsers + encryStr + "/printers/" + encryStrId
            let params = ["action": "reset", "target": "printer_leveling", "token": token]
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
                (response) in
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
    }
    //退出调平归位
    func getBack(){
        if PersonInfo().state() == "logout"{
            return
        }
        if PersonInfo.Var.currentMachine == ""{
            return
        }
        if PersonInfo.Var.currentMachineState == "2"{
            let token = PersonInfo().token()
            let encryStr = PersonInfo().emailAes()
            let machineNumber = PersonInfo.Var.currentMachine
            let encryStrId = AES_ECB().encypted(need: machineNumber)
            let url = Url.baseUsers + encryStr + "/printers/" + encryStrId
            let obj = ["axis": "all"]
            let params = ["action": "reset", "target": "printer_motor", "token": token, "object": obj] as [String : Any]
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
                (response) in
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
    }
}
