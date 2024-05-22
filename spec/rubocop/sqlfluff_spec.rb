# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Sqlfluff do
  it "has a version number" do
    expect(RuboCop::Sqlfluff::VERSION).not_to be nil
  end
end
