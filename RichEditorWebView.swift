//
//  RichEditorWebView.swift
//  RichEditorView
//
//  Created by admin on 21/11/19.
//

import WebKit

public class RichEditorWebView: WKWebView {

    public var accessoryView: UIView?
    public var inPutViewView: UIView?

    public override var inputAccessoryView: UIView? {
        return accessoryView
    }
    
    
    public override var inputView: UIView? {
        return inPutViewView
    }

}
