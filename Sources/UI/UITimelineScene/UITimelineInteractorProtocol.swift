//
//  UITimelineInteractor.swift
//  Squad
//
//  Created by Marcos Kobuchi on 09/10/18.
//  Copyright © 2018 Erwin GO. All rights reserved.
//

import Foundation

public protocol UITimelineInteractorProtocol: InteractorProtocol {
    associatedtype T: Codable
    func fetch(page: Int) throws -> [T]
}
