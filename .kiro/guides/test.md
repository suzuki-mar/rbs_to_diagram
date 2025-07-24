# テストガイドライン

## 🧪 基本原則（Kiroが必ず守ること）

### 1. テストファースト開発
**実装前にテストを書く**

```ruby
# ✅ 良い例：まずテストを書く
RSpec.describe RBSParser do
  describe '#parse_file' do
    it 'RBSファイルを正しく解析できること' do
      parser = RBSParser.new
      file_path = 'spec/fixtures/sample.rbs'
      
      result = parser.parse_file(file_path)
      
      expect(result).to be_a(RBSParserResult)
      expect(result.definitions).not_to be_empty
    end
  end
end

# その後で実装を書く
class RBSParser
  def parse_file(file_path)
    # 実装
  end
end
```

**理由**: 設計の透明性とバグの早期発見、要件の明確化に役立つ

### 2. モックを使わない
**本物のオブジェクト同士で動作するテストを書く**

```ruby
# ✅ 良い例：本物のオブジェクトを使用
RSpec.describe DiagramFormatter do
  it 'RBSParserResultからMermaid図を生成できること' do
    # 本物のRBSParserResultを作成
    definitions = [ClassDefinition.new('User', ['name', 'age'])]
    parser_result = RBSParserResult.new(definitions)
    formatter = DiagramFormatter.new
    
    diagram = formatter.format(parser_result)
    
    expect(diagram).to include('classDiagram')
    expect(diagram).to include('User')
  end
end

# ❌ 悪い例：モックを使用
RSpec.describe DiagramFormatter do
  it 'RBSParserResultからMermaid図を生成できること' do
    mock_result = double('RBSParserResult')
    allow(mock_result).to receive(:definitions).and_return([])  # 偽の値
    # テストが実際の動作と乖離する可能性
  end
end
```

**理由**: テストの信頼性向上と、疎結合でシンプルなAPI設計の促進

### 3. 小さなステップで進める
**一度に大きな変更をしない**

```ruby
# ✅ 良い例：段階的なテスト
RSpec.describe RBSParser do
  # ステップ1: 基本的な解析
  it 'クラス定義を解析できること' do
    # 基本機能のテスト
  end
  
  # ステップ2: モジュール対応
  it 'モジュール定義を解析できること' do
    # 機能拡張のテスト
  end
  
  # ステップ3: 継承関係対応
  it '継承関係を解析できること' do
    # さらなる機能拡張のテスト
  end
end
```

## 📝 テストの書き方

### テスト構造
**Arrange → Act → Assert の順で書く**

```ruby
RSpec.describe ClassDefinition do
  it 'メソッド一覧を取得できること' do
    # Arrange（準備）
    methods = ['initialize', 'name', 'age']
    definition = ClassDefinition.new('User', methods)
    
    # Act（実行）
    result = definition.method_list
    
    # Assert（検証）
    expect(result).to eq(methods)
  end
end
```

### 命名規則
**日本語で明示的に書く**

```ruby
# ✅ 良い例：意図が明確
describe '#parse_file' do
  context 'RBSファイルが存在する場合' do
    it 'クラス定義を正しく解析できること' do
      # テスト内容
    end
    
    it 'モジュール定義を正しく解析できること' do
      # テスト内容
    end
  end
  
  context 'RBSファイルが存在しない場合' do
    it 'エラーを発生させること' do
      # テスト内容
    end
  end
end

# ❌ 悪い例：意図が不明確
describe '#parse_file' do
  it 'works' do
    # 何をテストしているか不明
  end
end
```

## 🔧 RSpecの使い方

### subject の使い方
**テストの対象を明確にする**

```ruby
# ✅ 良い例：名前をつけない
RSpec.describe RBSParseCommand do
  subject { RBSParseCommand.execute(file_path) }
  
  let!(:file_path) { 'spec/fixtures/sample.rbs' }
  
  it 'RBSParserResultを返すこと' do
    expect(subject).to be_a(RBSParserResult)
  end
end

# ❌ 悪い例：名前をつける（複数のsubjectが生まれる可能性）
RSpec.describe RBSParseCommand do
  subject(:result) { RBSParseCommand.execute(file_path) }  # NG
end
```

### let の使い方
**繰り返し参照するもののみ使用し、let! で即時実行**

```ruby
# ✅ 良い例：必要最小限のlet!
RSpec.describe DiagramFormatter do
  let!(:definitions) do
    [
      ClassDefinition.new('User', ['name', 'age']),
      ClassDefinition.new('Post', ['title', 'content'])
    ]
  end
  
  let!(:parser_result) { RBSParserResult.new(definitions) }
  
  it 'Mermaid図を生成できること' do
    formatter = DiagramFormatter.new
    result = formatter.format(parser_result)
    expect(result).to include('classDiagram')
  end
end

# ❌ 悪い例：不要な分割
RSpec.describe DiagramFormatter do
  let(:user_definition) { ClassDefinition.new('User', ['name']) }
  let(:post_definition) { ClassDefinition.new('Post', ['title']) }
  let(:definitions) { [user_definition, post_definition] }
  let(:parser_result) { RBSParserResult.new(definitions) }
  # 複雑すぎて理解しにくい
end
```

## 📋 Kiroのテスト作業フロー

### テスト作成時
1. **要件を理解** - 何をテストすべきかを明確にする
2. **テストを先に書く** - 実装前にテストケースを作成
3. **最小限の実装** - テストが通る最小限のコードを書く
4. **リファクタリング** - テストが通る状態でコードを改善

### テスト実行時
- **編集したファイルに対応するspecのみ実行**
- 例：`app/parsers/rbs_parser.rb` を編集 → `spec/parsers/rbs_parser_spec.rb` を実行

### テストレビュー時
- [ ] テストの意図が明確か
- [ ] Arrange-Act-Assertの構造になっているか
- [ ] モックを使わずに本物のオブジェクトでテストしているか
- [ ] 1つのテストで1つの振る舞いのみ確認しているか