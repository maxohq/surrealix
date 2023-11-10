import { GenBase } from "./GenBase";
import { api } from "./api";
import type { IMethod } from "./api";
import { lpad } from "./utils";
import dedent from "ts-dedent";

export class ApiGenerator extends GenBase {
  constructor() {
    super();
    this.generatorName = "gen/src/ApiGenerator.ts";
  }
  run() {
    this.logRun();
    this.addBanner("ex");
    this.push(`defmodule Surrealix.Api do`);
    this.withIndent(() => {
      this.genStaticFunctions();
      this.genCastPayloadFunction();
      this.genMethods();
    });
    this.push("end");
    this.push("");
  }

  genCastPayloadFunction() {
    this.push("");
    this.push(`def build_cast_payload(method, args, id) do`);
    this.withIndent(() => {
      this.push("params =");
      this.withIndent(() => {
        this.push("case method do");
        this.indentUp();
        api.methods.forEach((method) => {
          if (method.argType == "inline") {
            let params = method.parameter
              .map((param) => `args[:${param.name}]`)
              .join(", ");
            this.push(`"${method.name}" -> [${params}]`);
          }

          if (method.argType == "payload") {
            this.push(`"${method.name}" -> [args[:payload]]`);
          }
        });
        this.indentDown();
        this.push("end");
      });
    });

    let code = dedent`

    %{
      "id" => id,
      "method" => method,
      "params" => params
    }
    |> Jason.encode!()
    `;
    this.push(lpad(code, "    "));
    this.push("end");
  }

  genStaticFunctions() {
    let content = dedent`
    @moduledoc """
    Thin layer over the Websockets API for SurrealDB that is 100% generated from a data-structure.
    """

    alias Surrealix.Config
    alias Surrealix.Socket
    alias Surrealix.Util

    defp exec_method(pid, {method, args, task}, opts \\\\ []) do
        Socket.exec_method(pid, {method, args, task}, opts)
    end

    @doc """
    Convenience method that combines sending a (live-)query and registering a callback.

    Params:
        sql: string
        vars: map with variables to interpolate into SQL
        callback: fn (event, data, config)
    """
    @spec live_query(pid(), String.t(), map(), (any, any, list() -> any)) :: :ok
    def live_query(pid, sql, vars \\\\ %{}, callback) do
        with {:sql_live_check, true} <- {:sql_live_check, Util.is_live_query_stmt(sql)},
            {:ok, res} <- query(pid, sql, vars),
            %{"result" => [%{"result" => lq_id}]} <- res do
        event = [:live_query, lq_id]
        :ok = Surrealix.Dispatch.attach("#{lq_id}_main", event, callback)
        :ok = WebSockex.cast(pid, {:register_lq, sql, lq_id})
        {:ok, res}
        end
    end
    `;

    this.plainPush(lpad(content, "  "));
  }

  genMethods() {
    this.push("");
    this.push("### API METHODS : START ###");
    api.methods.forEach((method) => {
      this.genMethod(method);
    });
    this.push("### API METHODS : FINISH ###");
  }

  genMethod(method: IMethod) {
    this.genMethodDoc(method);
    if (method.argType == "inline") {
      this.genInlineMethod(method);
      this.genInlineTaskMethod(method);
    }
    if (method.argType == "payload") {
      this.genPayloadMethod(method);
      this.genPayloadTaskMethod(method);
    }
  }

  genPayloadMethod(method: IMethod) {
    this.push(`def ${method.name}(pid, payload) do`);
    this.push(`  exec_method(pid, {"${method.name}", [payload: payload], nil})`);
    this.push("end");
    this.push("");
  }
  genPayloadTaskMethod(method: IMethod) {
    this.push(
      `def ${method.name}(pid, payload, task, opts \\\\ Config.task_opts_default()) do`
    );
    this.push(
      `  exec_method(pid, {"${method.name}", [payload: payload], task}, opts)`
    );
    this.push("end");
    this.push("");
  }

  genInlineMethod(method: IMethod) {
    if (method.parameter.length == 0) {
      this.push(`def ${method.name}(pid) do`);
    }
    if (method.parameter.length > 0) {
      let params = method.parameter
        .map((param) => {
          if (param.must) {
            return param.name;
          }
          return `${param.name} \\\\ ${param.default}`;
        })
        .join(", ");
      this.push(`def ${method.name}(pid, ${params}) do`);
    }
    let params = method.parameter
      .map((param) => `${param.name}: ${param.name}`)
      .join(", ");
    this.push(`  exec_method(pid, {"${method.name}", [${params}], nil})`);
    this.push("end");
    this.push("");
  }

  genInlineTaskMethod(method: IMethod) {
    if (method.parameter.length == 0) {
      this.push(
        `def ${method.name}(pid, task, opts \\\\ Config.task_opts_default()) do`
      );
    }
    if (method.parameter.length > 0) {
      let names = method.parameter.map((param) => param.name);
      names = names.concat(["task", "opts \\\\ Config.task_opts_default()"]);
      let params = names.join(", ");
      this.push(`def ${method.name}(pid, ${params}) do`);
    }
    let params = method.parameter
      .map((param) => `${param.name}: ${param.name}`)
      .join(", ");
    this.push(`  exec_method(pid, {"${method.name}", [${params}], task}, opts)`);
    this.push("end");
    this.push("");
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
