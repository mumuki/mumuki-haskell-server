require_relative 'spec_helper'

describe HaskellExpectationsHook do
  def req(expectations, content)
    OpenStruct.new(expectations: expectations, content: content)
  end

  def compile_and_run(request)
    runner.run!(runner.compile(request))
  end

  let(:runner) { HaskellExpectationsHook.new(mulang_path: './bin/mulang') }
  let(:result) { compile_and_run(req(expectations, code)) }

  context 'smells' do
    let(:code) { 'f\' = \x -> f x' }
    let(:expectations) do
      [{binding: 'foo', inspection: 'HasBinding'}]
    end

    it { expect(result).to eq [
         {expectation: {inspection: 'Declares:=foo', binding: ''}, result: false},
         {expectation: {inspection: 'HasRedundantParameter', binding: "f'"}, result: false},
         {expectation: {inspection: 'HasTooShortBindings', binding: "f'"}, result: false},
         {expectation: {inspection: 'HasWrongCaseBindings', binding: "f'"}, result: false}] }
  end

  context 'v0 expectations' do
    let(:code) { 'foo = 1' }
    let(:expectations) do
      [{binding: 'foo', inspection: 'HasBinding'}]
    end

    it { expect(result).to eq([{expectation: {inspection: "Declares:=foo", binding: ''}, result: true}]) }
  end

  context 'v2 expectations' do
    let(:code) { 'foo = m 3' }
    let(:expectations) do
      [{binding: 'foo', inspection: 'Uses:m'},
       {binding: '',    inspection: 'DeclaresFunction:foo'}]
    end

    it { expect(result).to eq([{expectation: expectations[0], result: true},
                               {expectation: expectations[1], result: true}]) }
  end

  context 'multiple v0 expectations' do
    let(:code) { 'bar = 1' }
    let(:expectations) do
      [{binding: 'foo', inspection: 'Not:HasBinding'}, {binding: 'foo', inspection: 'HasUsage:bar'}]
    end

    it { expect(result).to eq([{expectation: {binding: '', inspection: 'Not:Declares:=foo'}, result: true},
                               {expectation: {binding: 'foo', inspection: 'Uses:=bar' }, result: false}]) }
  end
end

