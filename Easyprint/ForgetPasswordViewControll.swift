//
//  ForgetPasswordViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/7.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ForgetPasswordViewControll: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var needCode: UITextField!
    @IBOutlet weak var getCode: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    //初始化验证时间
    var timer:Timer!
    var time = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userEmail.delegate = self
        needCode.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        // Do any additional setup after loading the view, typically from a nib.
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.navigationItem.title = "ForgetPassword"
        getCode.addTarget(self, action: #selector(getACode), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(nextBtnClick), for: UIControlEvents.touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tapBack(){
        if self.getCode.currentTitle  != "Get secutity code"{
            timer.invalidate()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    //键盘弹起
    @IBAction func beginEdit(_ sender: UITextField){
        animateViewMoving(up: true, moveValue: 100)
    }
    @IBAction func endEdit(_ sender: UITextField){
        animateViewMoving(up: false, moveValue: 100)
    }
    func animateViewMoving(up: Bool, moveValue: CGFloat){
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    //输入键盘控制消失
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func handleTap(sender: UITapGestureRecognizer){
        if sender.state == .ended{
            userEmail.resignFirstResponder()
            needCode.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
    //next 点击事件
    @objc func nextBtnClick(){
        userEmail.resignFirstResponder()
        needCode.resignFirstResponder()
        
        if self.getCode.currentTitle == "Get secutity code"{
            self.present(Alert().singleAlert(message: "Please get secutity code."), animated: true, completion: nil)
            return
        } else{
            if needCode.text?.count == 6{
                let url = Url.baseUsers
                let obj = ["email": userEmail.text, "code": needCode.text]
                let params = ["action": "verify", "target": "user_vcode", "object": obj] as [String : Any]
                PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
                PersonInfo.shadowView.startTheView()
                AlamofireCustom.alamofireManager.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default).response{
                    (response) in
                    PersonInfo.shadowView.stopAndRemoveFromSuperView()
                    let code = response.response?.statusCode
                    if code! == 200{
                        self.getCode.isEnabled = true
                        self.getCode.setTitle("Get secutity code", for: .normal)
                        self.timer.invalidate()
                        self.performSegue(withIdentifier: "resetPassword", sender: self.userEmail.text)
                    } else if code == 401{
                        self.present(Alert().singleAlert(message: "Verification code error."), animated: true, completion: nil)
                    } else if code == 404{
                        self.present(Alert().singleAlert(message: "Make sure your email is correct"), animated: true, completion: nil)
                    } else{
                        if code != nil {
                            ResponseError().error(target: self, code: code!)
                        } else{
                            let nsCode = (response.error! as NSError).code
                            ResponseError().errorNScode(target: self, code: nsCode)
                        }
                    }
                }
            } else{
                self.present(Alert().singleAlert(message: "Verification code error."), animated: true, completion: nil)
                return
            }
        }
    }
    @objc func getACode(){
        let email = userEmail.text! as String
        let regEmail = "^[A-Z0-9a-z._-]+@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*\\.[a-zA-Z0-9]{2,6}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEmail)
        let isEmailValid = predicate.evaluate(with: email)
        if isEmailValid{
            let url = Url.baseUsers
            let params = ["action": "verify", "target": "user_email", "value": email] as [String: String]
            PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
            PersonInfo.shadowView.startTheView()
            AlamofireCustom.alamofireManager.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default).response{
                (response) in
                PersonInfo.shadowView.stopAndRemoveFromSuperView()
                let code = response.response?.statusCode
                if code == 201{
                    self.creatTimer()
                    self.present(Alert().singleAlert(message: "Please check your mailbox."), animated: true, completion: nil)
                } else if code == 409{
                    self.present(Alert().singleAlert(message: "The mailbox is not registered."), animated: true, completion: nil)
                } else{
                    if code != nil {
                        ResponseError().error(target: self, code: code!)
                    } else{
                        let nsCode = (response.error! as NSError).code
                        ResponseError().errorNScode(target: self, code: nsCode)
                    }
                }
            }
        } else{
            self.present(Alert().singleAlert(message: "Please enter the correct mailbox."), animated: true, completion: nil)
        }
    }
    //创建定时器
    func creatTimer(){
        self.getCode.isEnabled = false
        getCode.setTitle("60s ", for: .normal)
        time = 60
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerManager), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    //创建定时器管理者
    @objc func timerManager(){
        time = time - 1
        if time == 0{
            self.getCode.isEnabled = true
            getCode.setTitle("Get secutity code", for: .normal)
            timer.invalidate()
            return
        }
        let timeStr = String(time) + "s "
        getCode.setTitle(timeStr, for: .normal)
    }
    //跳转传值
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resetPassword"{
            let controller = segue.destination as! ResetPasswordViewControll
            controller.resetEmail = sender as? String
        }
    }
    
}
