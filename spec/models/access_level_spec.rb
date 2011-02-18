require 'spec_helper'

describe AccessLevel do
  it "produces a dataset description" do
    # For datasets
    a = AccessLevel.make(:datasetID => "abc.def.ghi.jkl.12345", :datasetname => "This is the dataset name", :fileContent => nil)
    a.dataset_description.should == "12345 - This is the dataset name"

    # For files
    a = AccessLevel.make(:datasetID => "mno.pqr.stu.vwx.67890", :datasetname => "This is the dataset name", :fileContent => "This is the file content")
    a.dataset_description.should == "67890 - This is the file content"
  end
end
