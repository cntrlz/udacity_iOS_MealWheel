//
//  AppDelegate.swift
//  MealWheel
//
//  Created by benchmark on 8/30/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//


// TODO: Rebase old commit messages with multiple "initial commit"
// TODO: Create README
// TODO: Fix distance calculation being screwy. Is YelpAPI getting proper lat/long? Or is local calculation shit?

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	let locationManager = CLLocationManager()
	var lastLocation: CLLocation = CLLocation()
	

	let apiClient = YelpAPI()
	let dataController = DataController(modelName: "MealWheel")

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Use this for inspecting the Core Data
//		if let directoryLocation = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
//			print("Documents Directory: \(directoryLocation)Application Support")
//			print("Home Directory: \(NSHomeDirectory())")
//		}
		
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		print(urls[urls.count-1] as URL)

		setUpLocationManager()
		registerUserDefaults()
		dataController.load()

		if !UserDefaults.standard.bool(forKey: "firstRun") {
			print("No first run")
		} else {
			let maxDist = UserDefaults.standard.integer(forKey: "maxDistance")
			print("We have firstRun. MaxDist is: \(maxDist)")
		}
		
		if !UserDefaults.standard.bool(forKey: "landingPage") {
			window = UIWindow(frame: UIScreen.main.bounds)
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let initialViewController = storyboard.instantiateViewController(withIdentifier: "tabBarController")
			window?.rootViewController = initialViewController
			window?.makeKeyAndVisible()
		}

//		let tabController = window?.rootViewController as! UITabBarController
//		let navController = tabController.viewControllers?.first as! UINavigationController
//		let wheelViewController = navController.topViewController as! WheelViewController
//		wheelViewController.dataController = dataController
		
		

//		let fileName = "appGUID.txt"
//		let path = NSURL(fileURLWithPath:
//			NSTemporaryDirectory()).appendingPathComponent(fileName)
//		let myText = "\(NSHomeDirectory())"
//		do {
//			try myText.write(to: path!, atomically: true, encoding: .utf8)
//
//		} catch {
//			// Handle error
//		}

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
}

// Separate MealWheel-specific functions
extension AppDelegate {
	func registerUserDefaults() {
		if let path = Bundle.main.path(forResource: "DefaultPreferences", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
			UserDefaults.standard.register(defaults: dict)
			print("User defaults registered")
		}
	}
}


// MARK: - Location
extension AppDelegate: CLLocationManagerDelegate {
	func setUpLocationManager() {
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}
	
	func updateLocation(_ location: CLLocation) {
//		print("updated location")
		lastLocation = location
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		updateLocation(locations.last! as CLLocation)
	}
}

extension AppDelegate {
	func locationEnabled() -> Bool {
		if CLLocationManager.locationServicesEnabled() {
			switch CLLocationManager.authorizationStatus() {
			case .notDetermined, .restricted, .denied:
				return false
			case .authorizedAlways, .authorizedWhenInUse:
				return true
			}
		} else {
			print("Location services are not enabled")
			return false
		}
	}
}
