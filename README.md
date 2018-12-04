# MealWheel
MealWheel is an iOS 11.4+ app developed as part of [Udacity's iOS program](https://www.udacity.com/school-of-programming).

MealWheel offers a quick and fun way to decide where to eat, when the momentary consensus game among peers simply isn't cutting it.

## About
MealWheel interfaces with **Yelp's GraphQL API** using **Apollo** to display nearby restaurants using the device's **location data**. The restaurants are presented to the user in a roulette-wheel style format, which the user can spin to land on a random place. The app adds customization features including
- Custom restaurants
- Filter settings based on location and frequency of visits
- Blacklist/whitelist functionality

This data is persisted using the **CoreData** stack, and while others settings are saved using **NSUserDefaults.**

## Running Mealwheel
### Requirements
* Xcode 10 or later
* Cocoapods (see [here](https://guides.cocoapods.org/using/getting-started.html))
### Setup
1. Download or clone the git repository
2. `cd` to the project directory and install the Cocoapods dependencies with `pod install`
3. Open the generated _MealWheel.xcworkspace_ file (don't use _MealWheel.xcodeproj_)
3. Build and run the project (`cmd + r`)

## Issues
* If the user inputs an invalid location, the geocoder will not prompt the user about an unlikely location, and the restaurant might very well be saved with a weird location. Like, in the middle of the Pacific. No bueno.
* One of the xibs might be causing an Xcode view refresh loop. Unknown if this is an Xcode problem or something with the code. Try disabling "Automatically Refresh Views" under "Editor >" when focused on the storyboard. 

## Todo
* [x] Clean up UI elements which correspond to features not yet implemented
* [x] Remove unnecessary YelpAPI methods
* [ ] Remove duplicate and commented-out code
* [ ] Remove unused assets
* [x] Add license info
* [ ] Fix geocoding - it's still clunky

## Notes
* Apollo's build-time configuration should be all set, but if for some reason you're getting errors with the API, see [here](https://www.apollographql.com/docs/ios/installation.html#adding-build-step)

## Contributing
* Do as thou wilt. The author would be more than flattered if anyone thinks this project is neat.

## Acknowledgements
This project gratefully implements the following third party libraries and services:
* [Yelp](https://www.yelp.com/) GraphQL API
* [SpinWheelControl](https://github.com/joshdhenry/SpinWheelControl) for the main wheel in the app
* [Apollo](https://github.com/apollographql/apollo-ios) for its networking layer
* [Cosmos](https://github.com/evgenyneu/Cosmos) for ratings views

The author would also like to thank
* The [StackOverflow](https://stackoverflow.com/) community, which has saved countless hours of frustration
* [Udacity](https://www.udacity.com/) courses, for their intuitive and direct learning environment

## License
* MealWheel is distributed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html)
* Third-party libraries and dependencies retain their respective licenses. See LICENSE file for details.
