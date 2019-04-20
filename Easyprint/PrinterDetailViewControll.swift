//
//  PrinterDetailViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/25.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class PrinterDetailViewControll: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var printerId: String?
    var printerName: String?
    
    @IBOutlet weak var printerImg: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelNumber: UILabel!
    @IBOutlet weak var imgBtn: UIImageView!
    @IBOutlet weak var unbindBtn: UIButton!
    @IBOutlet weak var changeImgBtn: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.navigationItem.title = "3D Printer"
        let tap = UITapGestureRecognizer(target: self, action: #selector(editName))
        imgBtn.addGestureRecognizer(tap)
        unbindBtn.addTarget(self, action: #selector(unbind), for: UIControlEvents.touchUpInside)
        changeImgBtn.isUserInteractionEnabled = true
        let changeTap = UITapGestureRecognizer(target: self, action: #selector(fromAlbum(_:)))
        changeImgBtn.addGestureRecognizer(changeTap)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(_ animated: Bool) {
        labelName.text = self.printerName
        labelNumber.text = self.printerId
    }
    override func viewWillAppear(_ animated: Bool) {
        getImg()
    }
    //解绑
    @objc func unbind(){
        
        let url = Url.baseUsers + PersonInfo().emailAes()
        let params = ["action": "delete", "target": "user_printer", "serial_num": self.printerId as Any, "token": PersonInfo().token()] as [String: Any]
        PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
        PersonInfo.shadowView.startTheView()
        Alamofire.request(url, method: .delete, parameters: params, encoding: JSONEncoding.default).responseJSON{
            (response) in
            PersonInfo.shadowView.stopAndRemoveFromSuperView()
            let code = response.response?.statusCode
            if response.response?.statusCode == 200{
                self.tapBack()
                if self.printerId == PersonInfo.Var.currentMachine{
                    PersonInfo.Var.currentMachine = ""
                }
            } else{
                if code != nil{
                    ResponseError().error(target: self, code: code!)
                    return
                }
            }
            if response.result.isFailure{
                let code = (response.result.error! as NSError).code
                ResponseError().errorNScode(target: self, code: code)
            }
        }
    }
    //修改名字
    @objc func editName(){
        let alert = UIAlertController(title: "", message: "Change your printer name", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let ok = UIAlertAction(title: "Sure", style: UIAlertActionStyle.default, handler: {(UIAlertAction) in
            let name = alert.textFields![0]
            let need = String(name.text!)
            if need.count == 0{
                self.present(Alert().singleAlert(message: "Please write something."), animated: true, completion: nil)
                return
            }
            let machineNumber = self.printerId!
            let token = PersonInfo().token()
            let encryStr = PersonInfo().emailAes()
            let encryStrId = AES_ECB().encypted(need: machineNumber)
            let url = Url.baseUsers + encryStr + "/printers/" + encryStrId

            let params = ["action": "update", "target": "printer_name", "token": token, "value": need] as [String : Any]
            Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default).response{
                (response) in
                let code = response.response?.statusCode
                if response.response?.statusCode == 200{
                    self.labelName.text = need
                    if self.printerId == PersonInfo.Var.currentMachine{
                        PersonInfo.Var.currentMachineName = need
                    }
                } else{
                    if code != nil {
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
    //获取打印机图片信息
    func getImg(){
        let encryStrId = AES_ECB().encypted(need: printerId!)
        let url = Url.baseUsers + PersonInfo().emailAes() + "/printers/" + encryStrId + "/image?token=" + PersonInfo().token()
        Alamofire.request(url).response{
            (response) in
            let code = response.response?.statusCode
            let list = JSON(response.data as Any)
            if code == 410{
                if (self.printerId?.contains("3DWF"))!{
                    self.printerImg.image = UIImage(named: "icon_3dwifi")
                } else if (self.printerId?.contains("E180"))!{
                    self.printerImg.image = UIImage(named: "icon_e180")
                } else if (self.printerId?.contains("D200"))!{
                    self.printerImg.image = UIImage(named: "icon_d200")
                } else if (self.printerId?.contains("A30"))!{
                    self.printerImg.image = UIImage(named: "icon_a30")
                }
                return
            } else if code == 200{
                if self.printerId == PersonInfo.Var.currentMachine{
                    PersonInfo.Var.currentMachineImg = list["image"].stringValue
                }
                let url = URL(string:list["image"].stringValue)
                self.printerImg.kf.setImage(with: url)
            } else {
                if code != nil {
                    ResponseError().error(target: self, code: code!)
                } else{
                    let nsCode = (response.error! as NSError).code
                    if (self.printerId?.contains("3DWF"))!{
                        self.printerImg.image = UIImage(named: "icon_3dwifi")
                    } else if (self.printerId?.contains("E180"))!{
                        self.printerImg.image = UIImage(named: "icon_e180")
                    } else if (self.printerId?.contains("D200"))!{
                        self.printerImg.image = UIImage(named: "icon_d200")
                    } else if (self.printerId?.contains("A30"))!{
                        self.printerImg.image = UIImage(named: "icon_a30")
                    }
                    ResponseError().errorNScode(target: self, code: nsCode)
                }
            }
        }
    }
    //选择图片
    @objc func fromAlbum(_ sender: Any) {
        if PersonInfo().state() != "login"{
            return
        }
        //判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = .photoLibrary
            //弹出控制器，显示界面
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            self.present(Alert().singleAlert(message: "Error reading album."), animated: true, completion: nil)
        }
    }
    //选择图片成功后代理
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //获取选择的原图
        var pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        pickedImage = UIImage(data: PrinterDetailViewControll.resetImgSize(sourceImage: pickedImage, maxImageLenght: 1024, maxSizeKB: 1024))!
        //self.imageView.image = pickedImage
        //将选择的图片保存到Document目录下
        let fileManager = FileManager.default
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                           .userDomainMask, true)[0] as String
        let filePath = "\(rootPath)/picked.jpg"
        let imageData = UIImageJPEGRepresentation(pickedImage, 1.0)
        fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        //取得NSURL
        //let imageURL = URL(fileURLWithPath: filePath)
        //上传图片
        if (fileManager.fileExists(atPath: filePath)){
            let url = Url.baseUsers + PersonInfo().emailAes() + "/printers/" + AES_ECB().encypted(need: self.printerId!) + "/image"
            let params = ["action": "update","target": "user_avatar","token": PersonInfo().token(),"value": ""]
            //使用Alamofire上传
            Alamofire.upload(multipartFormData: {(multipartFormData) in
                multipartFormData.append(imageData!, withName: "file", fileName: "picked.jpg", mimeType: "jpg")
                for (key, value) in params {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            }, to: url, method: .post, encodingCompletion: {encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        let code = response.response?.statusCode
                        if code == 200{
                            self.getImg()
                        }else{
                            self.present(Alert().singleAlert(message: "Upload failed, file is too large."), animated: true, completion: nil)
                        }
                    }
                case .failure( _):
                    self.present(Alert().singleAlert(message: "Failed to upload pictures."), animated: true, completion: nil)
                }
            })
        }
        
        //图片控制器退出
        picker.dismiss(animated: true, completion:nil)
    }
    //返回键控制
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
    ///图片压缩方法
    class func resetImgSize(sourceImage : UIImage,maxImageLenght : CGFloat,maxSizeKB : CGFloat) -> Data {
        var maxSize = maxSizeKB
        var maxImageSize = maxImageLenght
        if (maxSize <= 0.0) {
            maxSize = 1024.0;
        }
        if (maxImageSize <= 0.0)  {
            maxImageSize = 1024.0;
        }
        //先调整分辨率
        var newSize = CGSize.init(width: sourceImage.size.width, height: sourceImage.size.height)
        let tempHeight = newSize.height / maxImageSize;
        let tempWidth = newSize.width / maxImageSize;
        if (tempWidth > 1.0 && tempWidth > tempHeight) {
            newSize = CGSize.init(width: sourceImage.size.width / tempWidth, height: sourceImage.size.height / tempWidth)
        }
        else if (tempHeight > 1.0 && tempWidth < tempHeight){
            newSize = CGSize.init(width: sourceImage.size.width / tempHeight, height: sourceImage.size.height / tempHeight)
        }
        UIGraphicsBeginImageContext(newSize)
        sourceImage.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var imageData = UIImageJPEGRepresentation(newImage!, 1.0)
        var sizeOriginKB : CGFloat = CGFloat((imageData?.count)!) / 1024.0;
        //调整大小
        var resizeRate = 0.9;
        while (sizeOriginKB > maxSize && resizeRate > 0.1) {
            imageData = UIImageJPEGRepresentation(newImage!,CGFloat(resizeRate));
            sizeOriginKB = CGFloat((imageData?.count)!) / 1024.0;
            resizeRate -= 0.1;
        }
        return imageData!
    }
}
