//
//  SKButton.swift
//  Extremest Sudoku
//
//  Created by Owner on 9/22/21.
//

import SpriteKit

enum ButtonNodeState {
    case Active, Selected, Hidden, Highlighted
}

class SKButton: SKSpriteNode {
    var isButtonEnabled = true
    var isHighlighted = false
    
    private var label: SKLabelNode = SKLabelNode()
    
    /* Setup a dummy action closure */
    var selectedHandler: (SKButton) -> Void = { _ in print("No button action set") }

    /* Button state management */
    var state: ButtonNodeState = .Active {
        didSet {
                switch state {
                case .Active:
                    /* Enable touch */
                    self.isUserInteractionEnabled = true

                    /* Visible */
                    //self.alpha = 1
                    self.color = self.color.withAlphaComponent(1)
                    break
                case .Selected:
                    /* Semi transparent */
                    //self.alpha = 0.5
                    self.color = self.color.withAlphaComponent(0.5)

                    break
                case .Hidden:
                    /* Disable touch */
                    self.isUserInteractionEnabled = false

                    /* Hide */
                    self.alpha = 0
                    break
                case .Highlighted:
                    /* Semi transparent */
                    self.color = self.color.withAlphaComponent(0.5)
        
                    isHighlighted = true
                    break
            }
        }
    }

    /* Support for NSKeyedArchiver (loading objects from SK Scene Editor */
    required init?(coder aDecoder: NSCoder) {

        /* Call parent initializer e.g. SKSpriteNode */
        super.init(coder: aDecoder)

        /* Enable touch on button node */
        self.isUserInteractionEnabled = true
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        label.text = ""
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.fontSize = 30
        label.fontName = "SFPro-Black"
        
        self.addChild(label)
    }
    
    func changeLabel(text: String){
        label.text = text
    }
    
    func getLabel()->String{
        return label.text ?? ""
    }
    
    func changeFontColor(color: UIColor){
        label.fontColor = color
    }
    
    func getFontColor()-> UIColor{
        return label.fontColor ?? .white
    }
    
    
    // MARK: - Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isButtonEnabled {
          // change state

            state = .Selected
            // run code assigned by other section
            // TODO: maybe its better for action to executed right the way not wait til the touch
            // has ended
            // selectedHandler(self)
        }

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isButtonEnabled {
          // run code assigned by other section
            selectedHandler(self)
            // change state back to active
            if state != .Highlighted{
                
                state = .Active
            }
        }
    }

}
