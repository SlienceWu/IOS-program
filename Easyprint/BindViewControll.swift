//
//  BindViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/23.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire

class BindViewControll: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var machineNumber: UITextField!
    @IBOutlet weak var bindBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        machineNumber.delegate = self
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        self.navigationItem.title = "Printers"
        bindBtn.addTarget(self, action: #selector(bindPrinter), for: UIControlEvents.touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //返回键控制
    @objc func tapBack(){
        machineNumber.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    //输入键盘控制消失
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func handleTap(sender: UITapGestureRecognizer){
        if sender.state == .ended{
            machineNumber.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
    @objc func bindPrinter(){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        let number = machineNumber.text! as String
        if number == ""{
            self.present(Alert().singleAlert(message: "Can't be empty"), animated: true, completion: nil)
            return
        }
        let token = PersonInfo().token()
        let encryStr = PersonInfo().emailAes()
        let url = Url.baseUsers + encryStr
        let params = ["action": "add", "target": "user_printer", "serial_num": number, "token": token]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                self.tapBack()
            } else if code == 400{
                self.present(Alert().singleAlert(message: "Invalid params."), animated: true, completion: nil)
            } else if code == 410{
                self.present(Alert().singleAlert(message: "The serial number does not exist, please check it."), animated: true, completion: nil)
            } else if code == 409{
                self.present(Alert().singleAlert(message: "The printer has been bound with another device, please check it."), animated: true, completion: nil)
            } else {
                if code != nil {
                    //if code! >= 500{
                        ResponseError().error(target: self, code: code!)
                    //}
                } else{
                    let nsCode = (response.error! as NSError).code
                    ResponseError().errorNScode(target: self, code: nsCode)
                }
            }
        }
    }
}
