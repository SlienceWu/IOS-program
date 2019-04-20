//
//  RegisterViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/7.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewControll: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var leftBtn: UINavigationItem!
    //地区
    @IBOutlet weak var userArea: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userRePassword: UITextField!
    @IBOutlet weak var postBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.delegate = self
        userEmail.delegate = self
        userPassword.delegate = self
        userRePassword.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        // Do any additional setup after loading the view, typically from a nib.
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.navigationItem.title = "Register"
        //地区查询
        Alamofire.request("http://ip-api.com/json").responseJSON{
            (returnResult) in
            if let json = returnResult.result.value{
                let list = json as! [String: AnyObject]
                let area = list["country"] as! String
                self.userArea.text = area
            }
        }
        postBtn.addTarget(self, action: #selector(getPost), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //注册
    @objc func getPost(){
        let name = userName.text
        let regName = "^[a-zA-Z0-9-_\\[\\]]{3,15}$"
        let predicate1 = NSPredicate(format: "SELF MATCHES %@", regName)
        let isNameValid = predicate1.evaluate(with: name)
        let email = userEmail.text
        let regEmail = "^[A-Z0-9a-z._-]+@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*\\.[a-zA-Z0-9]{2,6}$"
        let predicate2 = NSPredicate(format: "SELF MATCHES %@", regEmail)
        let isEmailValid = predicate2.evaluate(with: email)
        let password = userPassword.text
        let regPassword = "^[A-Z0-9a-z!@#$%^&*()_+\\[\\]{}:;,]{7,24}$"
        let predicate3 = NSPredicate(format: "SELF MATCHES %@", regPassword)
        let isPasswordValid = predicate3.evaluate(with: password)
        let passwords = userRePassword.text
        var area = userArea.text
        if area == ""{
            area = "China"
        }
        if !isNameValid{
            self.present(Alert().singleAlert(message: "Invalid user name."), animated: true, completion: nil)
            return
        }
        if (email?.count)! < 1 || !isEmailValid{
            self.present(Alert().singleAlert(message: "Invalid Email address."), animated: true, completion: nil)
            return
        }
        if password == passwords{
            if !isPasswordValid{
                self.present(Alert().singleAlert(message: "Invalid Password."), animated: true, completion: nil)
                return
            }
        }else{
            self.present(Alert().singleAlert(message: "Passwords don't match."), animated: true, completion: nil)
            return
        }
        let url = Url.baseUsers
        let obj = ["email": email, "password": password?.md5(), "name": name, "area": area]
        let params = ["action": "add", "target": "user", "object": obj] as [String : Any]
        PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
        PersonInfo.shadowView.startTheView()
        AlamofireCustom.alamofireManager.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            PersonInfo.shadowView.stopAndRemoveFromSuperView()
            let code = response.response?.statusCode
            if code == 201{
                self.present(Alert().textAlert(message: "Please check your email to verify your account."), animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                    self.tapBack()
                })
            } else if code == 400{
                self.present(Alert().singleAlert(message: "Params are wrong!"), animated: true, completion: nil)
            } else if code == 409{
                self.present(Alert().singleAlert(message: "Email is exist."), animated: true, completion: nil)
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
    //返回按键
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
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
            userName.resignFirstResponder()
            userEmail.resignFirstResponder()
            userPassword.resignFirstResponder()
            userRePassword.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
    //限制只能输入n位数字
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == userName{
            let proposeLength = (textField.text?.lengthOfBytes(using: String.Encoding.utf8))! - range.length + string.lengthOfBytes(using: String.Encoding.utf8)
            if proposeLength > 15 { return false}
        }
        if textField == userPassword || textField == userRePassword{
            let proposeLength = (textField.text?.lengthOfBytes(using: String.Encoding.utf8))! - range.length + string.lengthOfBytes(using: String.Encoding.utf8)
            if proposeLength > 24 { return false}
        }
        return true
    }
}
