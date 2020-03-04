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

    var richTextKeyboardView = RichTextKeyboard()
    var showToolBar = false
    override func viewDidLoad() {
        super.viewDidLoad()
        richTextKeyboardView = RichTextKeyboard(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 334))
        richTextKeyboardView.delegate = self
        vi = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
        editorView.delegate = self
//        editorView.inputAccessoryView = toolbar
        editorView.placeholder = "Type some text..."
        vi.addTarget(self, action: #selector(tap), for: .touchUpInside)
        vi.backgroundColor = UIColor.red
//        editorView.editingEnabled = false  
//        editorView.inputView = vi
//        editorView.isEditingEnabled = false
        editorView.html = "helloasdasdasdasdasdsddasdas"
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
    
    @IBAction func tapOnKeyBoard(_ sender: Any) {
        if !showToolBar{
            showToolBar = true
            editorView.inputView = richTextKeyboardView
        }else{
            editorView.defaultKeyboard()
            showToolBar = false
        }
//        editorView.becomeFirstResponder()
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
    
    func getIsBold(_ isBold: Bool) {
        if isBold{
            self.richTextKeyboardView.boldView.backgroundColor = RichTextKeyboard.selectedColor
        }else{
            self.richTextKeyboardView.boldView.backgroundColor = RichTextKeyboard.dafaultColor
        }
    }
    func getIsItalic(_ isItalic: Bool) {
        if isItalic{
            self.richTextKeyboardView.italicView.backgroundColor = RichTextKeyboard.selectedColor
        }else{
            self.richTextKeyboardView.italicView.backgroundColor = RichTextKeyboard.dafaultColor
        }
    }
    func getIsUnderLine(_ isUnderLine: Bool) {
        if isUnderLine{
            self.richTextKeyboardView.underLineView.backgroundColor = RichTextKeyboard.selectedColor
        }else{
            self.richTextKeyboardView.underLineView.backgroundColor = RichTextKeyboard.dafaultColor
        }
    }
    func getIsStrike(_ isStrike: Bool) {
        if isStrike{
            self.richTextKeyboardView.strikeView.backgroundColor = RichTextKeyboard.selectedColor
        }else{
            self.richTextKeyboardView.strikeView.backgroundColor = RichTextKeyboard.dafaultColor
        }
    }
    func currentEvents(isBold: Bool, isItalic: Bool, isUnderLine: Bool, isStrike: Bool) {
        if isBold{
            self.richTextKeyboardView.boldView.backgroundColor = RichTextKeyboard.selectedColor
        }else{
            self.richTextKeyboardView.boldView.backgroundColor = RichTextKeyboard.dafaultColor
        }
        if isItalic{
            self.richTextKeyboardView.italicView.backgroundColor = RichTextKeyboard.selectedColor
        }else{
            self.richTextKeyboardView.italicView.backgroundColor = RichTextKeyboard.dafaultColor
        }
        if isUnderLine{
            self.richTextKeyboardView.underLineView.backgroundColor = RichTextKeyboard.selectedColor
        }else{
            self.richTextKeyboardView.underLineView.backgroundColor = RichTextKeyboard.dafaultColor
        }
        if isStrike{
            self.richTextKeyboardView.strikeView.backgroundColor = RichTextKeyboard.selectedColor
        }else{
            self.richTextKeyboardView.strikeView.backgroundColor = RichTextKeyboard.dafaultColor
        }
    }
    func getFont(_ font: String) {
        if font == "2"{
            richTextKeyboardView.selectedFont(0)
        }else if font == "4"{
            richTextKeyboardView.selectedFont(1)
        }else if font == "6"{
            richTextKeyboardView.selectedFont(2)
        }
    }
    func getColor(_ color: String) {
        if color != ""{
            richTextKeyboardView.selectedColor(UIColor.hexStringToUIColor(hex: color))
        }
    }
    func keyboardHide(_ editor: RichEditorView) {
        self.showToolBar = false
    }
    
    func limitReached(_ editor: RichEditorView) {
        let alert = UIAlertController(title: "Alert", message: "Limit exceedd", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
extension ViewController: KeyboardDelegate {
    func bold() {
        editorView.bold()
    }
    
    func italic() {
        editorView.italic()
    }
    
    func underLine() {
        editorView.underline()
    }
    
    func strike() {
        editorView.strikethrough()
    }
    
    func smallFont() {
        editorView.setSelectedFontSize(2)
    }
    
    func mediamFont() {
        editorView.setSelectedFontSize(4)
    }
    
    func largeFont() {
        editorView.setSelectedFontSize(6)
    }
    
    func leftAlign() {
        editorView.alignLeft()
    }
    
    func centerAlign() {
        editorView.alignCenter()
    }
    
    func rightAlign() {
        editorView.alignRight()
    }
    
    func numberAlign() {
        editorView.orderedList()
    }
    
    func bulletAlign() {
        editorView.unorderedList()
    }
    func color(_ color: UIColor) {
        editorView.setTextColor(color)
    }
    func keybpardTapped() {
        showToolBar = false
        editorView.defaultKeyboard()
    }
    @objc func closeWebKeyBoard(){
        showToolBar = false
    }
}

extension UIColor {
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static var studioSegmentSelectedTextColor = UIColor(red: 50.0 / 255.0, green: 197.0 / 255.0, blue: 255.0/255.0, alpha: 1.0)
    static var homeSearchPlaceholderColor = UIColor(red: 196.0 / 255.0, green: 196.0 / 255.0, blue: 196.0/255.0, alpha: 1.0)
    static var studioSegmentSelectedBackgroundColor = UIColor(red: 34.0 / 255.0, green: 36.0 / 255.0, blue: 44.0/255.0, alpha: 1.0)
    static var studioShareColor = UIColor(red: 11.0 / 255.0, green: 179.0 / 255.0, blue: 223.0 / 255.0, alpha: 1.0)
    static var studioSelectColor = UIColor(red: 23.0 / 255.0, green: 24.0 / 255.0, blue: 29.0 / 255.0, alpha: 1.0)
    static var studioRemoveColor = UIColor(red: 224.0 / 255.0, green: 32.0 / 255.0, blue: 32.0 / 255.0, alpha: 1.0)
    static var renameUnderlineActiveColor = UIColor(red: 131.0 / 255.0, green: 131.0 / 255.0, blue: 131.0 / 255.0, alpha: 1.0)
    static var renameUnderlineInactiveColor = UIColor(red: 233.0 / 255.0, green: 233.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0)
    static let settingsConnectedColor = UIColor(red: 154.0 / 255.0, green: 154.0 / 255.0, blue: 154.0 / 255.0, alpha: 1.0)
    static let settingsDisconnectedColor = UIColor(red: 21.0 / 255.0, green: 210.0 / 255.0, blue: 145.0 / 255.0, alpha: 1.0)
    static let homeContentTitleColor = UIColor(red: 42.0 / 255.0, green: 44.0 / 255.0, blue: 55.0 / 255.0, alpha: 1.0)
    static let homeContentSubtitleColor = UIColor(red: 131.0 / 255.0, green: 131.0 / 255.0, blue: 131.0 / 255.0, alpha: 1.0)
    static let homeContentHighlightColor = UIColor(red: 23.0 / 255.0, green: 225.0 / 255.0, blue: 156.0 / 255.0, alpha: 1.0)
    
    
}
