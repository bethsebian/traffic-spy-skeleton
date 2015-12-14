require_relative '../test_helper'

class UserViewsSingleEventStatsTest < FeatureTest
  def create_application(a)
    Application.create(identifier: a, root_url: "http://#{a}.com")
  end

  def create_requests(app_id, timestamp, event_id, num)
    (1..num).to_a.each do |n|
      Request.create(request_data(app_id, timestamp, event_id, n))
      Event.create(name: "socialLogin_#{event_id}")
      Url.create(path: "blog_#{1}")
    end
  end

  def request_data(app_id, timestamp, event_id, n)
    { :request_hash => "#{Random.new_seed}",
      :application_id => app_id,
      :url_id => 1,
      :timestamp => "2013-02-16 #{timestamp}:38:28 -0700",
      :response_time => 30,
      :referral => 'http://jumpstartlab.com',
      :verb => 'GET',
      :event_id => event_id,
      :browser => "Chrome 24.0.1309",
      :os => "Mac OS X 10.8.2",
      :resolution => "1920x128#{event_id}"
      }
  end

  def test_user_sees_total_requests_for_given_event
    create_application('jumpstartlab')
    create_requests(1, 12, 1, 5)
    create_requests(1, 8, 1, 3)
    create_requests(1, 4, 2, 3)
    create_requests(1, 7, 1, 3)

    visit '/sources/jumpstartlab/events/socialLogin_1'

    assert page.has_content? 'Requests Stats for socialLogin_1'
    assert page.has_content? 'Total Requests'

    within("#total_requests") do
      assert page.has_content?('11')
      refute page.has_content?('8')
      refute page.has_content?('14')
    end
  end

  def test_user_sees_requests_by_hour
    create_application('jumpstartlab')
    create_requests(1, 12, 1, 5)
    create_requests(1, 8, 1, 3)
    create_requests(1, 4, 2, 3)
    create_requests(1, 7, 1, 3)

    visit '/sources/jumpstartlab/events/socialLogin_1'

    assert page.has_content? 'Requests by Hour'

    within("#requests_by_hour") do
      assert page.has_content?("9 o'clock: 5")
      assert page.has_content?("5 o'clock: 3")
      assert page.has_content?("4 o'clock: 3")
      refute page.has_content?("4 o'clock: 6")
      refute page.has_content?("10 o'clock: 4")
      assert page.has_content?("10 o'clock: 0")
    end
  end

  def test_user_is_given_error_page_with_link_to_events_if_event_unknown
    create_application('jumpstartlab')
    create_requests(1, 12, 1, 5)

    visit '/sources/jumpstartlab/events/socialLogin_2'

    assert page.has_content? 'Error: Event not defined'
    assert page.has_link?('View Jumpstartlab Events', :href => '/sources/jumpstartlab/events')
  end
end