import CustomCodable
import Foundation

let a = 17
let b = 25

let (result, code) = #stringify(a + b)

print("The value \(result) was produced by the code \"\(code)\"")

@CustomCodable
struct CustomCodableString: Codable {
    @CodableKey(name: "OtherName")
    var propertyWithOtherName: String
    var propertyWithSameName: Bool
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        print("CodingKeys: \(CodingKeys.propertyWithOtherName)")
        self.propertyWithOtherName = try container.decode(String.self, forKey: .propertyWithOtherName)
        self.propertyWithSameName = try container.decode(Bool.self, forKey: .propertyWithSameName)
    }
}

let json: [String: Any] = [
    "OtherName": "1",
    "propertyWithSameName": true
]
let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
let data = try JSONDecoder().decode(CustomCodableString.self, from: jsonData)
print(data)
