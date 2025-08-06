# ファイル形式

## パースするファイル
このスペックで扱うRBSファイルを扱う

```rbs
class SimpleClass
  def simple_method: () -> String
end
```

## 出力するファイル形式
このスペックで出力するファイル形式 
JSONか Mermaid.jsとか

``` json
{
  "file_path": "spec/fixtures/target_simple_class.rbs",
  "structure": [
    {
      "type": "class",
      "name": "SimpleClass",
      "superclass": null,
      "methods": [
        {
          "name": "simple_method",
          "visibility": "public",
          "parameters": [],
          "return_type": "String"
        }
      ],
      "includes": [],
      "extends": []
    }
  ]
}
```