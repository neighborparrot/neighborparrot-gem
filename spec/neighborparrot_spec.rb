require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Neighborparrot" do
  it "should send post request with valid parameters" do
    expec_params = { :channel => 'test', :data => 'test string' }
    url =  URI.parse('http://localhost:9000/post')
    Net::HTTP.should_receive(:post_form).with(url, expec_params)
    Neighborparrot.post(expec_params[:channel], expec_params[:data])
  end
end
