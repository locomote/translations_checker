require "spec_helper"

require "translations_checker/delegation"

RSpec.describe TranslationsChecker::Delegation do
  describe ".delegate" do
    context "for a delegated method without parameters" do
      Delegator = Struct.new(:delegatee) do
        include TranslationsChecker::Delegation

        delegate :a_method, to: :delegatee
      end

      it "delegates the method to the delegatee", :aggregate_failures do
        delegatee = double :delegatee
        expected_result = double :expected_result
        delegator = Delegator.new(delegatee)

        expect(delegatee).to receive(:a_method).with(no_args).and_return(expected_result)
        expect(delegator.a_method).to be expected_result
      end
    end

    context "for a delegated method with parameters" do
      Delegator = Struct.new(:delegatee) do
        include TranslationsChecker::Delegation

        delegate :a_method, to: :delegatee
      end

      it "delegates the method to the delegatee", :aggregate_failures do
        delegatee = double :delegatee
        expected_result = double :expected_result
        delegator = Delegator.new(delegatee)

        expect(delegatee).to receive(:a_method).with("some value", a: 1, b: 2).and_return(expected_result)
        expect(delegator.a_method("some value", a: 1, b: 2)).to be expected_result
      end
    end

    context "given mutiple methods" do
      Delegator = Struct.new(:delegatee) do
        include TranslationsChecker::Delegation

        delegate :a_method, :b_method, to: :delegatee
      end

      it "delegates all methods to the delegatee", :aggregate_failures do
        delegatee = double :delegatee
        expected_results = {
          a_method: double(:expected_a_method_result),
          b_method: double(:expected_b_method_result)
        }
        delegator = Delegator.new(delegatee)

        expected_results.each do |method, expected_result|
          expect(delegatee).to receive(method).with(no_args).and_return(expected_result)
          expect(delegator.send(method)).to be expected_result
        end
      end
    end
  end
end
