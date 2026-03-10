defmodule Oban.Web.QueuesPageTest do
  use Oban.Web.Case

  alias Oban.Web.QueuesPage

  setup do
    oban = start_supervised_oban!()
    conf = Oban.config(oban)
    {:ok, conf: conf}
  end

  describe "counts/2" do
    test "returns counts from Met when available", %{conf: conf} do
      gossip(queue: "alpha")
      insert_job!([ref: 1], queue: "alpha", state: "available")
      flush_reporter()

      counts = QueuesPage.counts(conf)
      assert Map.get(counts, "alpha", 0) > 0
    end

    test "returns previous counts when Met returns empty", %{conf: conf} do
      previous = %{"alpha" => 5, "beta" => 3}
      assert QueuesPage.counts(conf, previous) == previous
    end

    test "returns fresh counts over previous when Met has data", %{conf: conf} do
      previous = %{"alpha" => 99}

      gossip(queue: "alpha")
      insert_job!([ref: 1], queue: "alpha", state: "available")
      flush_reporter()

      counts = QueuesPage.counts(conf, previous)
      assert counts["alpha"] == 1
    end
  end
end
