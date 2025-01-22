//
//  MarkdownParser.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/22/25.
//

import SwiftUI
import UIKit

func parseAdvancedMarkdown(_ fullText: String) -> AttributedString {
    let lines = fullText.components(separatedBy: .newlines)
    
    let mutable = NSMutableAttributedString()
    
    for (index, line) in lines.enumerated() {
        let (blockStyle, trimmedLine) = detectBlockStyle(in: line)
        
        let lineAttrString = parseInlineMarkup(trimmedLine, blockStyle: blockStyle)
        
        mutable.append(lineAttrString)
        if index < lines.count - 1 {
            mutable.append(NSAttributedString(string: "\n"))
        }
    }
    
    return AttributedString(mutable)
}

enum BlockStyle {
    case normal
    case heading1
    case heading2
    case listItem
    case checkboxUnchecked
    case checkboxChecked
}

private func detectBlockStyle(in line: String) -> (BlockStyle, String) {
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    
    if trimmed.hasPrefix("## ") {
        return (.heading2, String(trimmed.dropFirst(3)))
    } else if trimmed.hasPrefix("# ") {
        return (.heading1, String(trimmed.dropFirst(2)))
    } else if trimmed.hasPrefix("- [ ]") {
        let remainder = String(trimmed.dropFirst(5).trimmingCharacters(in: .whitespaces))
        return (.checkboxUnchecked, remainder)
    } else if trimmed.hasPrefix("- [✓]") {
        let remainder = String(trimmed.dropFirst(5).trimmingCharacters(in: .whitespaces))
        return (.checkboxChecked, remainder)
    } else if trimmed.hasPrefix("- ") {
        let remainder = String(trimmed.dropFirst(2).trimmingCharacters(in: .whitespaces))
        return (.listItem, remainder)
    }
    
    return (.normal, trimmed)
}

private func parseInlineMarkup(_ text: String, blockStyle: BlockStyle) -> NSAttributedString {
    let mutable = NSMutableAttributedString()
    
    switch blockStyle {
    case .listItem:
        let bulletPrefix = "•  "
        mutable.append(NSAttributedString(string: bulletPrefix, attributes: blockAttributes(for: blockStyle)))
    case .checkboxUnchecked:
        let checkboxPrefix = "[ ] "
        mutable.append(NSAttributedString(string: checkboxPrefix, attributes: blockAttributes(for: blockStyle)))
    case .checkboxChecked:
        let checkedPrefix = "[✓] "
        mutable.append(NSAttributedString(string: checkedPrefix, attributes: blockAttributes(for: blockStyle)))
    default:
        break
    }
    
    let inlineAttrString = parseInlineTokens(text, blockStyle: blockStyle)
    
    mutable.append(inlineAttrString)
    
    return mutable
}

fileprivate enum InlineToken: Equatable {
    case bold           // triggered by *
    case italic         // triggered by _
    case underline      // triggered by ~
    case strikethrough  // triggered by -
    case code           // triggered by backticks `
    case color(String)  // e.g. color=red
}

private func parseInlineTokens(_ text: String, blockStyle: BlockStyle) -> NSAttributedString {
    let mutable = NSMutableAttributedString()
    
    let baseAttrs = blockAttributes(for: blockStyle)
    
    var openTokens: [InlineToken] = []
    var currentText = ""
    
    var i = text.startIndex
    while i < text.endIndex {
        let c = text[i]
        
        // Step A: check for a color block
        if c == "{" && text.suffix(from: i).hasPrefix("{color:") {
            // find the closing } for the color definition
            if let closeIndex = text.suffix(from: i).firstIndex(of: "}"), closeIndex > i {
                // e.g. {color: red}
                let substring = text[text.index(i, offsetBy: 8)..<closeIndex] // get "red"; offsetBy: 8 is accounting for {color: chars
                let colorName = substring.trimmingCharacters(in: .whitespaces)
                
                if !currentText.isEmpty {
                    mutable.append(makeSegment(currentText, baseAttrs: baseAttrs, openTokens: openTokens))
                    currentText = ""
                }
                
                openTokens.append(.color(colorName))
                
                i = text.index(closeIndex, offsetBy: 1) // skips the closing "}"
                continue
            }
        }
        
        // Step B: check if we're closing a color block
        if text.suffix(from: i).hasPrefix("{color}") {
            if let colorIndex = openTokens.lastIndex(where: {
                if case .color(_) = $0 { return true }
                return false
            }) {
                if !currentText.isEmpty {
                    mutable.append(makeSegment(currentText, baseAttrs: baseAttrs, openTokens: openTokens))
                    currentText = ""
                }
                
                openTokens.remove(at: colorIndex)
            }
            
            i = text.index(i, offsetBy: 7) // skip "{color}"
            continue
        }
        
        // Step C: check single char delimiters for inline styles
        if let token = inlineToken(for: c) {
            if let idx = openTokens.lastIndex(of: token) {
                if !currentText.isEmpty {
                    mutable.append(makeSegment(currentText, baseAttrs: baseAttrs, openTokens: openTokens))
                    currentText = ""
                }
                openTokens.remove(at: idx)
            } else {
                if !currentText.isEmpty {
                    mutable.append(makeSegment(currentText, baseAttrs: baseAttrs, openTokens: openTokens))
                    currentText = ""
                }
                openTokens.append(token)
            }
            
            i = text.index(after: i)
            continue
        }
        
        // Otherwise, it's a normal char
        currentText.append(c)
        i = text.index(after: i)
    }
    
    // End of line: append any leftover text
    if !currentText.isEmpty {
        mutable.append(makeSegment(currentText, baseAttrs: baseAttrs, openTokens: openTokens))
    }
    
    return mutable
}

private func inlineToken(for c: Character) -> InlineToken? {
    switch c {
    case "*": return .bold
    case "_": return .italic
    case "~": return .underline
    case "`": return .code
    case "-": return .strikethrough
    default: return nil
    }
}

private func blockAttributes(for style: BlockStyle) -> [NSAttributedString.Key: Any] {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.headIndent = 20
    paragraphStyle.firstLineHeadIndent = 20
    
    switch style {
    case .heading1:
        return [.font: UIFont.boldSystemFont(ofSize: 24)]
    case .heading2:
        return [.font: UIFont.boldSystemFont(ofSize: 20)]
    case .listItem, .checkboxChecked, .checkboxUnchecked:
        // need indent and bullet point still...
        return [
            .font: UIFont.systemFont(ofSize: 16),
            .paragraphStyle: paragraphStyle
        ]
    case .normal:
        return [.font: UIFont.systemFont(ofSize: 16)]
    }
}

private func makeSegment(_ text: String, baseAttrs: [NSAttributedString.Key: Any], openTokens: [InlineToken]) -> NSAttributedString {
    let mutable = NSMutableAttributedString(string: text, attributes: baseAttrs)
    
    for token in openTokens {
        switch token {
        case .bold:
            applyFontTrait(mutable, trait: .traitBold)
        case .italic:
            applyFontTrait(mutable, trait: .traitItalic)
        case .underline:
            mutable.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: mutable.length))
        case .strikethrough:
            mutable.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: mutable.length))
        case .code:
            mutable.addAttributes([
                .font: UIFont(name: "Menlo", size: 16)
                    ?? UIFont.monospacedSystemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor.green,
                .backgroundColor: UIColor(white: 0.1, alpha: 1.0),
            ], range: NSRange(location: 0, length: mutable.length))
        case .color(let colorName):
            if let uiColor = colorFromString(colorName) {
                mutable.addAttribute(.foregroundColor, value: uiColor, range: NSRange(location: 0, length: mutable.length))
            }
        }
    }
    
    return mutable
}

private func applyFontTrait(_ mutable: NSMutableAttributedString, trait: UIFontDescriptor.SymbolicTraits) {
    mutable.enumerateAttributes(in: NSRange(location: 0, length: mutable.length), options: []) { attrs, range, _ in
        if let font = attrs[.font] as? UIFont {
            if let descriptor = font.fontDescriptor.withSymbolicTraits(trait) {
                let newFont = UIFont(descriptor: descriptor, size: font.pointSize)
                mutable.addAttribute(.font, value: newFont, range: range)
            }
        }
    }
}

private func colorFromString(_ colorName: String) -> UIColor? {
    switch colorName.lowercased() {
    // Standard colors
    case "red": return .red
    case "orange": return .orange
    case "yellow": return .yellow
    case "green": return .green
    case "cyan": return .cyan
    case "blue": return .blue
    case "purple": return .purple
    case "magenta": return .magenta
    case "brown": return .brown
    case "black": return .black
    case "darkGray": return .darkGray
    case "gray": return .gray
    case "lightGray": return .lightGray
    case "white": return .white
    // System colors
    case "sysPink": return .systemPink
    case "sysRed": return .systemRed
    case "sysOrange": return .systemOrange
    case "sysYellow": return .systemYellow
    case "sysMint": return .systemMint
    case "sysGreen": return .systemGreen
    case "sysTeal": return .systemTeal
    case "sysCyan": return .systemCyan
    case "sysBlue": return .systemBlue
    case "sysIndigo": return .systemIndigo
    case "sysPurple": return .systemPurple
    case "sysBrown": return .systemBrown
    default: return nil
    }
}
