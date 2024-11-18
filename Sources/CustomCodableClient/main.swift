import CustomCodable
import Foundation

// MARK: - ExpressionMacro

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")

print(#URL("https://swift.org/")) // Output: URL(string: "https://swift.org/")!
// let domain = "domain.com"
// print(#URL("https://\(domain)/api/path")) // Error: #URL requires a static string literal
// print(#URL("https://not a url.com")) // Error: Malformed url

// MARK: - DeclarationMacro

enum TestClass {
    #declareStaticValue(1)
    
    static func test() {
//        print("Const.value: \(Const.value)")
    }
}

TestClass.test()

@MainActor
public enum Constaints {
    #Constant("app_icon")
    #Constant("empty_image")
    #Constant("error_tip")
}

// print("Constanints: \(Constaints.errorTip)")

// MARK: - PeerMacro

@AddCompletionHandler
func fetchData() async -> String {
    return "Hello world!"
}

// MARK: - Accessor

class Person1 {
    var dictionary: [String: Any]
    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
    }
    
    @DictionaryStorageProperty
    var name: String
    @DictionaryStorageProperty
    var age: Int
}

var person1 = Person1(dictionary: [:])
//print("person: \(person1.dictionary)")
person1.age = 42
//print("person: \(person1.dictionary)")

// MARK: - Member Attribute

class ViewController {}

@ObjCMembers
extension ViewController {
    func clickedDoneButton() {}
    func clickedPreviousButton() {}
    func clickedNextButton() {}
}

// MARK: - MemberMacro

@CustomCodable
struct CustomCodableString: Decodable {
    @CodableKey(name: "OtherName")
    var propertyWithOtherName: String
    var propertyWithSameName: Bool
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        propertyWithOtherName = try container.decode(String.self, forKey: .propertyWithOtherName)
        propertyWithSameName = try container.decode(Bool.self, forKey: .propertyWithSameName)
    }
}

let json: [String: Any] = [
    "OtherName": "1",
    "propertyWithSameName": true,
]
let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
let data = try JSONDecoder().decode(CustomCodableString.self, from: jsonData)
// print(data)

// MARK: - Extension

@equatable
enum TestEqutable {
    case test1(String)
    case test2
}

let test1: TestEqutable = TestEqutable.test1("")
let test2: TestEqutable = TestEqutable.test2

if test1 == test2 {}

// MARK: - Member, Extension

// @CustomCodable
// struct CustomCodableString2 {
//    @CodableKey(name: "OtherName")
//    var propertyWithOtherName: String
//    var propertyWithSameName: Bool
//
//    init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        propertyWithOtherName = try container.decode(String.self, forKey: .propertyWithOtherName)
//        propertyWithSameName = try container.decode(Bool.self, forKey: .propertyWithSameName)
//    }
// }
//
// let json2: [String: Any] = [
//    "OtherName": "1",
//    "propertyWithSameName": true,
// ]
// let jsonData2 = try JSONSerialization.data(withJSONObject: json2, options: [])
// let data2 = try JSONDecoder().decode(CustomCodableString2.self, from: jsonData2)
// print(data2)

// MARK: - Accessor, MemberAttribute, Member

//@DictionaryStorage
//class Person2 {
//    var name: String
//    var age: Int
//}
//
//var person2 = Person2()
//print("person: \(person2.dictionary)")
//person2.age = 42
//print("person: \(person2.dictionary)")


// MARK: - Property Wrapper

//@propertyWrapper
//struct DictionaryBacked<Value> {
//    private let key: String
//    private var storage: [String: Any]
//    
//    init(key: String, storage: [String: Any]) {
//        self.key = key
//        self.storage = storage
//    }
//    
//    var wrappedValue: Value {
//        get {
//            guard let value = storage[key] as? Value else {
//                fatalError("Value for key '\(key)' is not of type \(Value.self) or is missing")
//            }
//            return value
//        }
//        set {
//            storage[key] = newValue
//        }
//    }
//}
//
//@MainActor
//class TestSingle {
//    static let shared = TestSingle()
//    var dictionary: [String: Any] = [:]
//}
//private var dictionary: [String: Any] = [:]
//
//@MainActor
//class DictionaryPropertyWrapper {
//    @DictionaryBacked(key: "name", storage: TestSingle.shared.dictionary)
//    static var name: String
//    
//    @DictionaryBacked(key: "age", storage: dictionary)
//    static var age: Int
//}
//
//DictionaryPropertyWrapper.name = "John"
//DictionaryPropertyWrapper.age = 42
//print("TestSingle.shared.dictionary: \(TestSingle.shared.dictionary)")
//print("dictionary: \(dictionary)")
