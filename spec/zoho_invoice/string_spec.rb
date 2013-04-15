require 'spec_helper'

describe String do

  it "should make a snake case string into camel case" do
    expect("something_else".camelcase).to eq("SomethingElse")
  end

  it "should make a single word camelcase" do
    expect("something".camelcase).to eq("Something")
  end

  it "should handle a string thats already camelcase" do
    expect("Something".camelcase).to eq("Something")
    expect("SomethingElse".camelcase).to eq("SomethingElse")
  end

  it "should convert a class name to underscore" do
    expect(String.to_s.to_underscore).to eq('string')
  end

  it "should convert a string to underscore not creating copy" do
    str = "SomethingElse"
    id  = str.object_id
    rst = str.to_underscore!
    expect(rst).to eq("something_else")
    expect(id).to eq(rst.object_id)
  end

end
