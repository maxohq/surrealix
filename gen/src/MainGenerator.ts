import { GenBase } from "./GenBase";
import { api } from "./api";
import type { IMethod } from "./api";
import { lpad } from "./utils";
import dedent from "ts-dedent";

export class MainGenerator extends GenBase {
  constructor() {
    super();
    this.generatorName = "gen/src/MainGenerator.ts";
  }
  run() {
    this.logRun();
    this.addBanner("ex");
    this.push(`defmodule Surrealix do`);
    this.withIndent(() => {
      this.genStaticFunctions();
      this.genMethods();
    });
    this.push("end");
    this.push("");
  }

  genStaticFunctions() {
    let content = dedent`
    @moduledoc """
    Main entry module for Surrealix
    """
    alias Surrealix.Api, as: Api
    alias Surrealix.Socket, as: Socket


    defdelegate start(opts \\\\ []), to: Socket
    defdelegate start_link(opts \\\\ []), to: Socket
    defdelegate stop(pid), to: Socket

    defdelegate all_live_queries(pid), to: Socket
    defdelegate reset_live_queries(pid), to: Socket
    defdelegate set_auth_ready(pid, value), to: Socket
    defdelegate wait_until_auth_ready(pid), to: Socket

    @doc """
    Convenience method, that combines sending an query (live_query) and registering a callback

    Params:
      sql: string
      vars: map with variables to interpolate into SQL
      callback: fn (event, data, config)
    """
    defdelegate live_query(pid, sql, vars \\\\ %{}, callback), to: Api
    `;
    this.plainPush(lpad(content, "  "));
  }

  genMethods() {
    this.push("");
    api.methods.forEach((method) => {
      this.genMethod(method);
      this.push("");
    });
  }

  genMethod(method: IMethod) {
    this.genMethodDoc(method);
    if (method.argType == "inline") {
      this.genInlineMethod(method);
    }
    if (method.argType == "payload") {
      this.genPayloadMethod(method);
    }
  }

  genPayloadMethod(method: IMethod) {
    this.push(`defdelegate ${method.name}(pid, payload), to: Api`);
    this.push(`defdelegate ${method.name}(pid, payload, task), to: Api`);
    this.push(
      `defdelegate ${method.name}(pid, payload, task, opts), to: Api`
    );
  }

  genInlineMethod(method: IMethod) {
    if (method.parameter.length == 0) {
      this.push(`defdelegate ${method.name}(pid), to: Api`);
    }
    if (method.parameter.length > 0) {
      // ONLY possible to have default values for optional args in a direct call.
      let directParams = method.parameter
        .map((param) => {
          if (param.must) {
            return param.name;
          }
          return `${param.name} \\\\ ${param.default}`;
        })
        .join(", ");

      let params = method.parameter.map((param) => param.name).join(", ");
      this.push(`defdelegate ${method.name}(pid, ${directParams}), to: Api`);
      this.push(`defdelegate ${method.name}(pid, ${params}, task), to: Api`);
      this.push(
        `defdelegate ${method.name}(pid, ${params}, task, opts), to: Api`
      );
    }
  }
  genMethodDoc(method: IMethod) {
    this.push(`@doc """`);
    this.push(`${method.preview}`);
    this.push(`  ${method.desc}`);
    if (method.note) {
      this.push(`  NOTE: ${method.note}`);
    }
    method.examples.map((example) => {
      if (example.title) {
        this.push(`  ${example.title}`);
      }
      this.push(``);
      this.push(`  Example request:`);
      let str = JSON.stringify(example.req.data, null, 2);
      str = lpad(str, "      ");
      this.plainPush(str);
      this.push(``);
      this.push(`  Example response:`);
      str = JSON.stringify(example.res.data, null, 2);
      str = lpad(str, "      ");
      this.plainPush(str);
    });
    this.push(`"""`);
  }
}
