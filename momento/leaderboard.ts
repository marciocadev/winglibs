import types from "./leaderboard.extern";
import {
  CredentialProvider,
  PreviewLeaderboardClient,
  LeaderboardConfigurations,
  ILeaderboard,
  LeaderboardUpsert,
  LeaderboardFetch,
  LeaderboardOrder
} from "@gomomento/sdk";

let leadeboardClients: Record<string, ILeaderboard> = {};

async function createLeaderboardClient(token: string, name: string, cacheName: string) {
  if (!leadeboardClients[token]) {
    const client = new PreviewLeaderboardClient({
      configuration: LeaderboardConfigurations.Laptop.v1(),
      credentialProvider: CredentialProvider.fromString(token),
    })

    leadeboardClients[token] = client.leaderboard(cacheName, name);
  }
}

export const _upsert: types["_upsert"] = async (token, leaderboardName, cacheName, elements) => {
  await createLeaderboardClient(token, leaderboardName, cacheName);
  const leaderboardElements: { [key: number]: number } = {};
  for (const key in elements) {
    if (elements.hasOwnProperty(key)) {
      leaderboardElements[Number(key)] = elements[key];
    }
  }
  const upsertResponse = await leadeboardClients[token].upsert(leaderboardElements);
  if (upsertResponse instanceof LeaderboardUpsert.Success) {
    return;
  } else if (upsertResponse instanceof LeaderboardUpsert.Error) {
    throw upsertResponse.innerException();
  } else {
    throw new Error("Unexpected response type");
  }
}

export const _fetchByScore: types["_fetchByScore"] = async (token, leaderboardName, cacheName, options) => {
  await createLeaderboardClient(token, leaderboardName, cacheName);
  const fetchByScoreResponse = await leadeboardClients[token].fetchByScore({
    ...options,
    order: options?.order?.toString() == "Descending" ? LeaderboardOrder.Descending : LeaderboardOrder.Ascending
  });
  if (fetchByScoreResponse instanceof LeaderboardFetch.Success) {
    return fetchByScoreResponse.values();
  } else if (fetchByScoreResponse instanceof LeaderboardFetch.Error) {
    throw fetchByScoreResponse.innerException();
  } else {
    throw new Error("Unexpected response type");
  }
}

// export const _fetchByRank: types["_fetchByRank"] = async (token, leaderboardName, cacheName, start, end) => {
//   await createLeaderboardClient(token, leaderboardName, cacheName);
//   const fetchByRankResponse = await leadeboardClients[token].fetchByRank(start, end);
//   if (fetchByRankResponse instanceof LeaderboardFetch.Success) {
//     return fetchByRankResponse.values();
//   } else if (fetchByRankResponse instanceof LeaderboardFetch.Error) {
//     throw fetchByRankResponse.innerException();
//   } else {
//     throw new Error("Unexpected response type");
//   }
// }