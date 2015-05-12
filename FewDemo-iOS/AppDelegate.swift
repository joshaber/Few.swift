//
//  AppDelegate.swift
//  FewDemo-iOS
//
//  Created by Coen Wessels on 13/03/15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit
import Few

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	
	private let appComponent = Component(
		initialState: AppState(
			tableViewComponent: TableViewDemo(),
			counterComponent: Counter(),
			inputComponent: InputDemo(),
			activeComponent: .TableView
		),
		render: renderApp
	)
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		let vc = UIViewController()
		vc.view.backgroundColor = UIColor.whiteColor()
		appComponent.addToView(vc.view)
		window?.rootViewController = vc
		window?.makeKeyAndVisible()
		
		return true
	}
}

