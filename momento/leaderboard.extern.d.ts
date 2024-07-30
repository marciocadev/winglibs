export default interface extern {
  _fetchByScore: (token: string, leaderboardName: string, cacheName: string, options?: (FetchByScoreOptions) | undefined) => Promise<(readonly (Readonly<any>)[]) | void>,
  _upsert: (token: string, leaderboardName: string, cacheName: string, elements: Readonly<any>) => Promise<void>,
}
export enum LeaderboardOrder {
  Ascending = 0,
  Descending = 1,
}
export interface FetchByScoreOptions {
  /**  The maximum number of elements to return. */
  readonly count?: (number) | undefined;
  /**  Exclusive upper bound for the score range. */
  readonly maxScore?: (number) | undefined;
  /**  Inclusive lower bound for the score range. */
  readonly minScore?: (number) | undefined;
  /**  The number of elements to skip before returning the first element. */
  readonly offset?: (number) | undefined;
  /**  The order to fetch thee elements in.
   @default - Ascending */
  readonly order?: (LeaderboardOrder) | undefined;
}