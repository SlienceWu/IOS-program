//
//  MyViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/10.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MyViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loginView: UIView!
    //my printers
    @IBOutlet weak var myPrintersView: UIView!
    //printer profile
    @IBOutlet weak var printerProfileView: UIView!
    //material profile
    @IBOutlet weak var materialProfileView: UIView!
    //about
    @IBOutlet weak var aboutView: UIButton!
    //feedback
    @IBOutlet weak var feedbackView: UIButton!
    //password
    @IBOutlet weak var passwordView: UIButton!
    @IBOutlet weak var logoutView: UIView!
    //url
    @IBOutlet weak var facebook: UILabel!
    @IBOutlet weak var twitter: UILabel!
    @IBOutlet weak var youtube: UILabel!
    //数量
    @IBOutlet weak var printerCount: UILabel!
    @IBOutlet weak var pprofileCount: UILabel!
    @IBOutlet weak var materialCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view, typically from a nib.
        //UserData().setData(key: "user", value: ["state": "logout", "test":"test"] as AnyObject)
        
        aboutView.addTarget(self, action: #selector(skipToAbout), for: UIControlEvents.touchUpInside)
        feedbackView.addTarget(self, action: #selector(skipToFeedback), for: UIControlEvents.touchUpInside)
        passwordView.addTarget(self, action: #selector(skipToPassword), for: UIControlEvents.touchUpInside)
        let tapMyPriner = UITapGestureRecognizer(target: self, action: #selector(skipToMyPrinters(sender:)))
        self.myPrintersView.addGestureRecognizer(tapMyPriner)
        let tapPrinterProfile = UITapGestureRecognizer(target: self, action: #selector(skipToPrinterProfile(sender:)))
        self.printerProfileView.addGestureRecognizer(tapPrinterProfile)
        let tapMaterilaProfile = UITapGestureRecognizer(target: self, action: #selector(skipToMaterialProfile(sender:)))
        self.materialProfileView.addGestureRecognizer(tapMaterilaProfile)
        let tapFacebook = UITapGestureRecognizer(target: self, action: #selector(skipToUrl(sender:)))
        facebook.tag = 1
        facebook.addGestureRecognizer(tapFacebook)
        let tapTwitter = UITapGestureRecognizer(target: self, action: #selector(skipToUrl(sender:)))
        twitter.tag = 2
        twitter.addGestureRecognizer(tapTwitter)
        let tapYoutube = UITapGestureRecognizer(target: self, action: #selector(skipToUrl(sender:)))
        youtube.tag = 3
        youtube.addGestureRecognizer(tapYoutube)

        imageView.isUserInteractionEnabled = true
        let chooseTap = UITapGestureRecognizer(target: self, action: #selector(fromAlbum(_:)))
        imageView.addGestureRecognizer(chooseTap)
    }
    override func viewDidAppear(_ animated: Bool) {
//        self.mainView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        self.scrollView.contentSize = CGSize(width: self.view.bounds.size.width, height: self.scrollView.bounds.size.height + 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        getListInfo()
        let user = UserData().getData(key: "user")
        let isLogin = user["state"] as? String
        let logoutBtn = UIButton()
        logoutBtn.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 32, height: 50)
        logoutBtn.backgroundColor = UIColor.init(red: 28/255, green: 142/255, blue: 1, alpha: 1)
        logoutBtn.setTitle("Logout", for: .normal)
        logoutBtn.setTitleColor(UIColor.white, for: .normal)
        logoutBtn.setTitleColor(UIColor.cyan, for: .highlighted)
        logoutBtn.setTitleColor(UIColor.cyan, for: .selected)
        logoutBtn.setTitleShadowColor(UIColor.darkGray, for: .selected)
        logoutBtn.layer.cornerRadius = 5
        logoutBtn.layer.masksToBounds = true
        logoutBtn.isEnabled = true
        logoutBtn.addTarget(self, action: #selector(logout), for: UIControlEvents.touchUpInside)
        
        if isLogin == "login"{
            logoutView.subviews.forEach({$0.removeFromSuperview()})
            logoutView.addSubview(logoutBtn)
            
            loginView.subviews.forEach({$0.removeFromSuperview()})
            let user = UserData().getData(key: "user")
            let name = user["name"] as! String
            let address = user["address"] as! String
            let avatar = user["avatar"] as! String
            if avatar != ""{
                let url = URL(string: avatar)
                imageView.kf.setImage(with: url)
            } else {
                imageView.image = UIImage(named: "icon_default_avatar")?.scaleImage(scaleSize: 0.5)
            }
            
            let nameLabel = UILabel()
            let addressLabel = UILabel()
            
            nameLabel.frame = CGRect(x: 0, y: 30, width: loginView.bounds.size.width, height: 26)
            nameLabel.text = name
            loginView.addSubview(nameLabel)
            addressLabel.frame = CGRect(x: 0, y: 56, width: loginView.bounds.size.width, height: 26)
            addressLabel.text = address
            loginView.addSubview(addressLabel)
        } else {
            logoutView.subviews.forEach({$0.removeFromSuperview()})
            
            loginView.subviews.forEach({$0.removeFromSuperview()})
            imageView.image = UIImage(named: "icon_default_avatar")?.scaleImage(scaleSize: 0.5)
            let loginBtn = UIButton()
            loginBtn.frame = CGRect(x: 0, y: 0, width: loginView.bounds.size.width, height: loginView.bounds.size.height)
            loginBtn.setTitle("Log in", for: UIControlState.normal)
            loginBtn.setTitleColor(UIColor.black, for: UIControlState.normal)
            loginBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            loginBtn.addTarget(self, action: #selector(skipToLogin), for: UIControlEvents.touchUpInside)
            loginView.addSubview(loginBtn)
        }
    }
    //跳转登录页面
    @objc func skipToLogin(){
        self.performSegue(withIdentifier: "login", sender: self)
        //self.navigationController?.pushViewController(LoginViewControll(), animated: true)
    }
    //跳转到about页面
    @objc func skipToAbout(){
        self.performSegue(withIdentifier: "about", sender: self)
    }
    //跳转到feedback页面
    @objc func skipToFeedback(){
        self.performSegue(withIdentifier: "feedback", sender: self)
    }
    //跳转到password页面
    @objc func skipToPassword(){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        self.performSegue(withIdentifier: "password", sender: self)
    }
    //跳转到打印机列表页面
    @objc func skipToMyPrinters(sender: UITapGestureRecognizer){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        self.performSegue(withIdentifier: "myprinters", sender: self)
    }
    //跳转到打印机材料页
    @objc func skipToPrinterProfile(sender: UITapGestureRecognizer){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        self.performSegue(withIdentifier: "pprofile", sender: self)
    }
    @objc func skipToMaterialProfile(sender: UITapGestureRecognizer){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        self.performSegue(withIdentifier: "mprofile", sender: self)
    }
    //跳转到指定网址
    @objc func skipToUrl(sender: UITapGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        var urlStr = ""
        var url = URL(string: "")
        if tag == 1{
            urlStr = "https://www.facebook.com/geeetech"
            url = URL(string: urlStr)
        } else if tag == 2{
            urlStr = "https://twitter.com/geeetech"
            url = URL(string: urlStr)
        } else {
            urlStr = "https://www.youtube.com/channel/UCCDcof33Kp6i_JGCJ83GHPw"
            url = URL(string: urlStr)
        }
        if #available(iOS 10, *){
            UIApplication.shared.open(url!, options: [:], completionHandler: {(success) in})
        } else {
            UIApplication.shared.openURL(url!)
        }
    }
    //退出登录
    @objc func logout(){
        let emailAes = PersonInfo().emailAes()
        let token = PersonInfo().token()
        let params = ["action": "logout", "target": "user", "token": token]
        let url = Url.baseUserLogin + emailAes
        if PersonInfo.isConnectToServer != 1{
            PersonInfo().initPrinterData()
            let userParams = ["email": PersonInfo().email(), "name": "", "address": "", "avatar": "", "token": "", "token_expire": "", "state": ""]
            UserData().setData(key: "user", value: userParams as AnyObject)
            self.performSegue(withIdentifier: "login", sender: self)
            return
        }
        PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
        PersonInfo.shadowView.startTheView()
        AlamofireCustom.alamofireManager.request(url, method: .delete, parameters: params).response{
            (response) in
            PersonInfo.shadowView.stopAndRemoveFromSuperView()
            let code = response.response?.statusCode
            if code == 200{
                //print("logout request success")
            }
            PersonInfo().initPrinterData()
            let userParams = ["email": PersonInfo().email(), "name": "", "address": "", "avatar": "", "token": "", "token_expire": "", "state": ""]
            UserData().setData(key: "user", value: userParams as AnyObject)
            self.performSegue(withIdentifier: "login", sender: self)
        }
    }
    //跳转传值
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pprofile"{
            let controller = segue.destination as! PrinterProfileViewControll
            //let pprofile = controller.topViewController as! PrinterProfileViewControll
            let count = Int(pprofileCount.text!)
            controller.listCount = count
        } else if segue.identifier == "mprofile"{
            let controller = segue.destination as! MaterialProfileViewConroll
            //let pprofile = controller.topViewController as! MaterialProfileViewConroll
            let count = Int(materialCount.text!)
            controller.listCount = count
        } else if segue.identifier == "myprinters"{
            let controller = segue.destination as! MyPrinterViewControll
            //let pprofile = controller.topViewController as! MyPrinterViewControll
            let count = Int(printerCount.text!)
            controller.listCount = count
        }
    }
    //查询列表信息
    func getListInfo(){
        if PersonInfo().state() == "logout"{
            self.printerCount.text = "0"
            self.pprofileCount.text = "0"
            self.materialCount.text = "0"
            return
        }
        let encryStr = PersonInfo().emailAes()
        let token = PersonInfo().token()
        let url = Url.baseUsers + encryStr + "?token=" + token
        Alamofire.request(url).responseJSON{
            (response) in
            let code = response.response?.statusCode
            
            if code == 200{
                let value = response.result.value as Any
                let list = JSON(value)
                let machinesCount = list["machines"].count
                let machinesProfiles = list["machineProfiles"].count
                let materialProfiles = list["materialProfiles"].count
                self.printerCount.text = String(machinesCount)
                self.pprofileCount.text = String(machinesProfiles)
                self.materialCount.text = String(materialProfiles)
            } else{
                if code != nil{
                    ResponseError().error(target: self, code: code!)
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
        pickedImage = UIImage(data: MyViewController.resetImgSize(sourceImage: pickedImage, maxImageLenght: 1024, maxSizeKB: 1024))!
        //self.imageView.image = pickedImage
        //将选择的图片保存到Document目录下
        let fileManager = FileManager.default
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                           .userDomainMask, true)[0] as String
        let filePath = "\(rootPath)/pickedimage.jpeg"
        let imageData = UIImageJPEGRepresentation(pickedImage, 1.0)
        fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        //取得NSURL
        //let imageURL = URL(fileURLWithPath: filePath)
        //上传图片
        if (fileManager.fileExists(atPath: filePath)){
            let url = Url.baseUsers + PersonInfo().emailAes() + "/avatar"
            let params = ["action": "update","target": "user_avatar","token": PersonInfo().token(),"value": ""]
            //使用Alamofire上传
            Alamofire.upload(multipartFormData: {(multipartFormData) in
                multipartFormData.append(imageData!, withName: "file", fileName: "pickedimage.jpg", mimeType: "jpg")
                for (key, value) in params {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            }, to: url, method: .post, encodingCompletion: {encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        let code = response.response?.statusCode
                        if code == 200{
                            self.refreshImg()
                            //self.imageView.image = pickedImage
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
    //刷新图片地址
    func refreshImg(){
        let url = Url.baseUsers + PersonInfo().emailAes() + "/avatar?token=" + PersonInfo().token()
        AlamofireCustom.alamofireFast.request(url).responseJSON{
            response in
            let code = response.response?.statusCode
            if code == 200{
                let json = JSON(response.result.value as Any)
                let avatar = json["avatar"].stringValue
                let url = URL(string: avatar)
                self.imageView.kf.setImage(with: url)
                
                let address = PersonInfo().address()
                let email = PersonInfo().email()
                let name = PersonInfo().name()
                let token = PersonInfo().token()
                let token_expire = PersonInfo().token_expire()
                let userParams = ["email": email, "name": name, "address": address, "avatar": avatar, "token": token, "token_expire": token_expire, "state": "login"] as [String : Any]
                UserData().setData(key: "user", value: userParams as AnyObject)
            }
        }
    }
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        //将选到的图片设置给UIImageView
//        imageView.image=image
//        //结束选图界面，返回
//        picker.dismiss(animated: true, completion: nil)
//    }
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
////图片缩放
//extension UIImage {
//    func reSizeImage(reSize: CGSize) -> UIImage {
//        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
//        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
//        let reSizeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndPDFContext()
//        return reSizeImage
//    }
//
//    func scaleImage(scaleSize: CGFloat) -> UIImage {
//        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
//        return reSizeImage(reSize: reSize)
//    }
//}
