require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home page shows popular courses as links" do
    get root_path
    assert_response :success
    assert_select "a[href=?]", course_path(courses(:calculus)), text: courses(:calculus).title
  end
end
