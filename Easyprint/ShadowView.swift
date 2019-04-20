//
//  ShadowView.swift
//  Easyprint
//
//  Created by app on 2018/8/10.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Foundation
import UIKit

//自定义等待提示框
class CustView: UIView {
    private let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    private let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    let width = UIScreen.main.bounds.size.width
    //活动指示器
    var activity:UIActivityIndicatorView!
    //添加一个透明的View
    var activityView:UIView!
    
    var durationF:Double = 0.0
    
    
    //MARK: - 网络提示
    func initWithIndicatorWithView(view:UIView, withText:String){
        var needText = withText
        if withText == ""{
            needText = "please wait."
        }
        activityView = UIView(frame:CGRect(x:0, y:0, width:SCREEN_WIDTH, height:SCREEN_HEIGHT))
        activityView.backgroundColor = UIColor.clear
        
        
        //配置
        self.frame = CGRect(x:(view.bounds.size.width/2 - 120/2), y:view.bounds.size.height/2 - 90/2, width:120,height:90)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        self.alpha = 0
        
        
        //配置
        activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.center = CGPoint(x:60, y: 30)
        activityView.addSubview(activity)
        self.addSubview(activity)
        
        
        //UILabel
        let label = UILabel(frame:CGRect(x:0, y:50, width:120,height:30))
        label.text = needText
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = UIColor.white
        self.addSubview(label)
        
        
        activityView.addSubview(self)
        view.addSubview(activityView)
        activityView.isHidden = true
        
        
    }
    
    //显示菊花
    func startTheView(){
        
        activityView.isHidden = false
        activity.startAnimating()
        
        weak var weakSelf = self
        
        UIView.animate(withDuration: 0.3) {
            
            weakSelf?.alpha = 1
        }
    }
    
    
    //隐藏菊花
    func stopAndRemoveFromSuperView(){
        activityView.isHidden = true
        activity.stopAnimating()
        
        weak var weakSelf = self
        
        UIView.animate(withDuration: 0.3, animations: {
            
            weakSelf?.alpha = 0
            
        }) { (finish) in
            
            weakSelf?.activityView.isHidden = true
            weakSelf?.removeFromSuperview()
            
        }
        
        
    }
    
    
    
    //MARK: - 普通提示
    func initWithView(view:UIView, text:String ,duration:Double){
        
        print(text)
        
        durationF = duration
        
        //适配高度
        let size:CGRect =  text.boundingRect(with: CGSize(width: SCREEN_WIDTH - 60, height: 400), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13)] , context: nil);
        
        //配置
        self.frame = CGRect(x:(view.bounds.size.width/2 - (size.width + 20)/2), y:view.bounds.size.height/2 - 50/2, width:size.width + 20,height:50)
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        self.alpha = 0
        
        
        //UILabel
        let label = UILabel(frame:CGRect(x:0, y:0, width:self.width,height:50))
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        
        self.addSubview(label)
        view.addSubview(self)
        
        weak var weakSelf = self
        
        UIView.animate(withDuration: 0.3, animations: {
            
            weakSelf?.alpha = 1
            
        }) { (finish) in
            
            weakSelf?.perform(#selector(weakSelf?.closeCust), with: nil, afterDelay: (weakSelf?.durationF)!)
            
        }
        
        
    }
    
    //关闭
    @objc func closeCust(){
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.alpha = 0
            
        }) { (finished:Bool) in
            
            self.removeFromSuperview()
        }
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
