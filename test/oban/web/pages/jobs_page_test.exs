defmodule Oban.Web.JobsPageTest do
  use Oban.Web.Case

  alias Oban.Web.JobsPage

  setup do
    oban = start_supervised_oban!()
    conf = Oban.config(oban)
    {:ok, conf: conf}
  end

  describe "states/2" do
    test "returns counts from Met when available", %{conf: conf} do
      insert_job!([ref: 1], state: "available")
      flush_reporter()

      states = JobsPage.states(conf)
      available = Enum.find(states, &(&1.name == "available"))
      assert available.count > 0
    end

    test "returns previous states when Met returns empty counts", %{conf: conf} do
      previous = [
        %{name: "executing", count: 3},
        %{name: "available", count: 7}
      ]

      # No flush_reporter, so Met has no data → returns previous
      assert JobsPage.states(conf, previous) == previous
    end

    test "returns fresh counts over previous when Met has data", %{conf: conf} do
      previous = [%{name: "available", count: 99}]

      insert_job!([ref: 1], state: "available")
      flush_reporter()

      states = JobsPage.states(conf, previous)
      available = Enum.find(states, &(&1.name == "available"))
      assert available.count == 1
    end
  end
end
