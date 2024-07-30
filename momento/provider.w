bring tf;
bring util;

pub class MomentoProvider {
  pub static getOrCreate(scope: std.IResource): tf.Provider {
    let root = nodeof(scope).root;
    let singletonKey = "MomentoProvider";
    let existing = nodeof(root).tryFindChild(singletonKey);
    if existing != nil {
      return unsafeCast(existing);
    }

    return new tf.Provider(
      name: "momento",
      source: "momentohq/momento",
      version: "0.2.1",
      attributes: {
        api_key: util.env("MOMENTO_API_KEY"),
      }
    ) as singletonKey in root;
  }
}
