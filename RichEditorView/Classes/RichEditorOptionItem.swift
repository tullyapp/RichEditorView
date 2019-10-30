//
//  RichEditorOptionItem.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/// A RichEditorOption object is an object that can be displayed in a RichEditorToolbar.
/// This protocol is proviced to allow for custom actions not provided in the RichEditorOptions enum.
public protocol RichEditorOption {

    /// The image to be displayed in the RichEditorToolbar.
    var image: UIImage? { get }

    /// The title of the item.
    /// If `image` is nil, this will be used for display in the RichEditorToolbar.
    var title: String { get }

    /// The action to be evoked when the action is tapped
    /// - parameter editor: The RichEditorToolbar that the RichEditorOption was being displayed in when tapped.
    ///                     Contains a reference to the `editor` RichEditorView to perform actions on.
    func action(_ editor: RichEditorToolbar)
}

/// RichEditorOptionItem is a concrete implementation of RichEditorOption.
/// It can be used as a configuration object for custom objects to be shown on a RichEditorToolbar.
public struct RichEditorOptionItem: RichEditorOption {

    /// The image that should be shown when displayed in the RichEditorToolbar.
    public var image: UIImage?

    /// If an `itemImage` is not specified, this is used in display
    public var title: String

    /// The action to be performed when tapped
    public var handler: ((RichEditorToolbar) -> Void)

    public init(image: UIImage?, title: String, action: @escaping ((RichEditorToolbar) -> Void)) {
        self.image = image
        self.title = title
        self.handler = action
    }
    
    // MARK: RichEditorOption
    
    public func action(_ toolbar: RichEditorToolbar) {
        handler(toolbar)
    }
}

/// RichEditorOptions is an enum of standard editor actions
public enum RichEditorDefaultOption: RichEditorOption {
    
//    case red
//    case blue
//    case yellow
//    case purple
//    case green
//    case orange
    case color
    case underline
    case bold
    case italic
    case fontsize
    
    public static let all: [RichEditorDefaultOption] = [
//        .red,
//        .blue,
//        .yellow,
//        .purple,
//        .green,
//        .orange,
        .color,
        .underline,
        .bold,
        .italic,
        .fontsize
    ]

    // MARK: RichEditorOption

    public var image: UIImage? {
        var name = ""
        switch self {

//            case .red: name = "clear"
//            case .blue: name = "clear"
//            case .yellow: name = "clear"
//            case .purple: name = "clear"
//            case .green: name = "clear"
//            case .orange: name = "clear"
            case .color: name = "icon_Color.png"
            case .underline: name = "icon_UnderLine.png"
            case .bold: name = "icon_Bold.png"
            case .italic: name = "icon_italic.png"
            case .fontsize: name = "icon_Font.png"
        }
    
        let bundle = Bundle(for: RichEditorToolbar.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
    
    public var title: String {
        switch self {
//        case .red: return NSLocalizedString("red", comment: "")
//        case .blue: return NSLocalizedString("blue", comment: "")
//        case .yellow: return NSLocalizedString("yellow", comment: "")
//        case .purple: return NSLocalizedString("purple", comment: "")
//        case .green: return NSLocalizedString("green", comment: "")
//        case .orange: return NSLocalizedString("orange", comment: "")
        case .color: return NSLocalizedString("color", comment: "")
        case .bold: return NSLocalizedString("bold", comment: "")
        case .italic: return NSLocalizedString("italic", comment: "")
        case .underline: return NSLocalizedString("underline", comment: "")
        case .fontsize: return NSLocalizedString("fontsize", comment: "")
        }
    }
    
    public func action(_ toolbar: RichEditorToolbar) {

        switch self {
//            case .red : toolbar.delegate?.richEditorToolbarChangeTextColor?(toolbar, color: UIColor.red)
//            case .blue : toolbar.delegate?.richEditorToolbarChangeTextColor?(toolbar, color: UIColor.blue)
//            case .yellow : toolbar.delegate?.richEditorToolbarChangeTextColor?(toolbar, color: UIColor.yellow)
//            case .purple : toolbar.delegate?.richEditorToolbarChangeTextColor?(toolbar, color: UIColor.purple)
//            case .green : toolbar.delegate?.richEditorToolbarChangeTextColor?(toolbar, color: UIColor.green)
//            case .orange : toolbar.delegate?.richEditorToolbarChangeTextColor?(toolbar, color: UIColor.orange)
            case .color: toolbar.delegate?.textColor?(toolbar)
            case .underline: toolbar.editor?.underline()
            case .bold: toolbar.editor?.bold()
            case .italic: toolbar.editor?.italic()
            case .fontsize: toolbar.editor?.setFontSize(12)
            
        }
    }
}
