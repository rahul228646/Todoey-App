//
//  Category.swift
//  Todoey
//
//  Created by rahul kaushik on 05/10/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name : String = ""
    @objc dynamic var color : String?
    let items = List<Item>()
}
