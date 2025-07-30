# 包括的なRBS解析機能

## インプットするファイル
ほぼすべてのパターンのメソッド定義を含むRBSファイル

```rbs
class ComprehensiveClass
  # インスタンスメソッド - 引数なし
  def simple_method: () -> String
  
  # インスタンスメソッド - 位置引数
  def method_with_args: (String name, Integer age) -> String
  
  # インスタンスメソッド - オプション引数
  def method_with_optional: (String name, ?Integer age) -> String
  
  # インスタンスメソッド - キーワード引数
  def method_with_keywords: (name: String, age: Integer) -> String
  
  # インスタンスメソッド - オプションキーワード引数
  def method_with_optional_keywords: (name: String, ?age: Integer) -> String
  
  # インスタンスメソッド - ブロック引数
  def method_with_block: () { (String) -> void } -> Array[String]
  
  # インスタンスメソッド - 可変長引数
  def method_with_splat: (*String args) -> Array[String]
  
  # インスタンスメソッド - 複合引数
  def complex_method: (String name, ?Integer age, *String tags, **String options) { (String) -> void } -> Hash[String, untyped]
  
  # クラスメソッド
  def self.class_method: (String param) -> ComprehensiveClass
  
  # オーバーロードメソッド
  def overloaded_method: (String) -> String
                       | (Integer) -> Integer
                       | () -> nil
  
  # Union型戻り値
  def union_return: () -> (String | Integer | nil)
  
  # Generic型戻り値
  def generic_return: [T] (T value) -> Array[T]
  
  # void戻り値
  def void_method: (String message) -> void
  
  private
  
  # プライベートメソッド
  def private_method: () -> String
  
  protected
  
  # プロテクトメソッド
  def protected_method: () -> String
end
```

## 出力するファイル形式
包括的なメソッド情報を含むJSON形式

```json
{
  "file_path": "spec/fixtures/comprehensive_class.rbs",
  "structure": [
    {
      "type": "class",
      "name": "ComprehensiveClass",
      "superclass": null,
      "methods": [
        {
          "name": "simple_method",
          "method_type": "instance",
          "visibility": "public",
          "parameters": [],
          "return_type": "String",
          "overloads": []
        },
        {
          "name": "method_with_args",
          "method_type": "instance", 
          "visibility": "public",
          "parameters": [
            {
              "name": "name",
              "type": "String",
              "kind": "required_positional"
            },
            {
              "name": "age",
              "type": "Integer", 
              "kind": "required_positional"
            }
          ],
          "return_type": "String",
          "overloads": []
        },
        {
          "name": "method_with_optional",
          "method_type": "instance",
          "visibility": "public", 
          "parameters": [
            {
              "name": "name",
              "type": "String",
              "kind": "required_positional"
            },
            {
              "name": "age",
              "type": "Integer",
              "kind": "optional_positional"
            }
          ],
          "return_type": "String",
          "overloads": []
        },
        {
          "name": "method_with_keywords",
          "method_type": "instance",
          "visibility": "public",
          "parameters": [
            {
              "name": "name",
              "type": "String", 
              "kind": "required_keyword"
            },
            {
              "name": "age",
              "type": "Integer",
              "kind": "required_keyword"
            }
          ],
          "return_type": "String",
          "overloads": []
        },
        {
          "name": "method_with_optional_keywords",
          "method_type": "instance",
          "visibility": "public",
          "parameters": [
            {
              "name": "name",
              "type": "String", 
              "kind": "required_keyword"
            },
            {
              "name": "age",
              "type": "Integer",
              "kind": "optional_keyword"
            }
          ],
          "return_type": "String",
          "overloads": []
        },
        {
          "name": "method_with_block",
          "method_type": "instance",
          "visibility": "public",
          "parameters": [],
          "block": {
            "parameters": [
              {
                "type": "String"
              }
            ],
            "return_type": "void"
          },
          "return_type": "Array[String]",
          "overloads": []
        },
        {
          "name": "method_with_splat",
          "method_type": "instance",
          "visibility": "public",
          "parameters": [
            {
              "name": "args",
              "type": "String",
              "kind": "rest_positional"
            }
          ],
          "return_type": "Array[String]",
          "overloads": []
        },
        {
          "name": "complex_method",
          "method_type": "instance",
          "visibility": "public",
          "parameters": [
            {
              "name": "name",
              "type": "String",
              "kind": "required_positional"
            },
            {
              "name": "age",
              "type": "Integer",
              "kind": "optional_positional"
            },
            {
              "name": "tags",
              "type": "String",
              "kind": "rest_positional"
            },
            {
              "name": "options",
              "type": "String",
              "kind": "rest_keyword"
            }
          ],
          "block": {
            "parameters": [
              {
                "type": "String"
              }
            ],
            "return_type": "void"
          },
          "return_type": "Hash[String, untyped]",
          "overloads": []
        },
        {
          "name": "overloaded_method", 
          "method_type": "instance",
          "visibility": "public",
          "parameters": [],
          "return_type": null,
          "overloads": [
            {
              "parameters": [
                {
                  "type": "String",
                  "kind": "required_positional"
                }
              ],
              "return_type": "String"
            },
            {
              "parameters": [
                {
                  "type": "Integer", 
                  "kind": "required_positional"
                }
              ],
              "return_type": "Integer"
            },
            {
              "parameters": [],
              "return_type": "nil"
            }
          ]
        },
        {
          "name": "union_return",
          "method_type": "instance",
          "visibility": "public",
          "parameters": [],
          "return_type": "(String | Integer | nil)",
          "overloads": []
        },
        {
          "name": "generic_return",
          "method_type": "instance",
          "visibility": "public",
          "parameters": [
            {
              "name": "value",
              "type": "T",
              "kind": "required_positional"
            }
          ],
          "return_type": "Array[T]",
          "type_parameters": ["T"],
          "overloads": []
        },
        {
          "name": "void_method",
          "method_type": "instance",
          "visibility": "public",
          "parameters": [
            {
              "name": "message",
              "type": "String",
              "kind": "required_positional"
            }
          ],
          "return_type": "void",
          "overloads": []
        },
        {
          "name": "class_method",
          "method_type": "class",
          "visibility": "public",
          "parameters": [
            {
              "name": "param",
              "type": "String",
              "kind": "required_positional"
            }
          ],
          "return_type": "ComprehensiveClass",
          "overloads": []
        },
        {
          "name": "private_method",
          "method_type": "instance",
          "visibility": "private", 
          "parameters": [],
          "return_type": "String",
          "overloads": []
        },
        {
          "name": "protected_method",
          "method_type": "instance",
          "visibility": "protected",
          "parameters": [],
          "return_type": "String", 
          "overloads": []
        }
      ],
      "includes": [],
      "extends": []
    }
  ]
}
```
