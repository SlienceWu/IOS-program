//
//  MoveViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/16.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire

class MoveViewControll: UIViewController {
    
    @IBOutlet weak var topBtn: UIButton!
    @IBOutlet weak var bottomBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var homeBtn: UIImageView!
    @IBOutlet weak var xHomeBtn: UIView!
    @IBOutlet weak var yHomeBtn: UIView!
    @IBOutlet weak var zHomeBtn: UIView!
    @IBOutlet weak var zUpBtn: UIButton!
    @IBOutlet weak var zDownBtn: UIButton!
    @IBOutlet weak var moveDistance: UILabel!
    @IBOutlet weak var chooseDistance: UIView!
    
    @IBOutlet weak var sizeView: UIView!
    @IBOutlet weak var sizeBtn1: UIButton!
    @IBOutlet weak var sizeBtn2: UIButton!
    @IBOutlet weak var sizeBtn3: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSize))
        chooseDistance.addGestureRecognizer(tap)
        sizeBtn1.addTarget(self, action: #selector(changeDistance1), for: .touchUpInside)
        sizeBtn2.addTarget(self, action: #selector(changeDistance2), for: .touchUpInside)
        sizeBtn3.addTarget(self, action: #selector(changeDistance3), for: .touchUpInside)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(setModel(tapView:)))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(setModel(tapView:)))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(setModel(tapView:)))
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(setModel(tapView:)))
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(setModel(tapView:)))
        let tap6 = UITapGestureRecognizer(target: self, action: #selector(setModel(tapView:)))
        let home1 = UITapGestureRecognizer(target: self, action: #selector(setModelHome(tapView:)))
        let home2 = UITapGestureRecognizer(target: self, action: #selector(setModelHome(tapView:)))
        let home3 = UITapGestureRecognizer(target: self, action: #selector(setModelHome(tapView:)))
        let home4 = UITapGestureRecognizer(target: self, action: #selector(setModelHome(tapView:)))
        topBtn.tag = 1
        topBtn.addGestureRecognizer(tap1)
        bottomBtn.tag = 2
        rightBtn.addGestureRecognizer(tap2)
        rightBtn.tag = 3
        bottomBtn.addGestureRecognizer(tap3)
        leftBtn.tag = 4
        leftBtn.addGestureRecognizer(tap4)
        zUpBtn.tag = 5
        zUpBtn.addGestureRecognizer(tap5)
        zDownBtn.tag = 6
        zDownBtn.addGestureRecognizer(tap6)
        homeBtn.isUserInteractionEnabled = true
        homeBtn.tag = 1
        homeBtn.addGestureRecognizer(home1)
        xHomeBtn.tag = 2
        xHomeBtn.addGestureRecognizer(home2)
        yHomeBtn.tag = 3
        yHomeBtn.addGestureRecognizer(home3)
        zHomeBtn.tag = 4
        zHomeBtn.addGestureRecognizer(home4)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //返回键控制
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
    //显示可选移动距离
    @objc func showSize(){
        if sizeView.isHidden{
            sizeView.isHidden = false
        } else{
            sizeView.isHidden = true
        }
    }
    @objc func changeDistance1(){
        sizeView.isHidden = true
        moveDistance.text = sizeBtn1.currentTitle
    }
    @objc func changeDistance2(){
        sizeView.isHidden = true
        moveDistance.text = sizeBtn2.currentTitle
    }
    @objc func changeDistance3(){
        moveDistance.text = sizeBtn3.currentTitle
        sizeView.isHidden = true
    }
    //移动操作
    @objc func setModel(tapView: UIGestureRecognizer){
        let loginState = PersonInfo().state()
        if loginState == "logout"  || loginState == ""{
            let alert = UIAlertController(title: "", message: "message", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(cancel)
            self.present(Alert().singleAlert(message: "Please log in"), animated: true, completion: nil)
            return
        }
        let view = tapView.view!
        let viewTag = view.tag
        var axis = "x"
        var state = 0
        if viewTag == 1{
            state = 0
            axis = "y"
        } else if viewTag == 2{
            state = 1
            axis = "y"
        } else if viewTag == 3{
            state = 0
            axis = "x"
        } else if viewTag == 4{
            state = 1
            axis = "x"
        } else if viewTag == 5{
            state = 0
            axis = "z"
        } else if viewTag == 6{
            state = 1
            axis = "z"
        }
        let encryStr = PersonInfo().emailAes()
        let machineNumber = PersonInfo.Var.currentMachine
        if machineNumber == ""{
            self.present(Alert().singleAlert(message: "Please bind a machine."), animated: true, completion: nil)
            return
        }
        let machineState = PersonInfo.Var.currentMachineState
        if machineState == "0"{
            self.present(Alert().singleAlert(message: "Printer is offline."), animated: true, completion: nil)
            return
        } else if machineState == "1"{
            self.present(Alert().singleAlert(message: "Printer is logout."), animated: true, completion: nil)
            return
        } else if machineState == "3" || machineState == "4"{
            self.present(Alert().singleAlert(message: "Printer is printing."), animated: true, completion: nil)
            return
        }
        let encryStrId = AES_ECB().encypted(need: machineNumber)
        let url = Url.baseUsers + encryStr + "/printers/" + encryStrId
        var value = 10
        if state == 0{
            value = Int(moveDistance.text!)!
        } else {
            value = -Int(moveDistance.text!)!
        }
        let obj = ["axis": axis, "position": "relative", "value": value] as [String : Any]
        let params = ["action": "set", "target": "printer_motor", "token": PersonInfo().token(), "object": obj] as [String : Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                //print("move success")
            } else {
                //print("move fail")
                if code != nil {
                    ResponseError().error(target: self, code: code!)
                } else{
                    let nsCode = (response.error! as NSError).code
                    ResponseError().errorNScode(target: self, code: nsCode)
                }
            }
        }
    }
    //归位
    @objc func setModelHome(tapView: UIGestureRecognizer){
        let loginState = PersonInfo().state()
        if loginState == "logout" || loginState == ""{
            let alert = UIAlertController(title: "", message: "message", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(cancel)
            self.present(Alert().singleAlert(message: "Please log in"), animated: true, completion: nil)
            return
        }
        let view = tapView.view!
        let viewTag = view.tag
        var axis = "all"
        if viewTag == 1{
            axis = "all"
        } else if viewTag == 2{
            axis = "x"
        } else if viewTag == 3{
            axis = "y"
        } else if viewTag == 4{
            axis = "z"
        }
        let encryStr = PersonInfo().emailAes()
        let machineNumber = PersonInfo.Var.currentMachine
        if machineNumber == ""{
            self.present(Alert().singleAlert(message: "Please bind a machine"), animated: true, completion: nil)
            return
        }
        let machineState = PersonInfo.Var.currentMachineState
        if machineState == "0"{
            self.present(Alert().singleAlert(message: "Printer is offline."), animated: true, completion: nil)
            return
        } else if machineState == "1"{
            self.present(Alert().singleAlert(message: "Printer is logout."), animated: true, completion: nil)
            return
        } else if machineState == "3" || machineState == "4"{
            self.present(Alert().singleAlert(message: "Printer is printing."), animated: true, completion: nil)
            return
        }
        let encryStrId = AES_ECB().encypted(need: machineNumber)
        let url = Url.baseUsers + encryStr + "/printers/" + encryStrId

        let params = ["action": "reset", "target": "printer_motor", "token": PersonInfo().token(), "object": ["axis": axis]] as [String : Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                //print("move success")
            } else {
                //print("move fail")
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
