# 実装ガイドライン

## 🔧 基本的なRubyコーディング規約

### インスタンス変数の扱い
**必ず attr_reader を使用し、直接アクセスは禁止**

```ruby
# ✅ 良い例
class RBSParser
  private attr_reader :file_path, :content
  
  def initialize(file_path)
    @file_path = file_path
    @content = nil
  end
  
  def parse
    load_content
    analyze_syntax
  end
  
  private
  
  def load_content
    @content = File.read(file_path)  # 初期化時のみ直接代入
  end
  
  def analyze_syntax
    return unless content  # attr_reader経由でアクセス
    # 解析処理
  end
end

# ❌ 悪い例
class RBSParser
  def initialize(file_path)
    @file_path = file_path
  end
  
  def parse
    content = File.read(@file_path)  # 直接アクセス（NG）
  end
end
```

**理由**: コードの一貫性が保たれ、将来的な変更に対応しやすくなる

### メソッド引数の指定方法
**引数の数に応じて使い分ける**

```ruby
# ✅ 良い例：引数が2つ以下
class DiagramFormatter
  def format(data, output_type)
    # 処理
  end
end

# ✅ 良い例：引数が3つ以上
class RBSAnalyzer
  def analyze(file_path:, include_private:, output_format:)
    # 処理
  end
end

# ❌ 悪い例：1つの引数でキーワード引数
def bad_method(name:)  # 不要
  # 処理
end
```

## 📁 ディレクトリ構成とクラス設計

### 禁止されるディレクトリ名
**曖昧な名前は使わない**

```ruby
# ❌ 避けるべきディレクトリ名
app/
├── services/     # 曖昧
├── helpers/      # 何でも入れがち
└── utils/        # 責務不明確

# ✅ 推奨されるディレクトリ名
app/
├── parsers/      # RBS解析専用
├── formatters/   # 図生成専用
└── validators/   # バリデーション専用
```

**効果**: 
- クラスの役割が明確になる
- コードが探しやすくなる
- 新しいコードの配置場所が判断しやすくなる

### ファンクショナルクラスの実装
**executeメソッドを使用する**

```ruby
# ✅ 良い例：RBS to Diagram プロジェクト用
class RBSParseCommand
  def self.execute(file_path)
    new(file_path).execute
  end
  
  private_class_method :new
  
  def initialize(file_path)
    @file_path = file_path
  end
  
  def execute
    # 解析処理
    RBSParserResult.new(definitions, dependencies)
  end
  
  private
  
  attr_reader :file_path
end

# ❌ 悪い例：callメソッド
class RBSParseCommand
  def call  # executeの方が意図が明確
    # 処理
  end
end
```

**理由**: Commandパターンの意図がより明確に表現される

## 🚫 禁止事項

### require_relative は使わない
```ruby
# ❌ 悪い例
require_relative '../parsers/rbs_parser'

# ✅ 良い例
# Railsのオートロードに任せる（何も書かない）
class DiagramController
  def generate
    parser = RBSParser.new  # オートロードで解決
  end
end
```

**理由**: Railsのオートロード機能を最大限活用するため