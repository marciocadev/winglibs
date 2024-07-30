bring cloud;
bring expect;
bring "./cache.w" as c;
bring "./leaderboard.w" as l;
bring util;

let token = new cloud.Secret(name: "MOMENTO_API_KEY");

let cache = new c.Cache(token: token) as "WinglyCache";
let leaderboard = new l.Leaderboard(token: token, cacheName: cache.cache_name()) as "WinglyLeaderboard";

test "upsert and fetchByScore" {
  leaderboard.upsert({"1": 500, "2": 123, "3": 1000, "4": 2, "5": 3});
  
  if let ascending = leaderboard.fetchByScore() {
    expect.equal(ascending.length, 5);
    expect.equal(ascending.at(0).get("id"), 4);
    expect.equal(ascending.at(1).get("id"), 5);
    expect.equal(ascending.at(2).get("id"), 2);
    expect.equal(ascending.at(3).get("id"), 1);
    expect.equal(ascending.at(4).get("id"), 3);
  }

  if let minMax = leaderboard.fetchByScore(minScore: 100, maxScore: 900) {
    expect.equal(minMax.length, 2);
    expect.equal(minMax.at(0).get("id"), 2);
    expect.equal(minMax.at(1).get("id"), 1);
  }

  if let descending = leaderboard.fetchByScore(order: l.LeaderboardOrder.Descending) {
    expect.equal(descending.length, 5);
    expect.equal(descending.at(0).get("id"), 3);
    expect.equal(descending.at(1).get("id"), 1);
    expect.equal(descending.at(2).get("id"), 2);
    expect.equal(descending.at(3).get("id"), 5);
    expect.equal(descending.at(4).get("id"), 4);
  }
}