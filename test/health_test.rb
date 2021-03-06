require "test_helper"

describe Health do
  before do
    @e = Endpoint.create
  end

  describe ".update" do
    it "sets status to gray when we don't have enough data" do
      Health.update(@e, {})
      assert_equal "gray", @e.health
    end

    it "sets it to red when there are too many errors" do
      Health.update(@e, { 500 => 20 })
      assert_equal "red", @e.health
      assert_equal "100% errors", @e.health_msg
    end

    it "sets it too red when error rates are higher" do
      @e.stats = { 200 => 99, 500 => 1 }
      Health.update(@e, { 200 => 88, 500 => 12 })
      assert_equal "red", @e.health
      assert_equal "error rate increased 11%", @e.health_msg
    end

    it "updates the endpoints stats" do
      Health.update(@e, { 200 => 1 })
      assert_equal({ 200 => 1 }, @e.stats)
    end
  end

  describe ".compute_error_rate" do
    it "returns 0 if there are no requests" do
      assert_equal 0, Health.compute_error_rate({})
    end

    it "returns the % of 50x requests" do
      assert_equal 10, Health.compute_error_rate(200 => 9, 500 => 1)
      assert_equal 100, Health.compute_error_rate(503 => 1)
    end
  end
end
