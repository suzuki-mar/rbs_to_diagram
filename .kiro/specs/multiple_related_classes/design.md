# Design Document

## Overview

既存のRBSToDiagramシステムを拡張し、複数のRBSファイルを処理してクラス間の関係性を含むMermaid.js形式のクラス図を出力する機能を実装します。単一ファイル処理の前提を取り除き、既存クラスを段階的に変更します。

## Architecture

### 既存アーキテクチャ
```
RBSToDiagram -> RBSParser -> SignatureAnalyzer -> Result -> Formatter::MermaidJS
```

### 変更後のアーキテクチャ
```
RBSToDiagram -> RBSParser -> SignatureAnalyzer -> Result -> Formatter::MermaidJS
(各クラスが複数ファイル対応に拡張)
```

## Components and Interfaces

### 1. RBSToDiagram (変更)

**変更内容**: 複数ファイル入力に対応

```ruby
class RBSToDiagram
  def self.execute(input_paths, output_file = nil)
    # input_paths: Array<String> | String (単一ファイル/ディレクトリ/複数ファイル)
  end
  
  private
  
  def collect_rbs_files(input_paths) -> Array<String>
end
```

### 2. RBSParser (変更)

**変更内容**: 複数ファイルの統合解析

```ruby
class RBSParser
  def self.parse(file_paths)
    # file_paths: Array<String>
    # 戻り値: Result (複数クラス定義を含む)
  end
  
  private
  
  def parse_multiple_files(file_paths) -> Hash
  def merge_definitions(parsed_files) -> Hash
end
```

### 3. Result (変更)

**変更内容**: 複数クラス定義と関係性情報の管理

```ruby
class Result
  def class_definitions -> Array<ClassNode>
  def find_relationships -> Hash
  
  private
  
  def analyze_inheritance_relationships -> Array<Hash>
  def analyze_delegation_relationships -> Array<Hash>
end
```

### 4. Formatter::MermaidJS (変更)

**変更内容**: 関係性矢印の出力追加

```ruby
class Formatter::MermaidJS
  def format(parser_result)
    # 複数クラス + 関係性矢印を含むMermaid.js出力
  end
  
  private
  
  def build_relationships(parser_result) -> Array<String>
end
```

## Data Models

### 関係性データ構造

```ruby
{
  inheritance: [
    { parent: "BaseEntity", child: "User" }
  ],
  delegation: [
    { delegator: "User", delegatee: "UserSettings" }
  ]
}
```