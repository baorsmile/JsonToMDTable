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
    public var style: Int = 0

    public
    func conver(_ raw: String) -> String {
        
        self.contents.removeAll()
        
        let data = raw.data(using: String.Encoding.utf8)
        let dict = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves)
        print("这是要解析的数据= \(String(describing: dict))")
        
        var content: String = ""
        
        if self.style == 0 {
            // 整体
            content = self.header;
            content += self.converBy(dict, nil)
        } else if self.style == 1 {
            // 分组
            self.converMultiGroupBy(dict, nil, 0)
            for s in self.contents.reversed() {
                content += s
                content += "\n"
            }
        }
        
        return content
    }
    
    private
    func numberOf(_ index: Int) -> String {
        var numberStr: String = "##"
        for _ in 0..<index {
            numberStr.append("#")
        }
        return numberStr
    }
    
    private
    func converMultiGroupBy(_ data: Any?, _ name: String?, _ index: Int) {
        guard data is Dictionary<String, AnyObject> else {
            return
        }

        let dict: Dictionary<String, Any> = data as! Dictionary<String, Any>
        var content = String(format: "%@ %@:\n%@", self.numberOf(index), name ?? "最外层", self.header)
        for (key, value) in dict {
            // | ~~%@~~ | ~~%@~~ | -- |
            content += String(format: self.formatStr, key, self.objType(value))
            content += "\n"

            if value is Dictionary<String, AnyObject> {
                let nextIndex = index + 1
                self.converMultiGroupBy(value, key, nextIndex)
            } else if value is Array<Any> {
                let array = value as! Array<Any>
                let nextIndex = index + 1
                self.converMultiGroupBy(array.first, key, nextIndex)
            }
        }
        self.contents.append(content)
    }
    
    private
    func converBy(_ data: Any?, _ name: String?) -> String {
        guard data is Dictionary<String, Any> else {
            return ""
        }

        let dict: Dictionary<String, Any> = data as! Dictionary<String, Any>
        
        var formatStr: String = ""
        var arrayStr: String = ""
        var dictionaryStr: String = ""
        
        for (key, value) in dict {
            var keys = (name == nil) ? key : (name ?? "") + "." + key;

            if value is Dictionary<String, Any> {
                keys = self.superKey(keys)
                dictionaryStr = self.insertSuperKey(self.converBy(value, keys), keys, value)
            } else if value is Array<Any> {
                let array = value as! Array<Any>
                keys = self.superKey(keys)
                arrayStr = self.insertSuperKey(self.converBy(array.first, keys), keys, value)
            } else {
                let keyStr = String(format: self.formatStr, keys, self.objType(value))
                formatStr += keyStr
                formatStr += "\n"
            }
        }
        return formatStr + arrayStr + dictionaryStr
    }
    
    private
    func superKey(_ key: String) -> String {
        var formatKey: String = key
        if key.contains("*") {
            formatKey = formatKey.replacingOccurrences(of: "*", with: "")
        }
        return "**\(formatKey)**";
    }
    
    private
    func insertSuperKey(_ contentStr: String, _ key: String, _ value: Any) -> String {
        var formatStr: String = contentStr
        let keyStr = String(format: self.formatStr, key, self.objType(value)) + "\n"
        formatStr.insert(contentsOf: keyStr, at: formatStr.startIndex)
        return formatStr
    }
    
    private
    func objType(_ obj: Any) -> String {
        if obj is NSNumber {
            return "int"
        }
        
        if obj is String {
            return "string"
        }
        
        if obj is Dictionary<String, Any> {
            return "dictionary"
        }
        
        if obj is Array<Any> {
            return "array"
        }

        return "object"
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

