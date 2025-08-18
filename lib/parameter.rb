# frozen_string_literal: true

# パラメータ情報を表すクラス
class Parameter
  attr_reader :name, :type, :kind

  def initialize(name:, type:, kind:)
    @name = name
    @type = type
    @kind = kind
  end

  # ハッシュから Parameter オブジェクトを作成
  def self.from_hash(hash)
    new(
      name: hash[:name],
      type: hash[:type],
      kind: hash[:kind]
    )
  end
  # rubocop:enable Style/ClassMethodsDefinitions

  # Parameter オブジェクトをハッシュに変換
  def to_hash
    {
      name: @name,
      type: @type,
      kind: @kind
    }
  end
end
