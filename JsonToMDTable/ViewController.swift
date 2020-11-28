//
//  ViewController.swift
//  JsonToMDTable
//
//  Created by Dabao on 2020/10/22.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var menuButton: NSPopUpButton!
    @IBOutlet weak var partMenuButton: NSPopUpButton!
    
    let conver = Conver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let itmes = menuButton.itemTitles
        let index = menuButton.indexOfSelectedItem;
        let title = itmes[index]
        self.conver.formatStr = title;
        let style = partMenuButton.indexOfSelectedItem;
        self.conver.style = style;
        
        print("这里是个title：\(title)-\(style)")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func handleFormateStyle(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem;
        self.conver.style = index;
        print("这里是个title\(index)")
    }
    
    @IBAction func handleMenu(_ sender: NSPopUpButton) {
        let itmes = sender.itemTitles
        let index = sender.indexOfSelectedItem;
        let title = itmes[index]
        self.conver.formatStr = title;
        print("这里是个title\(title)")
    }
    
    @IBAction func handleConverButton(_ sender: NSButton) {
        let raw = self.textView.string;
        DispatchQueue.global().async {
            let doRaw = self.conver.conver(raw)
            DispatchQueue.main.async {
                self.textView.string = doRaw
            }
        }
    }
}

