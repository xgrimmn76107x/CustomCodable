import CustomCodable
import Foundation

// MARK: - ExpressionMacro

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")

// MARK: - DeclarationMacro

#FuncUnique

func runFuncUniqueMacroPlayground() {
    print("My Class Declaration with unique method: ", MyClass())
}

runFuncUniqueMacroPlayground()

enum TestClass {
    #declareStaticValue(1)
    
    static func test() {
        print("Const.value: \(Const.value)")
    }
}

TestClass.test()

// MARK: - PeerMacro

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
