require 'spec_helper'

describe UserPermissionB do
  it "provides permission values for combinations of permissions" do
    data = { [:browse] => 1,
             [:analyse] => 3,
             [:download] => 2,
             [:analyse, :download] => 6 }

    data.each_pair do |permissions, result|
      UserPermissionB.permission_value(permissions).should == result
    end
  end
end
