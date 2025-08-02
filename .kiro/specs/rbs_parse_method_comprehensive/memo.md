# 実装メモ - RBS Parse Comprehensive

## 概要
既存の`rbs_parse_single`機能を拡張して、ほぼすべてのパターンのメソッド定義をパースできるようにする機能です。

## 現在の状況
- 既存の`lib/rbs_parser/signature_analyzer.rb`は単純なメソッド定義のみ対応
- 既存の`lib/formatter/json.rb`は基本的なJSON出力のみ対応
- テストファイルは`spec/fixtures/target_simple_class.rbs`のような単純なクラスのみ

## 必要な変更点

### 1. RBSSignatureAnalyzer の拡張
**ファイル**: `lib/rbs_parser/signature_analyzer.rb`

**現在の制限**:
- 引数なしメソッドまたは単純な引数のみ対応
- メソッドの可視性（private/protected）を考慮していない
- クラスメソッドとインスタンスメソッドの区別なし
- オーバーロードメソッドに未対応

**必要な拡張**:
- 複雑な引数パターンの解析（オプション引数、キーワード引数、ブロック引数、可変長引数）
- メソッドの可視性判定ロジック
- クラスメソッド（`self.method`）の識別
- オーバーロードメソッドの処理
- 引数の種類分類（required/optional/keyword/splat/double_splat）

### 2. JSON出力形式の拡張
**ファイル**: `lib/formatter/json.rb`

**現在の出力**:
```json
{
  "name": "method_name",
  "visibility": "public",
  "parameters": [],
  "return_type": "String"
}
```

**拡張後の出力**:
```json
{
  "name": "method_name",
  "method_type": "instance|class",
  "visibility": "public|private|protected",
  "parameters": [
    {
      "name": "param_name",
      "type": "String",
      "kind": "required|optional|keyword|splat|double_splat"
    }
  ],
  "block": {
    "parameters": [...],
    "return_type": "void"
  },
  "return_type": "String",
  "overloads": [...]
}
```

### 3. テストファイルの追加
**新規ファイル**: `spec/fixtures/comprehensive_class.rbs`

spec.mdで定義したComprehensiveClassを含むRBSファイルを作成する必要があります。

### 4. 既存コードへの影響
**注意点**:
- 既存の`rbs_parse_single`機能との互換性を保つ
- `lib/rbs_parser/result.rb`の構造変更が必要な可能性
- 既存のテストが壊れないように注意

### 5. テスト戦略
**パース機能の単体テスト**: `spec/rbs_parser/parse_spec.rb`

パース機能とJSON出力機能を分離してテストするため、パース側単体のテストファイルを作成する必要があります。

**テストの構成**:
```ruby
# spec/rbs_parser/parse_spec.rb
describe RBSParser::SignatureAnalyzer do
  describe '#analyze' do
    context 'when parsing comprehensive class' do
      it 'extracts method with various parameter types' do
        # パース結果をRubyオブジェクトとして検証
        result = analyzer.analyze(rbs_content)
        expect(result.classes.first.methods).to include(
          have_attributes(
            name: 'method_with_args',
            method_type: 'instance',
            visibility: 'public',
            parameters: contain_exactly(
              have_attributes(name: 'name', type: 'String', kind: 'required'),
              have_attributes(name: 'age', type: 'Integer', kind: 'required')
            )
          )
        )
      end
    end
  end
end
```

### 6. 実装の優先順位
1. テストファイル（comprehensive_class.rbs）の作成
2. パース機能の単体テスト（parse_spec.rb）の作成
3. RBSSignatureAnalyzerの引数解析機能拡張
4. メソッド可視性の判定機能追加
5. クラスメソッドの識別機能追加
6. オーバーロードメソッドの処理機能追加
7. JSON出力形式の拡張
8. 統合テストの更新

## 技術的な課題
- RBS::Parserの詳細なAPIを理解する必要がある
- メソッドの可視性は前の`private`/`protected`宣言から判定する必要がある
- オーバーロードメソッドは複数の定義を一つのメソッドとしてグループ化する必要がある

## 参考情報
- 既存の実装: `lib/rbs_parser/signature_analyzer.rb`
- RBS公式ドキュメント: https://github.com/ruby/rbs
- 既存のテスト: `spec/integration_spec.rb`