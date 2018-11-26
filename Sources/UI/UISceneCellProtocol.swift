//
//  UISceneCellProtocol.swift
//  CleanKit
//
//  Created by Marcos Kobuchi on 26/11/18.
//

import Foundation

protocol UISceneCellProtocol: class {
    var delegate: ActionCenterDelegate? { get set }
    var tag: Int { get set }
    
    func focus(bool: Bool)
}
