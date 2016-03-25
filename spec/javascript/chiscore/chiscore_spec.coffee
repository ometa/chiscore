describe "ChiScore", ->
  describe "ChiScore.util", ->
    it "converts seconds to minutes", ->
      expect(ChiScore.util.displayableTime(90)).toEqual("01:30");

    it "pads seconds if it's under 10", ->
      expect(ChiScore.util.displayableTime(62)).toEqual("01:02");

    it "returns 0:00 for numbers if negative", ->
      expect(ChiScore.util.displayableTime(-1)).toEqual("00:00");
