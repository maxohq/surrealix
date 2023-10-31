import { GenBase } from "./GenBase";
import { api } from "./api";
import type { IMethod } from "./api";
import { lpad } from "./utils";
import dedent from "ts-dedent";

export class TopGenerator extends GenBase {
  constructor() {
    super();
    this.generatorName = "gen/src/TopGenerator.ts";
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
  }

  genStaticFunctions() {
    let content = dedent`
    alias Surrealix.Socket, as: Socket

    defdelegate start_link(), to: Socket
    defdelegate start_link(opts), to: Socket

    defdelegate stop(pid), to: Socket
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
    this.push(`defdelegate ${method.name}(pid, payload), to: Socket`);
    this.push(`defdelegate ${method.name}(pid, payload, task), to: Socket`);
    this.push(
      `defdelegate ${method.name}(pid, payload, task, opts), to: Socket`
    );
  }

  genInlineMethod(method: IMethod) {
    if (method.parameter.length == 0) {
      this.push(`defdelegate ${method.name}(pid), to: Socket`);
    }
    if (method.parameter.length > 0) {
      let params = method.parameter
        .map((param) => {
          return param.name;

          // return `${param.name} \\\\ ${param.default}`;
        })
        .join(", ");
      this.push(`defdelegate ${method.name}(pid, ${params}), to: Socket`);
      this.push(`defdelegate ${method.name}(pid, ${params}, task), to: Socket`);
      this.push(
        `defdelegate ${method.name}(pid, ${params}, task, opts), to: Socket`
      );
    }
  }
  genMethodDoc(method: IMethod) {
    this.push(`@doc """`);
    this.push(`${method.preview}`);
    this.push(`  ${method.desc}`);
    method.examples.map((example) => {
      if (example.title) {
        this.push(`  ${example.title}`);
      }
      this.push(``);
      this.push(`  Example request:`);
      let str = JSON.stringify(example.req.data, null, 2);
      this.plainPush(lpad(str, "    "));
      this.push(``);
      this.push(`  Example response:`);
      str = JSON.stringify(example.res.data, null, 2);
      this.plainPush(lpad(str, "    "));
    });
    this.push(`"""`);
  }
}
