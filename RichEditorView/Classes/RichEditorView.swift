//
//  RichEditor.swift
//
//  Created by Caesar Wirth on 4/1/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit
import WebKit

private let DefaultInnerLineHeight: Int = 28

/// RichEditorDelegate defines callbacks for the delegate of the RichEditorView
@objc public protocol RichEditorDelegate: class {

    /// Called when the inner height of the text being displayed changes
    /// Can be used to update the UI
    @objc optional func richEditor(_ editor: RichEditorView, heightDidChange height: Int)

    /// Called whenever the content inside the view changes
    @objc optional func richEditor(_ editor: RichEditorView, contentDidChange content: String)

    /// Called when the rich editor starts editing
    @objc optional func richEditorTookFocus(_ editor: RichEditorView)
    
    /// Called when the rich editor stops editing or loses focus
    @objc optional func richEditorLostFocus(_ editor: RichEditorView)
    
    /// Called when the RichEditorView has become ready to receive input
    /// More concretely, is called when the internal UIWebView loads for the first time, and contentHTML is set
    @objc optional func richEditorDidLoad(_ editor: RichEditorView)
    
    /// Called when the internal UIWebView begins loading a URL that it does not know how to respond to
    /// For example, if there is an external link, and then the user taps it
    @objc optional func richEditor(_ editor: RichEditorView, shouldInteractWith url: URL) -> Bool
    
    /// Called when custom actions are called by callbacks in the JS
    /// By default, this method is not used unless called by some custom JS that you add
    @objc optional func richEditor(_ editor: RichEditorView, handle action: String)
    
    @objc optional func rhyme(_ editor: RichEditorView,word: String, x: Float,y: Float)
    
//    @objc optional func currentEvents(isBold: Bool,isItalic: Bool,isUnderLine: Bool,isStrike: Bool)

    @objc optional func textCopied(_ editor: RichEditorView)
    
    @objc optional func limitReached(_ editor: RichEditorView)

    @objc optional func keyboardHide(_ editor: RichEditorView)
    
    @objc optional func getColor(_ color: String)
    
    @objc optional func getFont(_ font: String)

    @objc optional func getIsBold(_ isBold: Bool)
    
    @objc optional func getIsItalic(_ isItalic: Bool)
    
    @objc optional func getIsStrike(_ isStrike: Bool)
    
    @objc optional func getIsUnderLine(_ isUnderLine: Bool)
    
    @objc optional func getRhymeWord(_ word: String)

}

/// RichEditorView is a UIView that displays richly styled text, and allows it to be edited in a WYSIWYG fashion.
@objcMembers open class RichEditorView: UIView, UIScrollViewDelegate, WKNavigationDelegate, UIGestureRecognizerDelegate {

    // MARK: Public Properties

    /// The delegate that will receive callbacks when certain actions are completed.
    open weak var delegate: RichEditorDelegate?
    var isOpenKeyBoard = false
    var xPosition : Float = 0.0
    var yPosition : Float = 0.0
    open override var inputAccessoryView: UIView? {
        get { return webView.accessoryView }
        set { webView.accessoryView = newValue }
    }
    open override var inputView: UIView? {
        get { return webView.cjw_inputView }
        set { webView.cjw_inputView = newValue }
    }
    open private(set) var webView: RichEditorWebView
    
    /// Whether or not scroll is enabled on the view.
    open var isScrollEnabled: Bool = true {
        didSet {
            webView.scrollView.isScrollEnabled = isScrollEnabled
        }
    }
    
    /// Whether or not to allow user input in the view.
    open var editingEnabled: Bool = false {
        didSet { contentEditable = editingEnabled }
    }
    
    /// The content HTML of the text being displayed.
    /// Is continually updated as the text is being edited.
    open private(set) var contentHTML: String = "" {
        didSet {
            delegate?.richEditor?(self, contentDidChange: contentHTML)
        }
    }
    
    /// The internal height of the text being displayed.
    /// Is continually being updated as the text is edited.
    open private(set) var editorHeight: Int = 0 {
        didSet {
            delegate?.richEditor?(self, heightDidChange: editorHeight)
        }
    }
    
    /// The line height of the editor. Defaults to 21.
    open private(set) var lineHeight: Int = DefaultInnerLineHeight {
        didSet {
            runJS("RE.setLineHeight('\(lineHeight)px')")
        }
    }
    
    /// Whether or not the editor has finished loading or not yet.
    private var isEditorLoaded = false
    
    /// Value that stores whether or not the content should be editable when the editor is loaded.
    /// Is basically `isEditingEnabled` before the editor is loaded.
    private var editingEnabledVar = true
        
    /// The HTML that is currently loaded in the editor view, if it is loaded. If it has not been loaded yet, it is the
    /// HTML that will be loaded into the editor view once it finishes initializing.
    public var html: String = "" {
        didSet {
            self.lastHtml = html
            setHTML(html)
        }
    }
    
    /// Private variable that holds the placeholder text, so you can set the placeholder before the editor loads.
    private var placeholderText: String = ""
    /// The placeholder text that should be shown when there is no user input.
    open var placeholder: String {
        get { return placeholderText }
        set {
            placeholderText = newValue
            if isEditorLoaded {
                runJS("RE.setPlaceholderText('\(newValue.escaped)')")
            }
        }
    }
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        webView = RichEditorWebView()
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        webView = RichEditorWebView()
        super.init(coder: aDecoder)
        setup()
    }
    private let tapRecognizer = UITapGestureRecognizer()
    var lastHtml = ""
    var textCount = 0
    private func setup() {
        // configure webview
        webView.frame = bounds
        webView.navigationDelegate = self
        webView.keyboardDisplayRequiresUserAction = false
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.configuration.dataDetectorTypes = WKDataDetectorTypes()
        webView.scrollView.isScrollEnabled = isScrollEnabled
        webView.scrollView.bounces = false
        webView.scrollView.delegate = self
        webView.scrollView.clipsToBounds = true
        webView.cjw_inputView = nil
        addSubview(webView)
        webView.isOpaque = false
        if let filePath = Bundle(for: RichEditorView.self).path(forResource: "rich_editor", ofType: "html") {
            let url = URL(fileURLWithPath: filePath, isDirectory: false)
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        tapRecognizer.addTarget(self, action: #selector(viewWasTapped))
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
    }
    @objc private func viewWasTapped() {
        if !webView.containsFirstResponder {
            let point = tapRecognizer.location(in: webView)
            getText { (str, loading) in
                var height : CGFloat = 0.0
                if let font = UIFont(name: "Avenir-Medium", size: 16.0){
                    height = str.heightWithConstrainedWidth(width: self.webView.frame.width, font: font) + (height/21.0)
                }
                if point.y <= height{
                    self.focus(at: point)
                }else{
                    self.focus()
                }
                self.checkEvents()
                self.performCommand("input")
            }
        }else if !isOpenKeyBoard{
            let point = tapRecognizer.location(in: webView)
            getText { (str, loading) in
                var height : CGFloat = 0.0
                if let font = UIFont(name: "Avenir-Medium", size: 16.0){
                    height = str.heightWithConstrainedWidth(width: self.webView.frame.width, font: font) + (height/21.0)
                }
                if point.y <= height{
                    self.focus(at: point)
                }else{
                    self.focus()
                }
                self.checkEvents()
                self.performCommand("input")
            }
        }
    }

    private func setHTML(_ value: String) {
        if isEditorLoaded {
            runJS("RE.setHtml('\(value.escaped)')") { _ in
                self.updateHeight()
            }
        }
    }
    
    public func defaultKeyboard(){
        webView.cjw_inputView = nil
        webView.reloadInputViews()
    }
    func showRhyme(){
        if self.contentEditable{
            let rhyme = UIMenuItem(title: "Rhyme", action: #selector(runRhyme))
            UIMenuController.shared.menuItems = [rhyme]
        }
    }
   func hideRhyme(){
          UIMenuController.shared.menuItems = []
   }
    public func getselectedPosition(handler: @escaping (String) -> Void) {
        runJS("RE.selectedPosition();") { r in
            handler(r)
        }


    }
    @objc func runRhyme()
    {
        self.getselectedPosition { (str) in
            let data = str.components(separatedBy: ",")
            if data.count >= 4{
                self.xPosition = Float(data[0])! // + Float(data[2])!
                self.yPosition = Float(data[1])! // + Float(data[3])!
                self.getSelectedText { (selectedText) in
                    self.delegate?.rhyme?(self, word: selectedText, x: Float(data[0])!, y: Float(data[1])!)
                }
            }
        }
    }
    // MARK: - Rich Text Editing

    // MARK: Properties

    /// The HTML that is currently loaded in the editor view, if it is loaded. If it has not been loaded yet, it is the
    /// HTML that will be loaded into the editor view once it finishes initializing.

    /// Text representation of the data that has been input into the editor view, if it has been loaded.
    public func getSelectedText(handler: @escaping (String) -> Void) {
           runJS("RE.getSelectedText()") { r in
               handler(r)
           }
       }
    /// Private variable that holds the placeholder text, so you can set the placeholder before the editor loads.
    /// The placeholder text that should be shown when there is no user input.
 
    /// The href of the current selection, if the current selection's parent is an anchor tag.
    /// Will be nil if there is no href, or it is an empty string.
    
    /// Whether or not the selection has a type specifically of "Range".
    

    /// Whether or not the selection has a type specifically of "Range" or "Caret".
//    public var hasRangeOrCaretSelection: Bool {
//        return runJS("RE.rangeOrCaretSelectionExists();") == "true" ? true : false
//    }

    // MARK: Methods
    /// Whether or not the selection has a type specifically of "Range".
       public func hasRangeSelection(handler: @escaping (Bool) -> Void) {
           runJS("RE.rangeSelectionExists()") { r in
               handler((r == "1" || r == "true")  ? true : false)
           }
       }
       
       /// Whether or not the selection has a type specifically of "Range" or "Caret".
       public func hasRangeOrCaretSelection(handler: @escaping (Bool) -> Void) {
           runJS("RE.rangeOrCaretSelectionExists()") { r in
               handler((r == "1" || r == "true") ? true : false)
           }
       }
       
    public func removeFormat() {
        runJS("RE.removeFormat();")
    }
    
    public func setFontSize(_ size: Int) {
        runJS("RE.setFontSize('\(size)px');")
    }
    public func setSelectedFontSize(_ size: Int) {
        runJS("RE.setSelecedFontSize('\(size)');")
    }
    public func setEditorBackgroundColor(_ color: UIColor) {
        runJS("RE.setBackgroundColor('\(color.hex)');")
    }
    
    public func undo() {
        runJS("RE.undo();")
    }
    
    public func redo() {
        runJS("RE.redo();")
    }
    
    public func bold() {
        runJS("RE.setBold();")
    }
    
    public func italic() {
        runJS("RE.setItalic();")
    }
    
    // "superscript" is a keyword
    public func subscriptText() {
        runJS("RE.setSubscript();")
    }
    
    public func superscript() {
        runJS("RE.setSuperscript();")
    }
    
    public func strikethrough() {
        runJS("RE.setStrikeThrough();")
    }
    
    public func underline() {
        runJS("RE.setUnderline();")
    }
    
    public func setTextColor(_ color: UIColor) {
        runJS("RE.prepareInsert();")
        runJS("RE.setTextColor('\(color.hex)');")
    }
    
    public func replaceRhyme(_ rhyme: String) {
        runJS("RE.replace('\(rhyme)');")
        runJS("RE.focusAtPoint(\(xPosition), \(yPosition));")
    }
    
    public func replaceRhymeWord(_ rhyme: String){
        runJS("RE.replaceRhyme('\(rhyme)');")
        self.performCommand("input")
    }
    
    public func rhymeModeEnable(){
        self.scrollCaretToVisible()
    }
    
    public func setEditorFontColor(_ color: UIColor) {
        runJS("RE.setBaseTextColor('\(color.hex)');")
    }
    
    public func setTextBackgroundColor(_ color: UIColor) {
        runJS("RE.prepareInsert();")
        runJS("RE.setTextBackgroundColor('\(color.hex)');")
    }
    
    public func header(_ h: Int) {
        runJS("RE.setHeading('\(h)');")
    }

    public func indent() {
        runJS("RE.setIndent();")
    }

    public func outdent() {
        runJS("RE.setOutdent();")
    }

    public func orderedList() {
        runJS("RE.setOrderedList();")
    }

    public func unorderedList() {
        runJS("RE.setUnorderedList();")
    }

    public func blockquote() {
        runJS("RE.setBlockquote()");
    }
    
    public func alignLeft() {
        runJS("RE.setJustifyLeft();")
    }
    
    public func alignCenter() {
        runJS("RE.setJustifyCenter();")
    }
    
    public func alignRight() {
        runJS("RE.setJustifyRight();")
    }
    
    public func insertImage(_ url: String, alt: String) {
        runJS("RE.prepareInsert();")
        runJS("RE.insertImage('\(url.escaped)', '\(alt.escaped)');")
    }
    
    public func insertLink(_ href: String, title: String) {
        runJS("RE.prepareInsert();")
        runJS("RE.insertLink('\(href.escaped)', '\(title.escaped)');")
    }
    
    public func focus() {
        runJS("RE.focus();")
    }

    public func focus(at: CGPoint) {
        runJS("RE.focusAtPoint(\(at.x), \(at.y));")
    }
    
    public func blur() {
        runJS("RE.blurFocus()")
    }

    /// Runs some JavaScript on the UIWebView and returns the result
    /// If there is no result, returns an empty string
    /// - parameter js: The JavaScript string to be run
    /// - returns: The result of the JavaScript that was run
    public func runJS(_ js: String, handler: ((String) -> Void)? = nil) {
        webView.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                print("WKWebViewJavascriptBridge Error: \(String(describing: error)) - JS: \(js)")
                handler?("")
                return
            }
            
            guard let handler = handler else {
                return
            }
            
            if let resultInt = result as? Int {
                handler("\(resultInt)")
                return
            }
            
            if let resultBool = result as? Bool {
                handler(resultBool ? "true" : "false")
                return
            }
            
            if let resultStr = result as? String {
                handler(resultStr)
                return
            }
            
            // no result
            handler("")
        }
    }

    // MARK: - Delegate Methods


    // MARK: UIScrollViewDelegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // We use this to keep the scroll view from changing its offset when the keyboard comes up
        if !isScrollEnabled {
            scrollView.bounds = webView.bounds
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.keyboardHide?(self)
        defaultKeyboard()
        self.resignFirstResponder()
    }
    // MARK: UIWebViewDelegate
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
           // empy
       }
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Handle pre-defined editor actions
        let callbackPrefix = "re-callback://"
        if navigationAction.request.url?.absoluteString.hasPrefix(callbackPrefix) == true {
            // When we get a callback, we need to fetch the command queue to run the commands
            // It comes in as a JSON array of commands that we need to parse
            runJS("RE.getCommandQueue()") { commands in
                if let data = commands.data(using: .utf8) {
                    
                    let jsonCommands: [String]
                    do {
                        jsonCommands = try JSONSerialization.jsonObject(with: data) as? [String] ?? []
                    } catch {
                        jsonCommands = []
                        NSLog("RichEditorView: Failed to parse JSON Commands")
                    }
                    
                    jsonCommands.forEach(self.performCommand)
                }
            }
            return decisionHandler(WKNavigationActionPolicy.cancel);
        }
        
        // User is tapping on a link, so we should react accordingly
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                if delegate?.richEditor?(self, shouldInteractWith: url) ?? false {
                    return decisionHandler(WKNavigationActionPolicy.allow);
                }
            }
        }
        
        return decisionHandler(WKNavigationActionPolicy.allow);
    }


    // MARK: UIGestureRecognizerDelegate

    /// Delegate method for our UITapGestureDelegate.
    /// Since the internal web view also has gesture recognizers, we have to make sure that we actually receive our taps.
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }


    // MARK: - Private Implementation Details
    private var contentEditable: Bool = false {
           didSet {
               editingEnabledVar = contentEditable
               if isEditorLoaded {
                   let value = (contentEditable ? "true" : "false")
                   runJS("RE.editor.contentEditable = \(value)")
               }
           }
       }
    private func isContentEditable(handler: @escaping (Bool) -> Void) {
           if isEditorLoaded {
               // to get the "editable" value is a different property, than to disable it
               // https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/contentEditable
               runJS("RE.editor.isContentEditable") { value in
                   self.editingEnabledVar = Bool(value) ?? false
               }
           }
       }
       
    /// The position of the caret relative to the currently shown content.
    /// For example, if the cursor is directly at the top of what is visible, it will return 0.
    /// This also means that it will be negative if it is above what is currently visible.
    /// Can also return 0 if some sort of error occurs between JS and here.
   private func relativeCaretYPosition(handler: @escaping (Int) -> Void) {
        runJS("RE.getRelativeCaretYPosition()") { r in
            handler(Int(r) ?? 0)
        }
    }

    private func updateHeight() {
           runJS("document.getElementById('editor').clientHeight") { heightString in
               let height = Int(heightString) ?? 0
               if self.editorHeight != height {
                   self.editorHeight = height
               }
           }
       }
    private func getClientHeight(handler: @escaping (Int) -> Void) {
        runJS("document.getElementById('editor').clientHeight") { r in
            if let r = Int(r) {
                handler(r)
            } else {
                handler(0)
            }
        }
    }
    public func getHtml(handler: @escaping (String) -> Void) {
        runJS("RE.getHtml()") { r in
            handler(r)
        }
    }
    
    /// Text representation of the data that has been input into the editor view, if it has been loaded.
    public func getText(handler: @escaping (String, Bool) -> Void) {
        runJS("RE.getText()") { r in
            handler(r,self.isEditorLoaded)
        }
    }
    public func getSelectedHref(handler: @escaping (String?) -> Void) {
        hasRangeSelection(handler: { r in
            if !r {
                handler(nil)
                return
            }
            self.runJS("RE.getSelectedHref()") { r in
                if r == "" {
                    handler(nil)
                } else {
                    handler(r)
                }
            }
        })
    }
    
    private func getLineHeight(handler: @escaping (Int) -> Void) {
         if isEditorLoaded {
             runJS("RE.getLineHeight()") { r in
                 if let r = Int(r) {
                     handler(r)
                 } else {
                     handler(DefaultInnerLineHeight)
                 }
             }
         } else {
             handler(DefaultInnerLineHeight)
         }
     }
    /// Scrolls the editor to a position where the caret is visible.
    /// Called repeatedly to make sure the caret is always visible when inputting text.
    /// Works only if the `lineHeight` of the editor is available.
    private func scrollCaretToVisible() {
        let scrollView = self.webView.scrollView
        getClientHeight(handler: { clientHeight in
            let contentHeight = clientHeight > 0 ? CGFloat(clientHeight) : scrollView.frame.height
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
            
            // XXX: Maybe find a better way to get the cursor height
            self.getLineHeight(handler: { lh in
                let lineHeight = CGFloat(lh)
                let cursorHeight = lineHeight - 4
                self.relativeCaretYPosition(handler: { r in
                    let visiblePosition = CGFloat(r)
                    var offset: CGPoint?
                    
                    if visiblePosition + cursorHeight > scrollView.bounds.size.height {
                        // Visible caret position goes further than our bounds
                        offset = CGPoint(x: 0, y: (visiblePosition + lineHeight) - scrollView.bounds.height + scrollView.contentOffset.y)
                    } else if visiblePosition < 0 {
                        // Visible caret position is above what is currently visible
                        var amount = scrollView.contentOffset.y + visiblePosition
                        amount = amount < 0 ? 0 : amount
                        offset = CGPoint(x: scrollView.contentOffset.x, y: amount)
                    }
                    
                    if let offset = offset {
                        scrollView.setContentOffset(offset, animated: true)
                    }
                })
            })
        })
    }
    
    /// Called when actions are received from JavaScript
    /// - parameter method: String with the name of the method and optional parameters that were passed in
    private func performCommand(_ method: String) {
         if method.hasPrefix("ready") {
           // If loading for the first time, we have to set the content HTML to be displayed
           if !isEditorLoaded {
                isEditorLoaded = true
                setHTML(html)
                contentHTML = html
                contentEditable = editingEnabledVar
                placeholder = placeholderText
                lineHeight = DefaultInnerLineHeight
                self.getText { (text, isLoaded) in
                    self.textCount = text.count
                }
               delegate?.richEditorDidLoad?(self)
           }
           updateHeight()
       }
        else if method.hasPrefix("input") {
            scrollCaretToVisible()
            runJS("RE.getHtml()") { content in
                self.contentHTML = content
                self.updateHeight()
                self.getText { (text, isLoaded) in
                    if text.count > 50000 && self.textCount < text.count{
                        self.delegate?.limitReached?(self)
                        self.html = self.lastHtml
                    }else{
                        self.textCount = text.count
                        if self.lastHtml != content{
                            self.checkEvents()
                        }
                        self.lastHtml = content
                    }
                }
            }
            runJS("RE.getCursrPositionValue()") { r in
                self.delegate?.getRhymeWord?(r)
            }

        }
        else if method.hasPrefix("updateHeight") {
            updateHeight()
        }
        else if method.hasPrefix("focus") {
            isOpenKeyBoard = true
            delegate?.richEditorTookFocus?(self)
        }
        else if method.hasPrefix("blur") {
            isOpenKeyBoard = false
            delegate?.richEditorLostFocus?(self)
        }
        else if method.hasPrefix("action/") {
            runJS("RE.getHtml()") { content in
                self.contentHTML = content
                
                // If there are any custom actions being called
                // We need to tell the delegate about it
                let actionPrefix = "action/"
                let range = method.range(of: actionPrefix)!
                let action = method.replacingCharacters(in: range, with: "")
                
                self.delegate?.richEditor?(self, handle: action)
            }
        }else if method.hasPrefix("copy") {
            delegate?.textCopied?(self)
        }else{
            if method.hasPrefix("click") || method.hasPrefix("touch"){
                runJS("RE.getCursrPositionValue()") { r in
                    self.delegate?.getRhymeWord?(r)
                }
            }
            self.checkEvents()
        }
    }
    public func isBold(handler: @escaping (String) -> Void) {
        runJS("RE.isBold();") { r in
            handler(r)
        }
    }
    public func isItalic(handler: @escaping (String) -> Void) {
        runJS("RE.isItalic();") { r in
            handler(r)
        }
    }
    public func isUnderLine(handler: @escaping (String) -> Void) {
        runJS("RE.isUnderline();") { r in
            handler(r)
        }
    }
    public func isStrike(handler: @escaping (String) -> Void) {
        runJS("RE.isStrike();") { r in
            handler(r)
        }
    }
    public func getColor(handler: @escaping (String) -> Void) {
        runJS("RE.getColor();") { r in
            handler(r)
        }
    }
    public func getFont(handler: @escaping (String) -> Void) {
        runJS("RE.getFontSize();") { r in
            handler(r)
        }
    }
    func checkEvents(){
        self.isBold { (str) in
            self.delegate?.getIsBold?((str == "1" || str == "true")  ? true : false)
            print("printbold",((str == "1" || str == "true")  ? true : false))
        }
        self.isItalic { (str) in
            self.delegate?.getIsItalic?((str == "1" || str == "true")  ? true : false)
            print("printisItalic",((str == "1" || str == "true")  ? true : false))
        }
        self.isUnderLine { (str) in
            self.delegate?.getIsUnderLine?((str == "1" || str == "true")  ? true : false)
            print("printisUnderLine",((str == "1" || str == "true")  ? true : false))
        }
        self.isStrike { (str) in
            self.delegate?.getIsStrike?((str == "1" || str == "true")  ? true : false)
            print("printisStrike",((str == "1" || str == "true")  ? true : false))
        }
        self.getColor { (str) in
            self.delegate?.getColor?(str)
            print("printgetColor",str)
        }
        self.getFont { (str) in
            self.delegate?.getFont?(str)
            print("printgetFont",str)
        }
    }

    override open func becomeFirstResponder() -> Bool {
        if !webView.containsFirstResponder {
            focus()
            return true
        } else {
            return false
        }
    }

    open override func resignFirstResponder() -> Bool {
        blur()
        return true
    }

}


extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.height
    }
}
