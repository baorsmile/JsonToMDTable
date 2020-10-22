//
//  Conver.swift
//  JsonToMDTable
//
//  Created by Dabao on 2020/10/22.
//

import Foundation


class Conver: NSObject {
    
    private lazy var contents: Array<String> = [];
    public var formatStr: String!

    public
    func conver(_ raw: String) -> String {
        
        self.contents.removeAll()
        
        let data = raw.data(using: String.Encoding.utf8)
        let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)
        print("这是要解析的数据= \(String(describing: dict))")
        
        self.converBy(dict, nil)
        
        var content: String = "";
        for s in self.contents.reversed() {
            content += s
            content += "\n"
        }
        
        return content;
    }
    
    private
    func converBy(_ data: Any?, _ name: String?) {
        guard data is Dictionary<String, AnyObject> else {
            return
        }

        let dict: Dictionary<String, AnyObject> = data as! Dictionary<String, AnyObject>
        var content = "#####\(name ?? "最外层"):\n" + self.header
        for (key, value) in dict {
            // | ~~%@~~ | ~~%@~~ | -- |
            content += String(format: self.formatStr, key, self.objType(value))
            content += "\n"
            
            if value is Dictionary<String, AnyObject> {
                self.converBy(value, key)
            } else if value is Array<Any> {
                let array = value as! Array<Any>
                self.converBy(array, key)
            }
        }
        self.contents.append(content)
    }
    
    private
    func objType(_ obj: AnyObject) -> String {
        if obj.isKind(of: NSNumber.self) {
            return "int"
        }
        
        if obj.isKind(of: NSString.self) {
            return "string"
        }
        
        if obj.isKind(of: NSDictionary.self) {
            return "dictionary"
        }
        
        if obj.isKind(of: NSArray.self) {
            return "array"
        }
        
        return "object";
    }
    
    private
    var header: String {
        var header = "| 字段 | 类型 | 定义 |";
        header += "\n"
        header += "| ---- | ---- | ---- |"
        header += "\n"
        print("header is \(header)")
        return header
    }
}

