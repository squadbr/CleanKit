//
//  ProductDetailInteractor.swift
//  Example
//
//  Created by Wellington Marthas on 03/09/18.
//  Copyright © 2018 Wellington Marthas. All rights reserved.
//

import CleanKit

protocol ProductDetailInteractorProtocol {
    func locations() -> [LocationEntity]
    func details() -> [ProductDetailEntity]
}

class ProductDetailInteractor : Interactor, ProductDetailInteractorProtocol {
    func details() -> [ProductDetailEntity] {
        var list = [ProductDetailEntity]()
        
        for i in 0...10 {
            list.append(ProductDetailEntity(name: "Name \(i)", detail: "Detail \(i)"))
        }
        
        return list
    }
    
    func locations() -> [LocationEntity] {
        var list = [LocationEntity]()
        
        for _ in 0...10 {
            //list.append(FeedEntity(title: "Test 1", content: "Test of feed"))
        }
        
        return list
    }
}
