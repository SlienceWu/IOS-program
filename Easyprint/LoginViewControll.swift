//
//  LoginViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/6.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire
import CryptoSwift
import SwiftyJSON

class LoginViewControll: UIViewController, UITextFieldDelegate {
    //用户邮箱
    @IBOutlet weak var userEmail: UITextField!
    //用户密码
    @IBOutlet weak var userPassword: UITextField!
    //登录
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerbtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        self.view.isMultipleTouchEnabled = true
        userEmail.delegate = self
        userPassword.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        // Do any additional setup after loading the view, typically from a nib.
        
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        loginBtn.addTarget(self, action: #selector(userLogin), for: UIControlEvents.touchUpInside)
        registerbtn.addTarget(self, action: #selector(skipToRegister), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //touchesBegan(<#Set<UITouch>#>)
    }
    override func viewWillAppear(_ animated: Bool) {
        userEmail.text = PersonInfo().email()
    }
    //跳转到register页面
    @objc func skipToRegister(){
        self.performSegue(withIdentifier: "register", sender: self)
    }
    //返回键控制
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
    }
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
            userPassword.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
    //登录验证
    @objc func userLogin(){
        let email = self.userEmail.text! as String
        let password = self.userPassword.text! as String
        
        if email == "" {
            self.present(Alert().singleAlert(message: "Please enter the email."), animated: true, completion: nil)
            return
        } else if password == "" {
            self.present(Alert().singleAlert(message: "Please enter the password."), animated: true, completion: nil)
            return
        }
        let emailAes = AES_ECB().encypted(need: email)
        if emailAes == "" {
            self.present(Alert().singleAlert(message: "Email is error"), animated: true, completion: nil)
            return
        }
        let url = Url.baseUserLogin + emailAes
        let params = ["action": "login", "target": "user", "password": password.md5()]
        PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
        PersonInfo.shadowView.startTheView()
        AlamofireCustom.alamofireManager.request(url, method: .post, parameters: params)
            .responseJSON{
            (response) in
                PersonInfo.shadowView.stopAndRemoveFromSuperView()
            let code = response.response?.statusCode
            if response.response?.statusCode == 200{
                if let json = response.result.value {
                    let result = JSON(json)
                    let address = result["address"].stringValue
                    let avatar = result["avatar"].stringValue
                    let email = result["email"].stringValue
                    let name = result["name"].stringValue
                    let token = result["token"].stringValue
                    let token_expire = result["token_expire"].stringValue
                    let userParams = ["email": email, "name": name, "address": address, "avatar": avatar, "token": token, "token_expire": token_expire, "state": "login"] as [String : Any]
                    UserData().setData(key: "user", value: userParams as AnyObject)
                    self.navigationController?.popViewController(animated: true)
                }
            } else if code == 400{
                self.present(Alert().singleAlert(message: "Params are wrong!"), animated: true, completion: nil)
            } else if code == 401{
                self.present(Alert().singleAlert(message: "Password is wrong!"), animated: true, completion: nil)
            } else if code == 402{
                self.present(Alert().singleAlert(message: "Mailbox unverified!"), animated: true, completion: nil)
            } else if code == 410{
                self.present(Alert().singleAlert(message: "Email is not exist."), animated: true, completion: nil)
            }
            if response.result.isFailure{
                let code = (response.result.error! as NSError).code
                ResponseError().errorNScode(target: self, code: code)
            }
        }
    }
}
//图片缩放
extension UIImage {
    func reSizeImage(reSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndPDFContext()
        return reSizeImage
    }
    
    func scaleImage(scaleSize: CGFloat) -> UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}
