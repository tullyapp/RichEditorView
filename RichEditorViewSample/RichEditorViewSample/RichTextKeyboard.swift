//
//  RichTextKeyboard.swift
//  Tully Dev
//
//  Created by admin on 13/11/19.
//  Copyright © 2019 Tully. All rights reserved.
//

import UIKit

protocol KeyboardDelegate: class {
    func bold()
    func italic()
    func underLine()
    func strike()
    func smallFont()
    func mediamFont()
    func largeFont()
    func leftAlign()
    func centerAlign()
    func rightAlign()
    func numberAlign()
    func bulletAlign()
    func color(_ color: UIColor)
    func keybpardTapped()
}

class RichTextKeyboard: UIView {
    
    @IBOutlet weak var boldView: UIView!
    @IBOutlet weak var italicView: UIView!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var strikeView: UIView!
    @IBOutlet weak var smallFontView: UIView!
    @IBOutlet weak var mediamFontView: UIView!
    @IBOutlet weak var largeFontView: UIView!
    @IBOutlet weak var leftAlignView: UIView!
    @IBOutlet weak var centerAlignView: UIView!
    @IBOutlet weak var rightAlignView: UIView!
    @IBOutlet weak var numberAlignView: UIView!
    @IBOutlet weak var bulletsAlignView: UIView!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var blueView: UIView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var orangeView: UIView!
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var pinkView: UIView!
    @IBOutlet weak var yellowView: UIView!
    @IBOutlet weak var purpleView: UIView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var slateView: UIView!
    
    static let dafaultColor = UIColor(red: 50/255, green: 52/255, blue: 63/255, alpha: 1.0)
    static let selectedColor = UIColor(red: 23/255, green: 255/255, blue: 156/255, alpha: 1.0)
    
    let colors = [UIColor(red: 249/255, green: 45/255, blue: 4/255, alpha: 1.0),
                      UIColor(red: 255/255, green: 99/255, blue: 43/255, alpha: 1.0),
                    UIColor(red: 255/255, green: 238/255, blue: 0/255, alpha: 1.0),
                    UIColor(red: 51/255, green: 124/255, blue: 108/255, alpha: 1.0),
                    UIColor(red: 26/255, green: 99/255, blue: 244/255, alpha: 1.0),
                    UIColor(red: 44/255, green: 42/255, blue: 114/255, alpha: 1.0),
                    UIColor(red: 237/255, green: 116/255, blue: 122/255, alpha: 1.0),
                    UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0),
                    UIColor(red: 33/255, green: 28/255, blue: 28/255, alpha: 1.0),
                    UIColor(red: 10/255, green: 9/255, blue: 12/255, alpha: 1.0)

    ]
    weak var delegate: KeyboardDelegate?
    // MARK:- keyboard initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }

    func initializeSubviews() {
        let view = Bundle.main.loadNibNamed(String(describing: RichTextKeyboard.self), owner: self, options: nil)![0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
        clearSelectedColors()
    }
    
    func clearSelectedColors(){
        greenView.alpha = 0.0
        blueView.alpha = 0.0
        grayView.alpha = 0.0
        orangeView.alpha = 0.0
        redView.alpha = 0.0
        pinkView.alpha = 0.0
        yellowView.alpha = 0.0
        purpleView.alpha = 0.0
        blackView.alpha = 0.0
        slateView.alpha = 0.0
    }
    func selectedColor(_ color: UIColor){
       if let index = colors.index(of: color){
            clearSelectedColors()
            switch Int(index) {
                case 0:
                    redView.alpha = 1.0
                    break
                case 1:
                    orangeView.alpha = 1.0
                    break
                case 2:
                    yellowView.alpha = 1.0
                    break
                case 3:
                    greenView.alpha = 1.0
                    break
                case 4:
                    blueView.alpha = 1.0
                    break
                case 5:
                    purpleView.alpha = 1.0
                    break
                case 6:
                    pinkView.alpha = 1.0
                    break
                case 7:
                    grayView.alpha = 1.0
                    break
                case 8:
                    slateView.alpha = 1.0
                    break
                case 9:
                    blackView.alpha = 1.0
                    break
                default:
                    break
            }
        }
    }
    func selectedFont(_ font: Int){
        clearSelectedFonts()
        switch font {
            case 0:
                self.smallFontView.backgroundColor = RichTextKeyboard.selectedColor
                break
            case 1:
                self.mediamFontView.backgroundColor = RichTextKeyboard.selectedColor
                break
            case 2:
                self.largeFontView.backgroundColor = RichTextKeyboard.selectedColor
                break
            default:
                break
        }
    }
    
    func clearSelectedFonts(){
        self.smallFontView.backgroundColor = RichTextKeyboard.dafaultColor
        self.mediamFontView.backgroundColor = RichTextKeyboard.dafaultColor
        self.largeFontView.backgroundColor = RichTextKeyboard.dafaultColor
    }
    func roundCorners(){
        self.boldView.roundCorners(corners: [.topLeft,.bottomLeft], radius: 6.0)
        self.strikeView.roundCorners(corners: [.topRight,.bottomRight], radius: 6.0)
        self.smallFontView.roundCorners(corners: [.topLeft,.bottomLeft], radius: 6.0)
        self.largeFontView.roundCorners(corners: [.topRight,.bottomRight], radius: 6.0)

        self.leftAlignView.roundCorners(corners: [.topLeft,.bottomLeft], radius: 6.0)
        self.rightAlignView.roundCorners(corners: [.topRight,.bottomRight], radius: 6.0)
        self.numberAlignView.roundCorners(corners: [.topLeft,.bottomLeft], radius: 6.0)
        self.bulletsAlignView.roundCorners(corners: [.topRight,.bottomRight], radius: 6.0)

    }
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.roundCorners()
        }
    }
    // MARK:- Button actions from .xib file

    @IBAction func boldTapped(sender: UIButton) {
        self.delegate?.bold()
    }
    @IBAction func italicTapped(sender: UIButton) {
        self.delegate?.italic()
    }
    @IBAction func underLineTapped(sender: UIButton) {
        self.delegate?.underLine()
    }
    @IBAction func strikeTapped(sender: UIButton) {
        self.delegate?.strike()
    }
    @IBAction func smallFontTapped(sender: UIButton) {
        self.delegate?.smallFont()
    }
    @IBAction func mediamFontTapped(sender: UIButton) {
        self.delegate?.mediamFont()
    }
    @IBAction func largeFontTapped(sender: UIButton) {
        self.delegate?.largeFont()
    }
    @IBAction func leftAlignTapped(sender: UIButton) {
        self.leftAlignView.backgroundColor = RichTextKeyboard.selectedColor
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.15) {
            self.leftAlignView.backgroundColor = RichTextKeyboard.dafaultColor
        }
        self.delegate?.leftAlign()
    }
    @IBAction func centerAlignTapped(sender: UIButton) {
        self.delegate?.centerAlign()
        self.centerAlignView.backgroundColor = RichTextKeyboard.selectedColor
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.15) {
            self.centerAlignView.backgroundColor = RichTextKeyboard.dafaultColor
        }
    }
    @IBAction func rightAlignTapped(sender: UIButton) {
        self.rightAlignView.backgroundColor = RichTextKeyboard.selectedColor
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.15) {
            self.rightAlignView.backgroundColor = RichTextKeyboard.dafaultColor
        }
        self.delegate?.rightAlign()
    }
    @IBAction func numberFormatTapped(sender: UIButton) {
        self.numberAlignView.backgroundColor = RichTextKeyboard.selectedColor
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.15) {
            self.numberAlignView.backgroundColor = RichTextKeyboard.dafaultColor
        }
        self.delegate?.numberAlign()
    }
    @IBAction func bulletsFormatTapped(sender: UIButton) {
        self.bulletsAlignView.backgroundColor = RichTextKeyboard.selectedColor
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.15) {
            self.bulletsAlignView.backgroundColor = RichTextKeyboard.dafaultColor
        }
        self.delegate?.bulletAlign()
    }
    @IBAction func colorTapped(_ sender: UIButton) {
        self.clearSelectedColors()
        let color = self.colors[sender.tag]
        switch sender.tag {
             case 0:
                redView.alpha = 1.0
                break
            case 1:
                orangeView.alpha = 1.0
                break
            case 2:
                yellowView.alpha = 1.0
                break
            case 3:
                greenView.alpha = 1.0
                break
            case 4:
                blueView.alpha = 1.0
                break
            case 5:
                purpleView.alpha = 1.0
                break
            case 6:
                pinkView.alpha = 1.0
                break
            case 7:
                grayView.alpha = 1.0
                break
            case 8:
                slateView.alpha = 1.0
                break
            case 9:
                blackView.alpha = 1.0
                break
            default:
                break
        }
        self.delegate?.color(color)
    }
    @IBAction func keyboardTapped(_ sender: UIButton) {
        self.delegate?.keybpardTapped()
    }
}
extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
