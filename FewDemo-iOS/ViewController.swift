//
//  ViewController.swift
//  FewDemo-iOS
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit
import Few

class ViewController: UIViewController {
    private let counter = Component(initialState: 0, render: renderCounter)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        counter.addToView(view)
    }
}

