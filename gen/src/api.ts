type IParamType = "string" | "map" | "any" | "boolean" | "array";

type IExample = {
  title?: string;
  req: {
    desc?: string;
    data: any;
  };
  res: {
    desc?: string;
    data: any;
  };
};
type IParam = {
  name: string;
  must: boolean;
  desc: string;
  type: IParamType;
  default?: any;
};
export type IMethod = {
  name: string;
  desc: string;
  note?: string;
  argType: "inline" | "payload"; // either pass payload as map or use inline args
  preview: string;
  parameter: IParam[];
  examples: IExample[];
};

const useMethod: IMethod = {
  name: "use",
  desc: "Specifies the namespace and database for the current connection",
  preview: "use [ ns, db ]",
  argType: "inline",
  parameter: [
    {
      name: "ns",
      must: true,
      desc: "Specifies the namespace to use",
      type: "string",
    },
    {
      name: "db",
      must: true,
      desc: "Specifies the database to use",
      type: "string",
    },
  ],
  examples: [
    {
      req: {
        data: {
          id: 1,
          method: "use",
          params: ["surrealdb", "docs"],
        },
      },

      res: {
        desc: "",
        data: {
          id: 1,
          result: null,
        },
      },
    },
  ],
};

const infoMethod: IMethod = {
  name: "info",
  desc: "This method returns the record of an authenticated scope user.",
  preview: "info",
  argType: "inline",
  parameter: [],
  examples: [
    {
      req: {
        data: {
          id: 1,
          method: "info",
        },
      },

      res: {
        desc: "The result property of the response is likely different depending on your schema and the authenticated user. However, it does represent the overall structure of the responding message.",
        data: {
          id: 1,
          result: {
            id: "user:john",
            name: "John Doe",
          },
        },
      },
    },
  ],
};

const signupMethod: IMethod = {
  name: "signup",
  desc: "This method allows you to signup a user against a scope's SIGNUP method",
  preview: "signup [ NS, DB, SC, ... ]",
  argType: "payload",
  parameter: [
    {
      name: "ns",
      must: true,
      desc: "Specifies the namespace of the scope",
      type: "string",
    },
    {
      name: "db",
      must: true,
      desc: "Specifies the database of the scope",
      type: "string",
    },
    { name: "sc", must: true, desc: "Specifies the scope", type: "string" },
  ],
  examples: [
    {
      req: {
        data: {
          id: 1,
          method: "signup",
          params: [
            {
              NS: "surrealdb",
              DB: "docs",
              SC: "commenter",

              username: "johndoe",
              password: "SuperStrongPassword!",
            },
          ],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJTdXJyZWFsREIiLCJpYXQiOjE1MTYyMzkwMjIsIm5iZiI6MTUxNjIzOTAyMiwiZXhwIjoxODM2NDM5MDIyLCJOUyI6InRlc3QiLCJEQiI6InRlc3QiLCJTQyI6InVzZXIiLCJJRCI6InVzZXI6dG9iaWUifQ.N22Gp9ze0rdR06McGj1G-h2vu6a6n9IVqUbMFJlOxxA",
        },
      },
    },
  ],
};

const signinMethod: IMethod = {
  name: "signin",
  desc: "This method allows you to signin a root, NS, DB or SC user against SurrealDB",
  preview: "signin [ NS, DB, SC, ... ]",
  argType: "payload",
  parameter: [
    {
      name: "ns",
      must: true,
      desc: "The namespace to sign in to",
      type: "string",
    },
    {
      name: "db",
      must: true,
      desc: "The database to sign in to",
      type: "string",
    },
    {
      name: "sc",
      must: false,
      desc: "The scope to sign in to.",
      type: "string",
    },
    {
      name: "user",
      must: false,
      desc: "The username of the database user",
      type: "string",
    },
    {
      name: "pass",
      must: false,
      desc: "The password of the database user",
      type: "string",
    },
  ],
  examples: [
    {
      title: "As Root",
      req: {
        data: {
          id: 1,
          method: "signin",
          params: [
            {
              user: "tobie",
              pass: "3xtr3m3ly-s3cur3-p@ssw0rd",
            },
          ],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: null,
        },
      },
    },
    {
      title: "Signin as scope",
      req: {
        data: {
          id: 1,
          method: "signin",
          params: [
            {
              NS: "surrealdb",
              DB: "docs",
              SC: "commenter",

              username: "johndoe",
              password: "SuperStrongPassword!",
            },
          ],
        },
      },
      res: {
        data: {
          id: 1,
          result:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJTdXJyZWFsREIiLCJpYXQiOjE1MTYyMzkwMjIsIm5iZiI6MTUxNjIzOTAyMiwiZXhwIjoxODM2NDM5MDIyLCJOUyI6InRlc3QiLCJEQiI6InRlc3QiLCJTQyI6InVzZXIiLCJJRCI6InVzZXI6dG9iaWUifQ.N22Gp9ze0rdR06McGj1G-h2vu6a6n9IVqUbMFJlOxxA",
        },
      },
    },
  ],
};

const authenticateMethod: IMethod = {
  name: "authenticate",
  desc: "This method allows you to authenticate a user against SurrealDB with a token",
  preview: "authenticate [ token ]",
  argType: "inline",
  parameter: [
    {
      name: "token",
      must: true,
      desc: "The token that authenticates the user",
      type: "string",
    },
  ],
  examples: [
    {
      title: "",
      req: {
        data: {
          id: 1,
          method: "authenticate",
          params: [
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJTdXJyZWFsREIiLCJpYXQiOjE1MTYyMzkwMjIsIm5iZiI6MTUxNjIzOTAyMiwiZXhwIjoxODM2NDM5MDIyLCJOUyI6InRlc3QiLCJEQiI6InRlc3QiLCJTQyI6InVzZXIiLCJJRCI6InVzZXI6dG9iaWUifQ.N22Gp9ze0rdR06McGj1G-h2vu6a6n9IVqUbMFJlOxxA",
          ],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: null,
        },
      },
    },
  ],
};

const invalidateMethod: IMethod = {
  name: "invalidate",
  desc: "This method will invalidate the user's session for the current connection",
  preview: "invalidate",
  parameter: [],
  argType: "inline",
  examples: [
    {
      title: "",
      req: {
        data: {
          id: 1,
          method: "invalidate",
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: null,
        },
      },
    },
  ],
};

const letMethod: IMethod = {
  name: "let",
  desc: "This method stores a variable on the current connection",
  preview: "let [ name, value ]",
  argType: "inline",
  parameter: [
    {
      name: "name",
      must: true,
      desc: "The name for the variable without a prefixed $ character",
      type: "string",
    },
    {
      name: "value",
      must: true,
      desc: "The value for the variable",
      type: "any",
    },
  ],
  examples: [
    {
      title: "",
      req: {
        data: {
          id: 1,
          method: "let",
          params: ["website", "https://surrealdb.com/"],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: null,
        },
      },
    },
  ],
};

const unsetMethod: IMethod = {
  name: "unset",
  desc: "This method removes a variable from the current connection",
  preview: "unset [ name ]",
  argType: "inline",
  parameter: [
    {
      name: "name",
      must: true,
      desc: "The name for the variable without a prefixed $ character",
      type: "string",
    },
  ],
  examples: [
    {
      title: "",
      req: {
        data: {
          id: 1,
          method: "unset",
          params: ["website"],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: null,
        },
      },
    },
  ],
};

const liveMethod: IMethod = {
  name: "live",
  desc: "This methods initiates a live query for a specified table name",
  note: "For more advanced live queries where filters are needed, use the Query method to initiate a custom live query.",
  preview: "live [ table ]",
  argType: "inline",
  parameter: [
    {
      name: "table",
      must: true,
      desc: "The table to initiate a live query for",
      type: "string",
    },
    {
      name: "diff",
      must: false,
      desc: "If set to true, live notifications will contain an array of JSON Patches instead of the entire record",
      type: "boolean",
      default: false,
    },
  ],
  examples: [
    {
      title: "",
      req: {
        data: {
          id: 1,
          method: "live",
          params: ["person"],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: "0189d6e3-8eac-703a-9a48-d9faa78b44b9",
        },
      },
    },
    {
      title: "Live notification",
      req: {
        data: {},
      },
      res: {
        desc: "For every creation, update or deletion on the specified table, a live notification will be sent. Live notifications do not have an ID attached, but rather include the Live Query's UUID in the result object.",
        data: {
          result: {
            action: "CREATE",
            id: "0189d6e3-8eac-703a-9a48-d9faa78b44b9",
            result: {
              id: "person:8s0j0bbm3ngrd5c9bx53",
              name: "John",
            },
          },
        },
      },
    },
  ],
};

const killMethod: IMethod = {
  name: "kill",
  desc: "This methods kills an active live query",
  preview: "kill [ queryUuid ]",
  argType: "inline",
  parameter: [
    {
      name: "queryUuid",
      must: true,
      desc: "The UUID of the live query to kill",
      type: "string",
    },
  ],
  examples: [
    {
      title: "",
      req: {
        data: {
          id: 1,
          method: "kill",
          params: ["0189d6e3-8eac-703a-9a48-d9faa78b44b9"],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: null,
        },
      },
    },
  ],
};

const queryMethod: IMethod = {
  name: "query",
  desc: "This method executes a custom query against SurrealDB",
  preview: "query [ sql, vars ]",
  argType: "inline",
  parameter: [
    {
      name: "sql",
      must: true,
      desc: "The query to execute against SurrealDB",
      type: "string",
    },
    {
      name: "vars",
      must: false,
      desc: "A set of variables used by the query",
      type: "map",
      default: "%{}",
    },
  ],
  examples: [
    {
      title: "",
      req: {
        data: {
          id: 1,
          method: "query",
          params: [
            "CREATE person SET name = 'John'; SELECT * FROM type::table($tb);",
            {
              tb: "person",
            },
          ],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: [
            {
              status: "OK",
              time: "152.5µs",
              result: [
                {
                  id: "person:8s0j0bbm3ngrd5c9bx53",
                  name: "John",
                },
              ],
            },
            {
              status: "OK",
              time: "32.375µs",
              result: [
                {
                  id: "person:8s0j0bbm3ngrd5c9bx53",
                  name: "John",
                },
              ],
            },
          ],
        },
      },
    },
  ],
};

const selectMethod: IMethod = {
  name: "select",
  desc: "This method selects either all records in a table or a single record",
  preview: "select [ thing ]",
  argType: "inline",
  parameter: [
    {
      name: "thing",
      must: true,
      desc: "The thing (Table or Record ID) to select",
      type: "string",
    },
  ],
  examples: [
    {
      title: "",
      req: {
        data: {
          id: 1,
          method: "select",
          params: ["person"],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: [
            {
              id: "person:8s0j0bbm3ngrd5c9bx53",
              name: "John",
            },
          ],
        },
      },
    },
  ],
};

const createMethod: IMethod = {
  name: "create",
  desc: "This method creates a record either with a random or specified ID",
  preview: "create [ thing, data ]",
  argType: "inline",
  parameter: [
    {
      name: "thing",
      must: true,
      desc: "The thing (Table or Record ID) to create. Passing just a table will result in a randomly generated ID",
      type: "string",
    },
    {
      name: "data",
      must: false,
      desc: "The content of the record",
      default: "%{}",
      type: "map",
    },
  ],
  examples: [
    {
      title: "",
      req: {
        data: {
          id: 1,
          method: "create",
          params: [
            "person",
            {
              name: "Mary Doe",
            },
          ],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: [
            {
              id: "person:s5fa6qp4p8ey9k5j0m9z",
              name: "Mary Doe",
            },
          ],
        },
      },
    },
  ],
};

const insertMethod: IMethod = {
  name: "insert",
  desc: "This method creates a record either with a random or specified ID",
  preview: "insert [ thing, data ]",
  argType: "inline",
  parameter: [
    {
      name: "thing",
      must: true,
      desc: "The table to insert in to",
      type: "string",
    },
    {
      name: "data",
      must: false,
      desc: "One or multiple record(s)",
      type: "map",
      default: "%{}",
    },
  ],
  examples: [
    {
      title: "Single insert",
      req: {
        data: {
          id: 1,
          method: "insert",
          params: [
            "person",
            {
              name: "Mary Doe",
            },
          ],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: [
            {
              id: "person:s5fa6qp4p8ey9k5j0m9z",
              name: "Mary Doe",
            },
          ],
        },
      },
    },
    {
      title: "Bulk insert",
      req: {
        data: {
          id: 1,
          method: "insert",
          params: [
            "person",
            [
              {
                name: "Mary Doe",
              },
              {
                name: "John Doe",
              },
            ],
          ],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: [
            {
              id: "person:s5fa6qp4p8ey9k5j0m9z",
              name: "Mary Doe",
            },
            {
              id: "person:xtbbojcm82a97vus9x0j",
              name: "John Doe",
            },
          ],
        },
      },
    },
  ],
};

const updateMethod: IMethod = {
  name: "update",
  desc: "This method replaces either all records in a table or a single record with specified data",
  note: "This function replaces the current document / record data with the specified data. If no replacement data is passed it will simply trigger an update.",
  preview: "update [ thing, data ]",
  argType: "inline",
  parameter: [
    {
      name: "thing",
      must: true,
      desc: "The thing (Table or Record ID) to update",
      type: "string",
    },
    {
      name: "data",
      must: false,
      desc: "The new content of the record",
      type: "map",
      default: "%{}",
    },
  ],
  examples: [
    {
      title: "",
      req: {
        data: {
          id: 1,
          method: "update",
          params: [
            "person:8s0j0bbm3ngrd5c9bx53",
            {
              name: "John Doe",
            },
          ],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: {
            id: "person:8s0j0bbm3ngrd5c9bx53",
            name: "John Doe",
          },
        },
      },
    },
  ],
};

const mergeMethod: IMethod = {
  name: "merge",
  desc: "This method merges specified data into either all records in a table or a single record",
  note: "This function merges the current document / record data with the specified data. If no merge data is passed it will simply trigger an update.",
  preview: "merge [ thing, data ]",
  argType: "inline",
  parameter: [
    {
      name: "thing",
      must: true,
      desc: "The thing (Table or Record ID) to merge into",
      type: "string",
    },
    {
      name: "data",
      must: false,
      desc: "The content to be merged",
      type: "map",
      default: "%{}",
    },
  ],
  examples: [
    {
      title: "",
      req: {
        data: {
          id: 1,
          method: "merge",
          params: [
            "person",
            {
              active: true,
            },
          ],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: [
            {
              active: true,
              id: "person:8s0j0bbm3ngrd5c9bx53",
              name: "John Doe",
            },
            {
              active: true,
              id: "person:s5fa6qp4p8ey9k5j0m9z",
              name: "Mary Doe",
            },
          ],
        },
      },
    },
  ],
};

const patchMethod: IMethod = {
  name: "patch",
  desc: "This method patches either all records in a table or a single record with specified patches",
  note: "This function patches the current document / record data with the specified JSON Patch data.",
  preview: "patch [ thing, patches, diff ]",
  argType: "inline",
  parameter: [
    {
      name: "thing",
      must: true,
      desc: "The thing (Table or Record ID) to patch",
      type: "string",
    },
    {
      name: "patches",
      must: true,
      desc: "An array of patches following the JSON Patch specification",
      type: "array",
    },
    {
      name: "diff",
      must: false,
      desc: "A boolean representing if just a diff should be returned.",
      type: "boolean",
      default: false,
    },
  ],
  examples: [
    {
      title: "",
      req: {
        data: {
          id: 1,
          method: "patch",
          params: [
            "person",
            [
              {
                op: "replace",
                path: "/last_updated",
                value: "2023-06-16T08:34:25Z",
              },
            ],
          ],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: [
            [
              {
                op: "add",
                path: "/last_updated",
                value: "2023-06-16T08:34:25Z",
              },
            ],
            [
              {
                op: "add",
                path: "/last_updated",
                value: "2023-06-16T08:34:25Z",
              },
            ],
          ],
        },
      },
    },
  ],
};

const deleteMethod: IMethod = {
  name: "delete",
  desc: "This method deletes either all records in a table or a single record",
  preview: "delete [ thing ]",
  argType: "inline",
  parameter: [
    {
      name: "thing",
      must: true,
      desc: "The thing (Table or Record ID) to delete",
      type: "string",
    },
  ],
  examples: [
    {
      title: "",
      req: {
        data: {
          id: 1,
          method: "delete",
          params: ["person:8s0j0bbm3ngrd5c9bx53"],
        },
      },
      res: {
        desc: "",
        data: {
          id: 1,
          result: {
            active: true,
            id: "person:8s0j0bbm3ngrd5c9bx53",
            last_updated: "2023-06-16T08:34:25Z",
            name: "John Doe",
          },
        },
      },
    },
  ],
};

export const api = {
  methods: [
    useMethod,
    infoMethod,
    signupMethod,
    signinMethod,
    authenticateMethod,
    invalidateMethod,
    letMethod,
    unsetMethod,
    liveMethod,
    killMethod,
    queryMethod,
    selectMethod,
    createMethod,
    insertMethod,
    updateMethod,
    mergeMethod,
    patchMethod,
    deleteMethod,
  ],
};
