import { GenBase } from "./GenBase";
import { api } from "./api";
import type { IMethod } from "./api";
import { lpad } from "./utils";
import dedent from "ts-dedent";

export class SocketGenerator extends GenBase {
  constructor() {
    super();
    this.generatorName = "gen/src/SocketGenerator.ts";
  }
  run() {
    this.logRun();
    this.addBanner("ex");
    this.push(`defmodule Surrealix.Socket do`);
    this.withIndent(() => {
      this.genStaticFunctions();
      this.genCastPayloadFunction();
      this.genMethods();
    });
    this.push("end");
  }

  genCastPayloadFunction() {
    this.push("");
    this.push(`defp build_cast_payload(method, args) do`);
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
      "id" => :rand.uniform(9999) |> to_string(),
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
    use WebSockex

    @type socket_opts :: [
            hostname: String.t(),
            port: integer(),
            namespace: String.t(),
            database: String.t(),
            username: String.t(),
            password: String.t()
          ]

    @type base_connection_opts :: socket_opts()
    @base_connection_opts Application.compile_env(:surrealix, :connection,
                            hostname: "localhost",
                            port: 8000,
                            namespace: "default",
                            database: "default",
                            username: "root",
                            password: "root"
                          )

    @spec start_link(socket_opts()) :: WebSockex.on_start()
    def start_link(opts \\\\ []) do
      opts =
        Keyword.merge(
          @base_connection_opts,
          opts
        )

      hostname = Keyword.get(opts, :hostname)
      port = Keyword.get(opts, :port)

      WebSockex.start_link("ws://#{hostname}:#{port}/rpc", __MODULE__, opts)
    end

    @spec stop(pid()) :: :ok
    def stop(pid) do
      Process.exit(pid, :kill)
      :ok
    end

    def terminate(reason, state) do
      IO.puts("Socket Terminating:\\n#{inspect(reason)}\\n\\n#{inspect(state)}\\n")
      exit(:normal)
    end

    def handle_cast(caller, _state) do
      {method, args} = caller

      payload = build_cast_payload(method, args)

      frame = {:text, payload}
      {:reply, frame, args}
    end

    def handle_frame({type, msg}, state) do
      IO.inspect({"HANDLE_FRAME", type, msg})
      # IO.inspect(state, label: "state")
      task = Keyword.get(state, :__receiver__)

      Process.send(task.pid, {:ok, Jason.decode!(msg)}, [])
      {:ok, state}
    end

    defp exec_method(pid, {method, args}, opts \\\\ []) do
      task =
        Task.async(fn ->
          receive do
            {:ok, msg} ->
              if is_map(msg) and Map.has_key?(msg, "error"), do: {:error, msg}, else: {:ok, msg}

            {:error, reason} ->
              {:error, reason}

            _ ->
              {:error, "Unknown Error"}
          end
        end)

      WebSockex.cast(pid, {method, Keyword.merge([__receiver__: task], args)})

      task_timeout = Keyword.get(opts, :timeout, :infinity)
      Task.await(task, task_timeout)
    end

    defp task_opts_default, do: [timeout: :infinity]
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
    this.push(`  exec_method(pid, {"${method.name}", [payload: payload]})`);
    this.push("end");
    this.push("");
  }
  genPayloadTaskMethod(method: IMethod) {
    this.push(
      `def ${method.name}(pid, payload, task, opts \\\\ task_opts_default()) do`
    );
    this.push(
      `  exec_method(pid, {"${method.name}", [payload: payload, __receiver__: task]}, opts)`
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
    this.push(`  exec_method(pid, {"${method.name}", [${params}]})`);
    this.push("end");
    this.push("");
  }

  genInlineTaskMethod(method: IMethod) {
    if (method.parameter.length == 0) {
      this.push(
        `def ${method.name}(pid, task, opts \\\\ task_opts_default()) do`
      );
    }
    if (method.parameter.length > 0) {
      let names = method.parameter.map((param) => param.name);
      names = names.concat(["task", "opts \\\\ task_opts_default()"]);
      let params = names.join(", ");
      this.push(`def ${method.name}(pid, ${params}) do`);
    }
    let params = method.parameter
      .map((param) => `${param.name}: ${param.name}`)
      .concat([`__receiver__: task`])
      .join(", ");
    this.push(`  exec_method(pid, {"${method.name}", [${params}]}, opts)`);
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
      str = lpad(str, "    ");
      this.plainPush(str);
      this.push(``);
      this.push(`  Example response:`);
      str = JSON.stringify(example.res.data, null, 2);
      str = lpad(str, "    ");
      this.plainPush(str);
    });
    this.push(`"""`);
  }
}
