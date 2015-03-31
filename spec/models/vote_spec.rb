require 'rails_helper'

RSpec.describe Vote, type: :model do
  it { should validate_presence_of :title }
  it { should validate_presence_of :finish_at }
  it "should be valid?" do
    create(:vote).should be_valid
  end
end
