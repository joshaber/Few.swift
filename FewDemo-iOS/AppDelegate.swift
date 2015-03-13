//
//  AppDelegate.swift
//  FewDemo-iOS
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit
import Few

func renderCounter(component: Component<Int>, count: Int) -> Element {
    let updateCounter = {
        component.updateState { $0 + 1 }
    }
    
    return Few.View()
        // The view itself should be centered.
        .justification(.Center)
        // The children should be centered in the view.
        .childAlignment(.Center)
        // Layout children in a column.
        .direction(.Column)
        .children([
            Label("You've clicked \(count) times!"),
            Button(title: "Click me!", action: updateCounter)
                .margin(Edges(uniform: 10))
                .width(100),
        ])
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
}

