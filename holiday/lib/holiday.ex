defmodule Holiday do
  @moduledoc """
  Provides three functions
  - init_db/0 reads from file and creates a holiday database
  - is_holiday/2 reads from said database and checks if the given day is a holiday
  - time_until_holiday/3 returns the amount of time between a date and the closest holiday
  """

  @doc """
  Reads from a specific file and deserializes its data into Elixir-native structure

  """

  @spec init_db() :: %ICalendar{}
  def init_db() do
    # in this case calendar.ics contains US holidays
    {:ok, file} = File.read("./lib/db/calendar.ics")
    holidays = file |> ICalendar.from_ics()
    %ICalendar{events: holidays}
  end

  @doc """
  Calls the function time_until_holiday/3 and checks if there's 0 days left till closest holiday
  in other words, checks whether it's "today"

  ## Parameters

   - db: a holiday database. Usually provided by an init_db/0 function
   - day: by default takes today's date, but can be stated otherwise

  ## Examples

      iex> Holiday.is_holiday(%ICalendar{ events: [%ICalendar.Event{summary: "Christmas", dtstart: ~U[1970-12-25 00:00:00Z], dtend: ~U[1970-12-26 00:00:00Z], rrule: %{freq: "YEARLY"},
      ...> exdates: [], description: nil, location: nil, url: nil, uid: "c1679873-ff26-4f96-a628-01e89a2049fb", prodid: nil, status: "confirmed", categories: nil, class: "public",
      ...> comment: nil, geo: nil, modified: ~U[2020-04-25 15:38:22Z], organizer: nil, sequence: "0", attendees: []}]}, ~D[2022-12-25])
      true

  """
  @spec is_holiday(db :: %ICalendar{}, day :: %Date{}) :: boolean()
  def is_holiday(db, day \\ Date.utc_today()) do
    {:ok, dt} = DateTime.new(day, Time.utc_now())
    time_until_holiday(db, :day, dt) == 0
  end

  @doc """
  Returns days/hours/minutes/seconds between two days: one is given as a parameter, the other is determined as its closest holiday, according to holiday database

  ## Parameters

   - db: a holiday database. Usually provided by an init_db/0 function
   - unit: a specified metric of time that describes the difference between two dates
   - now: by default takes today's date-time, but can be stated otherwise

  ## Examples

      iex> Holiday.time_until_holiday(%ICalendar{ events: [%ICalendar.Event{summary: "Christmas", dtstart: ~U[1970-12-25 00:00:00Z], dtend: ~U[1970-12-26 00:00:00Z], rrule: %{freq: "YEARLY"},
      ...> exdates: [], description: nil, location: nil, url: nil, uid: "c1679873-ff26-4f96-a628-01e89a2049fb", prodid: nil, status: "confirmed", categories: nil, class: "public",
      ...> comment: nil, geo: nil, modified: ~U[2020-04-25 15:38:22Z], organizer: nil, sequence: "0", attendees: []}]}, :day, ~U[2022-12-22 00:00:00.00Z])
      3

  """
  @spec time_until_holiday(
          db :: %ICalendar{},
          unit :: :day | :hour | :minute | :second,
          now :: %DateTime{}
        ) :: integer
  def time_until_holiday(db, unit, now \\ DateTime.utc_now())

  def time_until_holiday(%ICalendar{events: []}, _, _) do
    Enum.EmptyError
  end

  def time_until_holiday(db, unit, now) do
    {:ok, next_year_date} = Date.new(now.year + 1, 1, 1) # a time constraint for the recurrence function

    closest_holiday =
      Enum.map(db.events, fn holiday ->
        ICalendar.Recurrence.get_recurrences(holiday, next_year_date)
        |> Enum.to_list()
      end)
      |> List.flatten()
      |> Enum.filter(fn holiday -> Date.diff(holiday.dtstart, now) >= 0 end)
      |> Enum.min_by(fn holiday -> holiday.dtstart end, Date)

    DateTime.diff(closest_holiday.dtstart, now, unit)
  end
end
