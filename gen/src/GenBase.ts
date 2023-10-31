/**
 * Generator base class
 * - provides basic functions to help with code generation
 */

type FileType = "ex" | "ts";
export class GenBase {
  logLevel = 1; // change for more verbose logging
  lines: string[] = [];
  indentLevel: number = 0;
  prefix: string = "";
  generatorName: string = "";

  get content() {
    return this.lines.join("\n");
  }

  push(line: string) {
    this.lines.push(this.prefix + line);
  }
  plainPush(line: string) {
    this.lines.push(line);
  }
  indentUp(amount: number = 1) {
    this.indentLevel += amount;
    this.setPrefix();
  }

  indentDown(amount: number = 1) {
    this.indentLevel -= amount;
    this.setPrefix();
  }

  setPrefix() {
    this.prefix = Array(this.indentLevel).fill("  ").join("");
  }

  withIndent(func: Function) {
    this.indentUp();
    func();
    this.indentDown();
  }

  addBanner(type: FileType) {
    if (type == "ts") {
      this.push(
        `// **** GENERATED CODE! see ${this.generatorName} for details. ****`
      );
    }
    if (type == "ex") {
      this.push(
        `## **** GENERATED CODE! see ${this.generatorName} for details. ****`
      );
    }
    this.push("");
  }

  logRun() {
    this.log(`*** RUN GENERATOR ${this.generatorName}`);
  }

  log(...s: any) {
    console.log(...s);
  }

  warn(...s: any) {
    if (this.logLevel < 2) {
      return;
    }
    this.log(...s);
  }

  debug(...s: any) {
    if (this.logLevel < 3) {
      return;
    }
    this.log(...s);
  }
}
