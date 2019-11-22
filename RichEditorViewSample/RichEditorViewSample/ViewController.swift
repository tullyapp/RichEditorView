//
//  ViewController.swift
//  RichEditorViewSample
//
//  Created by Caesar Wirth on 4/5/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import RichEditorView

class ViewController: UIViewController {

    @IBOutlet var editorView: RichEditorView!
    @IBOutlet var htmlTextView: UITextView!

    var vi = UIButton()


    override func viewDidLoad() {
        super.viewDidLoad()
        vi = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
        editorView.delegate = self
//        editorView.inputAccessoryView = toolbar
        editorView.placeholder = "Type some text..."
        vi.addTarget(self, action: #selector(tap), for: .touchUpInside)
        vi.backgroundColor = UIColor.red
//        editorView.editingEnabled = false  
        editorView.inputView = vi
//        editorView.isEditingEnabled = false
        editorView.html = "hello"
//        editorView.html = "&nbsp;bbbdhgdhdhbzbxb xb helo djdjj hhhh&nbsp;<div><span style=\"font-size: 14pt; color: rgb(255, 99, 43); -webkit-text-size-adjust: 100%;\">g</span><b style=\"font-size: 14pt; color: rgb(255, 99, 43); -webkit-text-size-adjust: 100%;\">rrerrf</b><u style=\"font-size: 14pt; color: rgb(255, 99, 43); -webkit-text-size-adjust: 100%; font-style: italic; font-weight: bold;\">fffff</u><strike style=\"font-size: 14pt; color: rgb(255, 99, 43); -webkit-text-size-adjust: 100%; font-style: italic;\">fff</strike><br></div><div><strike style=\"font-size: 14pt; color: rgb(255, 99, 43); -webkit-text-size-adjust: 100%; font-style: italic;\">gggggg</strike></div><div><strike style=\"font-size: 14pt; color: rgb(255, 99, 43); -webkit-text-size-adjust: 100%; font-style: italic;\">hhgt</strike><strike style=\"-webkit-text-size-adjust: 100%; font-style: italic;\"><font size=\"6\"><span style=\"color: rgb(255, 99, 43);\">fffgggggg</span><b><span style=\"color: rgb(255, 99, 43);\">&nbsp;</span><span style=\"color: rgb(255, 238, 0);\">ttt</span></b><span style=\"color: rgb(255, 238, 0);\">ccffg</span></font></strike></div><div><strike style=\"-webkit-text-size-adjust: 100%; font-style: italic;\"><font size=\"6\"><b style=\"color: rgb(128, 128, 128);\">hhhh </b><b style=\"color: rgb(26, 99, 244);\">hhhh</b></font></strike></div><div style=\"text-align: left;\"><span style=\"-webkit-text-size-adjust: 100%; font-style: italic;\"><font size=\"6\"><b><u>derdffff<span style=\"color: rgb(255, 99, 43);\"> ff ggg.&nbsp;</span></u></b></font></span></div><div><strike style=\"color: rgb(255, 99, 43); -webkit-text-size-adjust: 100%; font-style: italic;\"><font size=\"6\"><b><br></b></font></strike></div><div><span style=\"font-size: 10pt; color: rgb(255, 99, 43); -webkit-text-size-adjust: 100%; font-style: italic;\"><font size=\"6\"><b><strike>h</strike><u>fgfgghh</u><strike>&nbsp;fffgbbbbbbbb</strike></b></font></span><br></div><div><strike style=\"color: rgb(255, 99, 43); -webkit-text-size-adjust: 100%; font-style: italic;\"><font size=\"6\"><b><br></b></font></strike></div><div><strike style=\"color: rgb(255, 99, 43); -webkit-text-size-adjust: 100%; font-style: italic;\"><font size=\"6\"><b>&nbsp;hhh</b></font></strike></div><div><strike style=\"color: rgb(255, 99, 43); -webkit-text-size-adjust: 100%; font-style: italic;\"><font size=\"6\"><b><br></b></font></strike></div><div><strike style=\"color: rgb(255, 99, 43); -webkit-text-size-adjust: 100%; font-style: italic;\"><font size=\"6\"><b><br></b></font></strike></div><div><strike style=\"-webkit-text-size-adjust: 100%; font-style: italic;\"><font size=\"6\"><b><font color=\"#211c1c\">fffggg </font>vfggv</b></font></strike></div><div><strike style=\"-webkit-text-size-adjust: 100%; font-style: italic;\"><font size=\"6\"><b><br></b></font></strike></div><div><strike style=\"-webkit-text-size-adjust: 100%; font-style: italic;\"><font size=\"6\"><b><br></b></font></strike></div><div><strike style=\"-webkit-text-size-adjust: 100%; font-style: italic;\"><font size=\"6\"><b><br></b></font></strike></div><div><font color=\"#ff632b\"><b><br></b></font></div>"
        //"<b><font size=\"6\">Jjjjjjjjjjjjf fvdfvjfdbvvfdjb vdfjvbdvdfjvbdvdf vfdvjdfbvdfvkfdjvbdfbkvbdfvkdf dfjkg DVD’s fvdf vodka. Vfdvfd</font><button type=button>Click Me!</button>"
        // We will create a custom action that clears all the input text when it is pressed
    }
    var a = false
    
    @IBAction func tapme(_ sender: Any) {
        if a{
            editorView.inputView = vi
        }else{
            editorView.defaultKeyboard()
        }
        a = !a
    }
    @objc func tap(){
        editorView.setSelectedFontSize(6)
    }
}

extension ViewController: RichEditorDelegate {

    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        if content.isEmpty {
            htmlTextView.text = "HTML Preview"
        } else {
            htmlTextView.text = content
        }
    }
    
}
