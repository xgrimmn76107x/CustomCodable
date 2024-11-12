import CustomCodable
import Foundation

// MARK: - ExpressionMacro

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")

// MARK: - DeclarationMacro

enum TestClass {
    #declareStaticValue(1)
    
    static func test() {
        print("Const.value: \(Const.value)")
    }
}

TestClass.test()

@MainActor
public enum Constaints {
    #Constant("app_icon")
    #Constant("empty_image")
    #Constant("error_tip")
}

print("Constanints: \(Constaints.errorTip)")

// MARK: - PeerMacro

@AddCompletionHandler
func fetchData() async -> String {
    return "Hello world!"
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
print(data)

// MARK: - Member Attribute

@memberDeprecated
struct SomeStruct {
    var oldProperty: Int = 420
    func oldMethod() {
        print("This is an old method.")
    }
}

let someStruct = SomeStruct()
_ = someStruct.oldProperty
someStruct.oldMethod()

// MARK: - Accessor

struct CustomData {
    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    var dictionary: [String: Any]
    @DictionaryStorageProperty
    var age: Int
}

// MARK: - Extension
