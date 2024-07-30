bring cloud;
bring sim;
bring util;
bring tf;
bring "./cache.w" as cache;
bring "./provider.w" as momento;

pub enum LeaderboardOrder {
  Ascending,
  Descending
}

pub struct FetchByScoreOptions {
  /// Inclusive lower bound for the score range.
  minScore: num?;

  /// Exclusive upper bound for the score range.
  maxScore: num?;

  /// The order to fetch thee elements in.
  /// @default - Ascending
  order: LeaderboardOrder?;

  /// The number of elements to skip before returning the first element.
  offset: num?;

  /// The maximum number of elements to return.
  count: num?;
}

pub struct LeaderboardProps {
  /// A secret containing the Momento API key to use for accessing
  /// the cache at runtime.
  token: cloud.Secret;

  /// The name of the cache used by the leaderboard
  cacheName: str;

  /// The name of the leaderboard.
  /// @default - a unique id will be generated
  name: str?;
}

pub interface ILeaderboard {
  /// Insert or update values in the leaderboard
  inflight upsert(elements: Json): void;

  /// Get elements from score
  inflight fetchByScore(options: FetchByScoreOptions?): Array<Json>?;
}

pub class Leaderboard {
  inner: ILeaderboard;
  new(props: LeaderboardProps) {
    let target = util.env("WING_TARGET");
    let node = nodeof(this);
    let name = props.name ?? node.id.substring(0, 8) + "_" + node.addr.substring(34);
    let cacheName = props.cacheName;
    let token = props.token;
    if target.startsWith("tf") {
      this.inner = new Leaderboard_tf({ name, cacheName, token });
    } elif target == "sim" {
      // this.inner = new Cache_sim({ token, name, defaultTtl });
    } else {
      throw "unsupported target: " + target;
    }
  }

  pub inflight upsert(elements: Json) {
    this.inner.upsert(elements);
  }

  pub inflight fetchByScore(options: FetchByScoreOptions?): Array<Json>? {
    return this.inner.fetchByScore(options);
  }
}

class Leaderboard_tf impl ILeaderboard {
  name: str;
  cacheName: str;
  token: cloud.Secret;

  new(props: LeaderboardProps) {
    this.name = props.name!;
    this.cacheName = props.cacheName;
    this.token = props.token;

    // Create a momento_cache resource to model the cache.
    new tf.Resource(type: "momento_leaderboard", attributes: {
      name: this.name,
      cache_name: this.cacheName,
    });

    // Ensure a provider is available.
    momento.MomentoProvider.getOrCreate(this);
  }

  extern "./leaderboard.ts" static inflight _upsert(token: str, leaderboardName: str, cacheName: str, elements: Json): void;
  extern "./leaderboard.ts" static inflight _fetchByScore(token: str, leaderboardName: str, cacheName: str, options: FetchByScoreOptions?): Array<Json>?;

  pub inflight upsert(elements: Json): void {
    let token = this.token.value(cache: true);
    Leaderboard_tf._upsert(token, this.name, this.cacheName, elements);
  }

  pub inflight fetchByScore(options: FetchByScoreOptions?): Array<Json>? {
    let token = this.token.value(cache: true);
    return Leaderboard_tf._fetchByScore(token, this.name, this.cacheName, options);
  }
}