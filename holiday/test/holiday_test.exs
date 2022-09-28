defmodule HolidayTest do
  use ExUnit.Case
  doctest Holiday

  test "db initialized successfully" do
    assert Holiday.init_db().events != []
  end

  def fake_db do
    %ICalendar{
      events: [
        %ICalendar.Event{
          summary: "Christmas",
          dtstart: ~U[1970-12-25 00:00:00Z],
          dtend: ~U[1970-12-26 00:00:00Z],
          rrule: %{freq: "YEARLY"},
          exdates: [],
          description: nil,
          location: nil,
          url: nil,
          uid: "c1679873-ff26-4f96-a628-01e89a2049fb",
          prodid: nil,
          status: "confirmed",
          categories: nil,
          class: "public",
          comment: nil,
          geo: nil,
          modified: ~U[2020-04-25 15:38:22Z],
          organizer: nil,
          sequence: "0",
          attendees: []
        }
      ]
    }
  end

  test "no events, no holidays" do
    {:ok, fake_date} = Date.new(2023, 1, 1)
    assert Holiday.is_holiday(%ICalendar{events: []}, fake_date) == false
  end

  test "is it holiday when it's really not?" do
    {:ok, fake_date} = Date.new(2022, 9, 27)
    assert Holiday.is_holiday(fake_db(), fake_date) == false
  end

  test "is it holiday when it's Christmas tho?" do
    {:ok, fake_date} = Date.new(2022, 12, 25)
    assert Holiday.is_holiday(fake_db(), fake_date) == true
  end

  test "12 days of crisis or whatever" do
    {:ok, fake_date_time} = DateTime.new(~D[2022-12-13], ~T[00:00:00.000])
    assert Holiday.time_until_holiday(fake_db(), :day, fake_date_time) == 12
  end

  test "no events, so empty_error" do
    assert Holiday.time_until_holiday(%ICalendar{events: []}, :day) == Enum.EmptyError
  end
end
