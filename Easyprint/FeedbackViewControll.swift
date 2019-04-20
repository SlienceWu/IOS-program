//
//  FeedbackViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/11.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FeedbackViewControll: UIViewController , UITextViewDelegate, UITextFieldDelegate{
    
//    @IBOutlet weak var adviceView: UIView!
//    @IBOutlet weak var adviceImg: UIImageView!
//    @IBOutlet weak var bugsView: UIView!
//    @IBOutlet weak var bugImg: UIImageView!
//    @IBOutlet weak var errorsView: UIView!
//    @IBOutlet weak var errorImg: UIImageView!
    @IBOutlet weak var serialNumber: UITextField!
    @IBOutlet weak var baudRate: UITextField!
    @IBOutlet weak var deviceName: UITextField!
    //文本视图
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var submitBtn: UIButton!
    let label = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        //check选择
//        let tap1 = UITapGestureRecognizer(target: self, action: #selector(tapClick(tapView:)))
//        let tap2 = UITapGestureRecognizer(target: self, action: #selector(tapClick(tapView:)))
//        let tap3 = UITapGestureRecognizer(target: self, action: #selector(tapClick(tapView:)))
//        adviceView.tag = 1
//        adviceView.addGestureRecognizer(tap1)
//        bugsView.tag = 2
//        bugsView.addGestureRecognizer(tap2)
//        errorsView.tag = 3
//        errorsView.addGestureRecognizer(tap3)
        serialNumber.delegate = self
        baudRate.delegate = self
        deviceName.delegate = self
        //创建placeholder
        label.frame = CGRect(x: 4, y: 0, width: textView.bounds.width - 4, height: 50)
        label.font = textView.font
        label.text = "Please give us your feedback and we will keep improving your user experience."
        label.numberOfLines = 0
        label.textColor = UIColor.lightGray
        textView.addSubview(label)
        textView.delegate = self
        submitBtn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func sendMessage(){
        let url = Url.basePath + "/v1/app/feedback"
        let needNum = serialNumber.text! as String
        let needBaud = baudRate.text! as String
        let needDevice = deviceName.text! as String
        let need = textView.text! as String
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        if need == ""{
            self.present(Alert().singleAlert(message: "Please enter something."), animated: true, completion: nil)
            return
        }else if needNum == ""{
            self.present(Alert().singleAlert(message: "Please enter serial number."), animated: true, completion: nil)
            return
        }else if needBaud == ""{
            self.present(Alert().singleAlert(message: "Please enter baud rate."), animated: true, completion: nil)
            return
        }else if needDevice == ""{
            self.present(Alert().singleAlert(message: "Please enter device name."), animated: true, completion: nil)
            return
        }
        let details = "serial number:" + needNum + "\n baud rate:" + needBaud + "\n device name:" + needDevice + "\n feedback:" + need
        let params = ["action": "feedback", "email": PersonInfo().email(), "value": details, "token": PersonInfo().token()] as [String: Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                self.present(Alert().singleAlert(message: "Send message success."), animated: true, completion: nil)
            } else{
                if code != nil {
                    ResponseError().error(target: self, code: code!)
                } else{
                    let nsCode = (response.error! as NSError).code
                    ResponseError().errorNScode(target: self, code: nsCode)
                }
            }
        }
    }
    //返回键控制
    @objc func tapBack(){
        textView.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    //check事件
//    @objc func tapClick(tapView: UITapGestureRecognizer){
//        let view = tapView.view!
//        let viewTag = view.tag
//        if viewTag == 1{
//            let isCheck = adviceImg.tag
//            if isCheck == 0{
//                adviceImg.image = UIImage(named: "icon_check_on")
//                adviceImg.tag = 1
//            } else {
//                adviceImg.image = UIImage(named: "icon_check_out")
//                adviceImg.tag = 0
//            }
//        } else if viewTag == 2 {
//            let isCheck = bugImg.tag
//            if isCheck == 0{
//                bugImg.image = UIImage(named: "icon_check_on")
//                bugImg.tag = 1
//            } else {
//                bugImg.image = UIImage(named: "icon_check_out")
//                bugImg.tag = 0
//            }
//        } else if viewTag == 3 {
//            let isCheck = errorImg.tag
//            if isCheck == 0{
//                errorImg.image = UIImage(named: "icon_check_on")
//                errorImg.tag = 1
//            } else {
//                errorImg.image = UIImage(named: "icon_check_out")
//                errorImg.tag = 0
//            }
//        }
//    }
    //textview事件
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == ""{
            label.isHidden = false
        } else {
            label.isHidden = true
        }
    }
    //输入键盘控制消失
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        if range.location >= 200{
            let alert = UIAlertController(title: "", message: "to many number", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "ok", style: .default, handler: nil)
            alert.addAction(cancel)
            
            self.present(Alert().singleAlert(message: "to many number"), animated: true, completion: nil)
            return false
        }
        return true
    }
    @objc func handleTap(sender: UITapGestureRecognizer){
        if sender.state == .ended{
            textView.resignFirstResponder()
            serialNumber.resignFirstResponder()
            baudRate.resignFirstResponder()
            deviceName.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
    //输入键盘控制消失
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
