require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get download" do
    get transactions_download_url
    assert_response :success
  end
end
