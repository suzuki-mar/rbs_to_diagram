
# RBS運用ガイド

## 🔥 最重要ルール（Kiroが必ず守ること）

### 1. 型定義優先読解
**コードを理解する時は、必ずRBSファイルを最初に読む**

```ruby
# ❌ 悪い例：いきなり実装コードを読む
def some_method
  # 実装を見て推測...
end

# ✅ 良い例：まずRBSで型定義を確認
# sig/example.rbs
class Example
  def some_method: (String name, Integer age) -> User
end
```

**理由**: RBSは設計書として機能し、実装の意図やインターフェースが明確に分かる

### 2. 実装変更時の型定義メンテナンス
**実装を変更したら、必ずRBSも同時に更新する**

```ruby
# 実装を変更した場合
def create_user(name, age, email)  # emailを追加
  # 実装
end

# RBSも必ず更新
def create_user: (String name, Integer age, String email) -> User
```

**理由**: RBSと実装の同期が崩れると、設計書として機能しなくなる

### 3. untypedの制限
**理由なくuntypedを使わない**

```ruby
# ❌ 悪い例：理由なくuntyped
def process: (untyped data) -> untyped

# ✅ 良い例：具体的な型を定義
def process: (Hash[String, String] data) -> Array[User]

# ✅ 例外：ActiveRecordなど動的な部分のみ許可
def find_by_conditions: (untyped conditions) -> untyped
```

## 📝 実装時のルール

### public/private分離の書き方
```ruby
# RBSファイルの構成
class UserService
  # publicメソッドを上部にまとめる
  def create_user: (String name) -> User
  def find_user: (Integer id) -> User?

  private
  # privateメソッドを下部にまとめる
  def validate_name: (String name) -> bool
  def generate_id: () -> Integer
end
```

**理由**: 外部インターフェースと内部実装が明確に分離され、可読性が向上する