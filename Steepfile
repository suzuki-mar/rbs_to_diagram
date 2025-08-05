# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  signature 'sig'

  check 'lib'

  library 'pathname'
  library 'rbs'

  configure_code_diagnostics(D::Ruby.strict)
end

target :spec_support do
  signature 'sig'

  check 'spec/support'

  library 'pathname'
  library 'rbs'

  configure_code_diagnostics(D::Ruby.strict)
end
