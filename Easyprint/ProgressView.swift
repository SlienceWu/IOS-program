//
//  ProgressView.swift
//  Easyprint
//
//  Created by app on 2018/7/28.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Foundation
import UIKit

class ProgressView: UIView {
    var value: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    let image = UIImageView()
    var maximumValue: CGFloat = 0 {
        didSet { self.setNeedsDisplay() }
    }
    
    var backgroundImage: String = "printer_off"{
        didSet { self.setNeedsDisplay() }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.red
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        
        
        image.frame = CGRect(x: 10, y: 10, width: self.bounds.size.width - 20, height: self.bounds.size.height - 20)
        if backgroundImage.contains("http"){
            let url = URL(string: backgroundImage)
            image.kf.setImage(with: url)
        } else{
            image.image = UIImage(named: backgroundImage)
        }
        image.backgroundColor = UIColor.white
        image.layer.cornerRadius = (self.bounds.size.width - 20)/2
        image.layer.masksToBounds = true
        self.subviews.forEach({$0.removeFromSuperview()})
        self.addSubview(image)
        //线宽度
        let lineWidth: CGFloat = 10.0
        //半径
        let radius = rect.width / 2.0 - lineWidth
        //中心点x
        let centerX = rect.midX
        //中心点y
        let centerY = rect.midY
        //弧度起点
        let startAngle = CGFloat(-90 * M_PI / 180)
        //弧度终点
        var endAngle = CGFloat(((self.value / self.maximumValue) * 360.0 - 90.0) ) * CGFloat(M_PI) / 180.0
        
        //创建一个画布
        let context = UIGraphicsGetCurrentContext()
        
        //画笔颜色UIColor.blue.cgColor
        if self.value == 0{
            endAngle = CGFloat(((1 / self.maximumValue) * 360.0 - 90.0) ) * CGFloat(M_PI) / 180.0
            context!.setStrokeColor(UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor)
        } else{
            context!.setStrokeColor(UIColor(red: 252/255, green: 162/255, blue: 3/255, alpha: 1).cgColor)
        }
        
        //画笔宽度
        context!.setLineWidth(lineWidth)
        
        //（1）画布 （2）中心点x（3）中心点y（4）圆弧起点（5）圆弧结束点（6） 0顺时针 1逆时针
        context?.addArc(center: CGPoint(x:centerX,y:centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        //绘制路径
        context!.strokePath()
        
        //画笔颜色UIColor.darkGray.cgColor
        context!.setStrokeColor(UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor)
        
        //（1）画布 （2）中心点x（3）中心点y（4）圆弧起点（5）圆弧结束点（6） 0顺时针 1逆时针
        context?.addArc(center: CGPoint(x:centerX,y:centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        //绘制路径
        context!.strokePath()
    }

}
