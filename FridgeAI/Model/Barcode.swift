//
//  Barcode.swift
//  FridgeAI
//
//  Created by Michael Ilic on 18.04.25.
//

import Foundation
import CodeScanner

struct ProductResponse: Codable {
    let product: Product
}

struct Product: Codable {
    let product_name: String?
    let image_url: String?
}
