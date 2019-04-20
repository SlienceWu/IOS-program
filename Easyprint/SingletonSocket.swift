//
//  SingletonSocket.swift
//  Easyprint
//
//  Created by app on 2018/9/11.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Starscream


class SingletonSocket {
    
    //let socket:WebSocket = WebSocket(url: NSURL(string: "后台服务器的地址")!)/websocket 47.88.84.109:3389
    let socket = WebSocket(url: URL(string: "ws://47.88.84.109:3389/")!, protocols: ["chat"])
    class var sharedInstance : SingletonSocket{
        struct Static{
            static let instance:SingletonSocket = SingletonSocket()
        }
        if !Static.instance.socket.isConnected{
            Static.instance.socket.connect()
        }
        return Static.instance
    }
}


