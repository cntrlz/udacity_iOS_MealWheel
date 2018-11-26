//  This file was automatically generated and should not be edited.

import Apollo

public final class RestaurantsQuery: GraphQLQuery {
  public let operationDefinition =
    "query Restaurants($term: String, $limit: Int, $long: Float, $lat: Float, $cat: String, $radius: Float) {\n  search(term: $term, limit: $limit, latitude: $lat, longitude: $long, categories: $cat, radius: $radius) {\n    __typename\n    business {\n      __typename\n      ...BusinessDetails\n    }\n    total\n  }\n}"

  public var queryDocument: String { return operationDefinition.appending(BusinessDetails.fragmentDefinition) }

  public var term: String?
  public var limit: Int?
  public var long: Double?
  public var lat: Double?
  public var cat: String?
  public var radius: Double?

  public init(term: String? = nil, limit: Int? = nil, long: Double? = nil, lat: Double? = nil, cat: String? = nil, radius: Double? = nil) {
    self.term = term
    self.limit = limit
    self.long = long
    self.lat = lat
    self.cat = cat
    self.radius = radius
  }

  public var variables: GraphQLMap? {
    return ["term": term, "limit": limit, "long": long, "lat": lat, "cat": cat, "radius": radius]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("search", arguments: ["term": GraphQLVariable("term"), "limit": GraphQLVariable("limit"), "latitude": GraphQLVariable("lat"), "longitude": GraphQLVariable("long"), "categories": GraphQLVariable("cat"), "radius": GraphQLVariable("radius")], type: .object(Search.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(search: Search? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "search": search.flatMap { (value: Search) -> ResultMap in value.resultMap }])
    }

    /// Search for businesses on Yelp.
    public var search: Search? {
      get {
        return (resultMap["search"] as? ResultMap).flatMap { Search(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "search")
      }
    }

    public struct Search: GraphQLSelectionSet {
      public static let possibleTypes = ["Businesses"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("business", type: .list(.object(Business.selections))),
        GraphQLField("total", type: .scalar(Int.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(business: [Business?]? = nil, total: Int? = nil) {
        self.init(unsafeResultMap: ["__typename": "Businesses", "business": business.flatMap { (value: [Business?]) -> [ResultMap?] in value.map { (value: Business?) -> ResultMap? in value.flatMap { (value: Business) -> ResultMap in value.resultMap } } }, "total": total])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// A list of business Yelp finds based on the search criteria.
      public var business: [Business?]? {
        get {
          return (resultMap["business"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Business?] in value.map { (value: ResultMap?) -> Business? in value.flatMap { (value: ResultMap) -> Business in Business(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Business?]) -> [ResultMap?] in value.map { (value: Business?) -> ResultMap? in value.flatMap { (value: Business) -> ResultMap in value.resultMap } } }, forKey: "business")
        }
      }

      /// Total number of businesses found.
      public var total: Int? {
        get {
          return resultMap["total"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "total")
        }
      }

      public struct Business: GraphQLSelectionSet {
        public static let possibleTypes = ["Business"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(BusinessDetails.self),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var businessDetails: BusinessDetails {
            get {
              return BusinessDetails(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }
}

public struct BusinessDetails: GraphQLFragment {
  public static let fragmentDefinition =
    "fragment BusinessDetails on Business {\n  __typename\n  id\n  name\n  rating\n  url\n  categories {\n    __typename\n    title\n    alias\n    parent_categories {\n      __typename\n      title\n      alias\n    }\n  }\n  display_phone\n  review_count\n  price\n  coordinates {\n    __typename\n    latitude\n    longitude\n  }\n  distance\n}"

  public static let possibleTypes = ["Business"]

  public static let selections: [GraphQLSelection] = [
    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
    GraphQLField("id", type: .scalar(String.self)),
    GraphQLField("name", type: .scalar(String.self)),
    GraphQLField("rating", type: .scalar(Double.self)),
    GraphQLField("url", type: .scalar(String.self)),
    GraphQLField("categories", type: .list(.object(Category.selections))),
    GraphQLField("display_phone", type: .scalar(String.self)),
    GraphQLField("review_count", type: .scalar(Int.self)),
    GraphQLField("price", type: .scalar(String.self)),
    GraphQLField("coordinates", type: .object(Coordinate.selections)),
    GraphQLField("distance", type: .scalar(Double.self)),
  ]

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: String? = nil, name: String? = nil, rating: Double? = nil, url: String? = nil, categories: [Category?]? = nil, displayPhone: String? = nil, reviewCount: Int? = nil, price: String? = nil, coordinates: Coordinate? = nil, distance: Double? = nil) {
    self.init(unsafeResultMap: ["__typename": "Business", "id": id, "name": name, "rating": rating, "url": url, "categories": categories.flatMap { (value: [Category?]) -> [ResultMap?] in value.map { (value: Category?) -> ResultMap? in value.flatMap { (value: Category) -> ResultMap in value.resultMap } } }, "display_phone": displayPhone, "review_count": reviewCount, "price": price, "coordinates": coordinates.flatMap { (value: Coordinate) -> ResultMap in value.resultMap }, "distance": distance])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// Yelp ID of this business.
  public var id: String? {
    get {
      return resultMap["id"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  /// Name of this business.
  public var name: String? {
    get {
      return resultMap["name"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

  /// Rating for this business (value ranges from 1, 1.5, ... 4.5, 5).
  public var rating: Double? {
    get {
      return resultMap["rating"] as? Double
    }
    set {
      resultMap.updateValue(newValue, forKey: "rating")
    }
  }

  /// URL for business page on Yelp.
  public var url: String? {
    get {
      return resultMap["url"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "url")
    }
  }

  /// A list of category title and alias pairs associated with this business.
  public var categories: [Category?]? {
    get {
      return (resultMap["categories"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Category?] in value.map { (value: ResultMap?) -> Category? in value.flatMap { (value: ResultMap) -> Category in Category(unsafeResultMap: value) } } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [Category?]) -> [ResultMap?] in value.map { (value: Category?) -> ResultMap? in value.flatMap { (value: Category) -> ResultMap in value.resultMap } } }, forKey: "categories")
    }
  }

  /// Phone number of the business formatted nicely to be displayed to users. The format is the standard phone number format for the business's country.
  public var displayPhone: String? {
    get {
      return resultMap["display_phone"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "display_phone")
    }
  }

  /// Number of reviews for this business.
  public var reviewCount: Int? {
    get {
      return resultMap["review_count"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "review_count")
    }
  }

  /// Price level of the business. Value is one of $, $$, $$$ and $$$$ or null if we don't have price available for the business.
  public var price: String? {
    get {
      return resultMap["price"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "price")
    }
  }

  /// The coordinates of this business.
  public var coordinates: Coordinate? {
    get {
      return (resultMap["coordinates"] as? ResultMap).flatMap { Coordinate(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "coordinates")
    }
  }

  /// When searching, this provides the distance of the business from the search location in meters
  public var distance: Double? {
    get {
      return resultMap["distance"] as? Double
    }
    set {
      resultMap.updateValue(newValue, forKey: "distance")
    }
  }

  public struct Category: GraphQLSelectionSet {
    public static let possibleTypes = ["Category"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("title", type: .scalar(String.self)),
      GraphQLField("alias", type: .scalar(String.self)),
      GraphQLField("parent_categories", type: .list(.object(ParentCategory.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(title: String? = nil, alias: String? = nil, parentCategories: [ParentCategory?]? = nil) {
      self.init(unsafeResultMap: ["__typename": "Category", "title": title, "alias": alias, "parent_categories": parentCategories.flatMap { (value: [ParentCategory?]) -> [ResultMap?] in value.map { (value: ParentCategory?) -> ResultMap? in value.flatMap { (value: ParentCategory) -> ResultMap in value.resultMap } } }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// Title of a category for display purposes.
    public var title: String? {
      get {
        return resultMap["title"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "title")
      }
    }

    /// Alias of a category, when searching for business in certain categories, use alias rather than the title.
    public var alias: String? {
      get {
        return resultMap["alias"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "alias")
      }
    }

    /// List of parent categories.
    public var parentCategories: [ParentCategory?]? {
      get {
        return (resultMap["parent_categories"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [ParentCategory?] in value.map { (value: ResultMap?) -> ParentCategory? in value.flatMap { (value: ResultMap) -> ParentCategory in ParentCategory(unsafeResultMap: value) } } }
      }
      set {
        resultMap.updateValue(newValue.flatMap { (value: [ParentCategory?]) -> [ResultMap?] in value.map { (value: ParentCategory?) -> ResultMap? in value.flatMap { (value: ParentCategory) -> ResultMap in value.resultMap } } }, forKey: "parent_categories")
      }
    }

    public struct ParentCategory: GraphQLSelectionSet {
      public static let possibleTypes = ["Category"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("title", type: .scalar(String.self)),
        GraphQLField("alias", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(title: String? = nil, alias: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Category", "title": title, "alias": alias])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Title of a category for display purposes.
      public var title: String? {
        get {
          return resultMap["title"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }

      /// Alias of a category, when searching for business in certain categories, use alias rather than the title.
      public var alias: String? {
        get {
          return resultMap["alias"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "alias")
        }
      }
    }
  }

  public struct Coordinate: GraphQLSelectionSet {
    public static let possibleTypes = ["Coordinates"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("latitude", type: .scalar(Double.self)),
      GraphQLField("longitude", type: .scalar(Double.self)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(latitude: Double? = nil, longitude: Double? = nil) {
      self.init(unsafeResultMap: ["__typename": "Coordinates", "latitude": latitude, "longitude": longitude])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The latitude of this business.
    public var latitude: Double? {
      get {
        return resultMap["latitude"] as? Double
      }
      set {
        resultMap.updateValue(newValue, forKey: "latitude")
      }
    }

    /// The longitude of this business.
    public var longitude: Double? {
      get {
        return resultMap["longitude"] as? Double
      }
      set {
        resultMap.updateValue(newValue, forKey: "longitude")
      }
    }
  }
}